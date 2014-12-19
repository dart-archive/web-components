// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web_components.build.import_inliner;

import 'dart:async';
import 'package:html5lib/dom.dart' show Document, Element, Node;

abstract class ImportReader {
  Future<Document> readImport(Element import);
}

class ImportInliner {
  final ImportReader _importReader;

  ImportInliner(this._importReader);

  // TODO(jakemac): Dedupe imports based on location
  // TODO(jakemac): Normalize paths in attributes when inlining
  Future<Document> inlineImports(Document document,
        [Element importsWrapper, bool inPlace = true]) {
    if (importsWrapper == null) {
      importsWrapper = new Element.html('<div style="display:none;"></div>');
    }
    // Copy document if not editing in place.
    if (!inPlace) document = document.clone(true);

    var imports = document.querySelectorAll('link[rel="import"]');
    var done = Future.wait(imports.map(
        (import) => _inlineImport(document, importsWrapper, import)));
    return done.then((_) {
      // Insert the importsWrapper element at top of body if we had any imports.
      if (importsWrapper.hasChildNodes()) {
        document.body.insertBefore(importsWrapper, document.body.firstChild);
      }
      return document;
    });
  }

  Future _inlineImport(Document document, Element importsWrapper,
                       Element import) {
    return _importReader.readImport(import).then((importedDocument) {
      // Create copies of the imports we find, don't modify them in place.
      return inlineImports(importedDocument, importsWrapper, false).then((_) {
        for (var node in importedDocument.body.nodes) {
          importsWrapper.append(node.clone(true));
        }
        import.remove();
      });
    });
  }
}
