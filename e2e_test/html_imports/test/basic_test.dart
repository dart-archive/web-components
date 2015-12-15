// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
@HtmlImport('packages/html_imports/theme.html')
library e2e_test.html_imports.basic_test;

import 'dart:html';
import 'package:initialize/initialize.dart' as init;
import 'package:web_components/html_import_annotation.dart';
import 'package:test/test.dart';

main() async {
  // Waits until all html imports are loaded.
  await init.run();

  test('text is red', () {
    var p = document.createElement('p');
    document.body.append(p);
    expect(p.getComputedStyle().color, 'rgb(255, 0, 0)');
  });
}
