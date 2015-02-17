// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.build.import_crawler;

import 'dart:async';
import 'dart:collection' show LinkedHashMap;
import 'package:code_transformers/assets.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:barback/barback.dart';
import 'package:html5lib/dom.dart' show Document, Element;
import 'common.dart';
import 'messages.dart';

/// Information about an html import found in a document.
class ImportData {
  /// The [Document] where the html import appeared.
  final Document document;

  /// The html import element itself.
  final Element element;

  ImportData(this.document, this.element);
}

/// A crawler for html imports.
class ImportCrawler {
  // Can be either an AggregateTransform or Transform.
  final _transform;
  final BuildLogger _logger;
  final AssetId _primaryInputId;

  ImportCrawler(this._transform, this._primaryInputId, this._logger);

  /// Returns a post-ordered map of [AssetId]'s to [ImportData]. The [AssetId]'s
  /// represent an asset which was discovered via an html import, and the
  /// [ImportData] represents the [Document] where it was discovered and the
  /// html import [Element] itself.
  Future<LinkedHashMap<AssetId, ImportData>> crawlImports() {
    var documents = new LinkedHashMap<AssetId, ImportData>();
    var seen = new Set<AssetId>();

    Future doCrawl(AssetId assetId, [Element import]) {
      if (seen.contains(assetId)) return null;
      seen.add(assetId);

      return _transform.readInputAsString(assetId).then((html) {
        var document = parseHtml(html, assetId.path);

        var imports = document.querySelectorAll('link[rel="import"]');
        var done =
            Future.forEach(imports, (i) => doCrawl(_importId(assetId, i), i));

        // Add this document after its dependencies.
        return done.then((_) {
          documents[assetId] = new ImportData(document, import);
        });
      }).catchError((error) {
        var span;
        if (import != null) span = import.sourceSpan;
        _logger.error(inlineImportFail.create({'error': error}), span: span);
      });
    }

    return doCrawl(_primaryInputId).then((_) => documents);
  }

  AssetId _importId(AssetId source, Element import) {
    var url = import.attributes['href'];
    return uriToAssetId(source, url, _transform.logger, import.sourceSpan);
  }
}
