// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Contains logic to initialize web_components apps during development. This
/// implementation uses dart:mirrors to load each library as they are discovered
/// through HTML imports. This is only meant to be used during development in
/// dartium, and the web_components transformers replace this implementation
/// for deployment.
library web_components.src.mirror_initializer;

import 'dart:async';
import 'dart:collection' show LinkedHashMap;
import 'dart:mirrors';
import 'dart:html';
import 'package:initialize/initialize.dart' as init;

Future run({List<Type> typeFilter, init.InitializerFilter customFilter}) async {
  var libraryUris = _discoverLibrariesToLoad(document, window.location.href)
      .map(Uri.parse);

  for (var uri in libraryUris) {
    await init.run(
        typeFilter: typeFilter, customFilter: customFilter, from: uri);
  }
  return null;
}

/// Walks the HTML import structure to discover all script tags that are
/// implicitly loaded. This code is only used in Dartium and should only be
/// called after all HTML imports are resolved. Polymer ensures this by asking
/// users to put their Dart script tags after all HTML imports (this is checked
/// by the linter, and Dartium will otherwise show an error message).
Iterable<_ScriptInfo> _discoverScripts(
    Document doc, String baseUri, [_State state]) {
  if (state == null) state = new _State();
  if (doc == null) {
    print('warning: $baseUri not found.');
    return state.scripts.values;
  }
  if (!state.seen.add(doc)) return state.scripts.values;

  for (var node in doc.querySelectorAll('script,link[rel="import"]')) {
    if (node is LinkElement) {
      _discoverScripts(node.import, node.href, state);
    } else if (node is ScriptElement && node.type == 'application/dart') {
      var info = _scriptInfoFor(node, baseUri);
      if (state.scripts.containsKey(info.resolvedUrl)) {
        // TODO(jakemac): Move this to a web_components uri.
        print('warning: Script `${info.resolvedUrl}` included more than once. '
            'See http://goo.gl/5HPeuP#polymer_44 for more details.');
      } else {
        state.scripts[info.resolvedUrl] = info;
      }
    }
  }
  return state.scripts.values;
}

/// Internal state used in [_discoverScripts].
class _State {
  /// Documents that we have visited thus far.
  final Set<Document> seen = new Set();

  /// Scripts that have been discovered, in tree order.
  final LinkedHashMap<String, _ScriptInfo> scripts = {};
}

/// Holds information about a Dart script tag.
class _ScriptInfo {
  /// The original URL seen in the tag fully resolved.
  final String resolvedUrl;

  /// Whether it seems to be a 'package:' URL (starts with the package-root).
  bool get isPackage => packageUrl != null;

  /// The equivalent 'package:' URL, if any.
  final String packageUrl;

  _ScriptInfo(this.resolvedUrl, {this.packageUrl});
}


// TODO(sigmund): explore other (cheaper) ways to resolve URIs relative to the
// root library (see dartbug.com/12612)
final _rootUri = currentMirrorSystem().isolate.rootLibrary.uri;

/// Returns [_ScriptInfo] for [script] which was seen in [baseUri].
_ScriptInfo _scriptInfoFor(script, baseUri) {
  var uriString = script.src;
  if (uriString != '') {
    var uri = _rootUri.resolve(uriString);
    if (!_isHttpStylePackageUrl(uri)) return new _ScriptInfo('$uri');
    // Use package: urls if available. This rule here is more permissive than
    // how we translate urls in polymer-build, but we expect Dartium to limit
    // the cases where there are differences. The polymer-build issues an error
    // when using packages/ inside lib without properly stepping out all the way
    // to the packages folder. If users don't create symlinks in the source
    // tree, then Dartium will also complain because it won't find the file seen
    // in an HTML import.
    var packagePath = uri.path.substring(
        uri.path.lastIndexOf('packages/') + 'packages/'.length);
    return new _ScriptInfo('$uri', packageUrl: 'package:$packagePath');
  }

  // Even in the case of inline scripts its ok to just use the baseUri since
  // there can only be one per page.
  return new _ScriptInfo(baseUri);
}

/// Whether [uri] is an http URI that contains a 'packages' segment, and
/// therefore could be converted into a 'package:' URI.
bool _isHttpStylePackageUrl(Uri uri) {
  var uriPath = uri.path;
  return uri.scheme == _rootUri.scheme &&
      // Don't process cross-domain uris.
      uri.authority == _rootUri.authority &&
      uriPath.endsWith('.dart') &&
      (uriPath.contains('/packages/') || uriPath.startsWith('packages/'));
}

Iterable<String> _discoverLibrariesToLoad(Document doc, String baseUri) =>
    _discoverScripts(doc, baseUri).map(
        (info) => _packageUrlExists(info) ? info.packageUrl : info.resolvedUrl);

/// All libraries in the current isolate.
final _libs = currentMirrorSystem().libraries;

bool _packageUrlExists(_ScriptInfo info) =>
    info.isPackage && _libs[Uri.parse(info.packageUrl)] != null;
