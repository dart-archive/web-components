// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.build.common;

import 'package:barback/barback.dart';
import 'package:code_transformers/src/test_harness.dart';
import 'package:unittest/unittest.dart';

testPhases(String testName, List<List<Transformer>> phases,
    Map<String, String> inputFiles, Map<String, String> expectedFiles,
    [List<String> expectedMessages]) {
  test(testName, () {
    var helper = new TestHelper(phases, inputFiles, expectedMessages)..run();
    return helper.checkAll(expectedFiles).whenComplete(() => helper.tearDown());
  });
}
