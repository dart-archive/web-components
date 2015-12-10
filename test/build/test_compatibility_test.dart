// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('vm')
library web_components.test.build.test_compatibility_test;

import 'package:code_transformers/tests.dart';
import 'package:web_components/build/test_compatibility.dart';
import 'package:test/test.dart';

var start = new RewriteXDartTestToScript(null);
var end = new RewriteScriptToXDartTest(null);

main() {
  testPhases('can rewrite x-dart-test link tags to script tags', [[start]], {
    'a|test/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <link rel="x-dart-test" href="foo.dart">
          </head>
          <body></body>
        </html>''',
  }, {
    'a|test/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <script type="application/dart" src="foo.dart" $testAttribute="">
            </script>
          </head>
          <body></body>
        </html>''',
  }, [], StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases('can rewrite script tags to x-dart-test link tags', [[end]], {
    'a|test/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <script type="application/dart" src="foo.dart" $testAttribute="">
            </script>
          </head>
          <body></body>
        </html>''',
  }, {
    'a|test/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <link rel="x-dart-test" href="foo.dart">
          </head>
          <body></body>
        </html>''',
  }, [], StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases('restores original application at the end', [[start], [end]], {
    'a|test/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <link rel="x-dart-test" href="foo.dart">
          </head>
          <body></body>
        </html>''',
  }, {
    'a|test/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <link rel="x-dart-test" href="foo.dart">
          </head>
          <body></body>
        </html>''',
  }, [], StringFormatter.noNewlinesOrSurroundingWhitespace);
}
