// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.build.html_import_annotation_recorder_test;

import 'package:code_transformers/tests.dart' hide testPhases;
import 'package:web_components/build/html_import_annotation_recorder.dart';
import 'package:initialize/transformer.dart';
import 'package:unittest/compact_vm_config.dart';
import 'package:unittest/unittest.dart';
import 'common.dart';

testPhases(String name, Map<String, String> inputs,
    Map<String, String> expected, List<String> expectedPaths) {
  var plugin = new HtmlImportAnnotationRecorder();
  var transformer =
      new InitializeTransformer(['web/index.dart'], plugins: [plugin]);

  test(name, () {
    // Run the transformer and test the output.
    return applyTransformers([[transformer]],
        inputs: inputs,
        results: expected,
        formatter: StringFormatter.noNewlinesOrSurroundingWhitespace).then((_) {
      // Check that we recorded the right html imports.
      expect(plugin.importPaths, expectedPaths);
    });
  });
}

main() {
  useCompactVMConfiguration();

  testPhases('basic', {
    'a|web/index.dart': '''
        @HtmlImport('index.html')
        library index;

        import 'package:web_components/html_import_annotation.dart';
        import 'foo.dart';
        ''',
    'a|web/foo.dart': '''
        @HtmlImport(fooHtml)
        library foo;

        import 'package:initialize/initialize.dart';
        import 'package:web_components/html_import_annotation.dart';
        import 'package:bar/bar.dart';

        const String fooHtml = 'foo.html';

        @initMethod
        foo() {}
        ''',
    'bar|lib/bar.dart': '''
        @HtmlImport(barHtml)
        library bar;

        import 'package:initialize/initialize.dart';
        import 'package:web_components/html_import_annotation.dart';
        import 'src/zap.dart';

        const String barHtml = 'bar.html';

        @initMethod
        bar() {}
        ''',
    'bar|lib/src/zap.dart': '''
        @zapImport
        library bar.src.zap;

        import 'package:web_components/html_import_annotation.dart';

        const zapImport = const HtmlImport('zap.html');
        ''',
    // Mock out the Initialize package plus some initializers.
    'initialize|lib/initialize.dart': mockInitialize,
    'web_components|lib/html_import_annotation.dart': mockHtmlImportAnnotation,
  }, {
    'a|web/index.initialize.dart': '''
        import 'package:initialize/src/static_loader.dart';
        import 'package:initialize/initialize.dart';
        import 'index.dart' as i0;
        import 'package:bar/src/zap.dart' as i1;
        import 'package:bar/bar.dart' as i2;
        import 'package:web_components/html_import_annotation.dart' as i3;
        import 'package:initialize/initialize.dart' as i4;
        import 'foo.dart' as i5;

        main() {
          initializers.addAll([
            new InitEntry(i4.initMethod, i2.bar),
            new InitEntry(i4.initMethod, i5.foo),
          ]);

          i0.main();
        }
        '''
  }, [
    'packages/bar/src/zap.html',
    'packages/bar/bar.html',
    'foo.html',
    'index.html',
  ]);
}
