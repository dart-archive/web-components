// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
@HtmlImport(importPath)
library web_components.test.html_import_annotation;

import 'dart:html';
import 'package:test/test.dart';
import 'package:web_components/web_components.dart';
import 'foo/bar.dart' as foo_bar;

const String importPath = 'my_import.html';

/// Uses [foo_bar].
main() async {
  await initWebComponents();

  test('adds import to head', () {
    var my_import = document.head.querySelector('link[href="$importPath"]');
    expect(my_import, isNotNull);
    expect(my_import.import.body.text, 'Hello world!\n');

    var bar = document.head.querySelector('link[href="foo/bar.html"]');
    expect(bar, isNotNull);
    expect(bar.import.body.text, 'bar\n');
  });
}
