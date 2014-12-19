// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web_components.test.build.import_inliner_test;

import 'dart:async';
import 'package:web_components/build/import_inliner.dart';
import 'package:unittest/compact_vm_config.dart';
import 'package:unittest/unittest.dart';
import 'package:html5lib/parser.dart';
import 'package:html5lib/dom.dart' show Document, Element;

main() {
  useCompactVMConfiguration();

  testInline('basic inlining', '''
      <html>
        <body>
          <link rel="import" href="foo.html">
        </body>
      </html>''', {
        'foo.html': '<div>bar</div>'
      }, '''
      <html>
        <head></head>
        <body>
          <div style="display:none;">
              <div>bar</div>
          </div>
        </body>
      </html>'''
  );
}

class MapImportReader implements ImportReader {
  Map<String, Document> _imports;
  MapImportReader(this._imports);

  Future<Document> readImport(Element import) {
    return new Future.value(_imports[import.attributes['href']]);
  }
}

void testInline(String name, String input, Map<String, String> dependencies,
                String expectedOutput, {String reason}) {
  var inputDoc = parse(input);
  var dependencyDocs = new Map<String, Document>();
  dependencies.forEach((k, v) => dependencyDocs[k] = parse(v));
  var importReader = new MapImportReader(dependencyDocs);
  var importInliner = new ImportInliner(importReader);

  importInliner.inlineImports(inputDoc);

  test(name, () {
    expect(
        inputDoc.outerHtml.replaceAll('  ', '').replaceAll('\n', ''),
        expectedOutput.replaceAll('  ', '').replaceAll('\n', ''),
        reason: reason);
  });
}
