// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Transformer used for pub serve and pub build
library web_components.build.web_components;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:code_transformers/assets.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:code_transformers/resolver.dart';
import 'package:html5lib/dom.dart' as dom;
import 'package:initialize/transformer.dart' show generateBootstrapFile;
import 'package:path/path.dart' as path;
import 'package:web_components/transformer.dart';
import 'common.dart';

/// A [Transformer] which runs the `initialize` transformer with
/// some special plugins and also inlines the html imports.
class WebComponentsTransformer extends Transformer {
  final Resolvers _resolvers;
  TransformOptions options;

  WebComponentsTransformer(this.options) : _resolvers = new Resolvers.fromMock({
        // The list of types below is derived from:
        //   * types that are used internally by the resolver (see
        //   _initializeFrom in resolver.dart).
        // TODO(jakemac): Move this into code_transformers so it can be shared.
        'dart:core': '''
          library dart.core;
          class Object {}
          class Function {}
          class StackTrace {}
          class Symbol {}
          class Type {}

          class String extends Object {}
          class bool extends Object {}
          class num extends Object {}
          class int extends num {}
          class double extends num {}
          class DateTime extends Object {}
          class Null extends Object {}

          class Deprecated extends Object {
            final String expires;
            const Deprecated(this.expires);
          }
          const Object deprecated = const Deprecated("next release");
          class _Override { const _Override(); }
          const Object override = const _Override();
          class _Proxy { const _Proxy(); }
          const Object proxy = const _Proxy();

          class List<V> extends Object {}
          class Map<K, V> extends Object {}
          ''',
        'dart:html': '''
          library dart.html;
          class HtmlElement {}
          ''',
        'dart:async': '''
          library dart.async;
          class Future<T> {}
        ''',
      });

  bool isPrimary(AssetId id) {
    if (options.entryPoints != null) {
      return options.entryPoints.contains(id.path);
    }
    if (id.path == 'web/index.bootstrap.dart') return true;
    // If no entry point is supplied, then any html file under web/ or test/ is
    // an entry point.
    return (id.path.startsWith('web/') || id.path.startsWith('test/')) &&
        id.path.endsWith('.html');
  }

  Future apply(Transform transform) {
    var logger = new BuildLogger(transform);
    var primaryInput = transform.primaryInput;
    return primaryInput.readAsString().then((html) {
      // Find the dart script in the page.
      var doc = parseHtml(html, primaryInput.id.path);
      var mainScriptTag = doc.querySelector('script[type="$dartType"]');
      var scriptId = uriToAssetId(primaryInput.id,
          mainScriptTag.attributes['src'], logger, mainScriptTag.sourceSpan);

      return _resolvers.get(transform, [scriptId]).then((resolver) {
        var newScriptId = new AssetId(scriptId.package,
            '${path.url.withoutExtension(scriptId.path)}.initialize.dart');

        // Bootstrap the application using the `initialize` package and the
        // html import annotation recorder plugin.
        var htmlImportRecorder = new HtmlImportAnnotationRecorder();
        var initializeBootstrap = generateBootstrapFile(
            resolver, transform, scriptId, newScriptId,
            errorIfNotFound: false, plugins: [htmlImportRecorder]);
        transform.addOutput(initializeBootstrap);

        // Add all seen imports to the document.
        for (var importPath in htmlImportRecorder.importPaths) {
          doc.head.append(new dom.Element.tag('link')
            ..attributes = {'rel': 'import', 'href': importPath,});
        }

        // Swap out the main script tag for the bootstrap version.
        mainScriptTag.attributes['src'] = path.url.relative(
            initializeBootstrap.id.path,
            from: path.url.dirname(primaryInput.id.path));

        transform
            .addOutput(new Asset.fromString(primaryInput.id, doc.outerHtml));
      });
    });
  }
}
