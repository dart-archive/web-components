// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('vm')
library web_components.test.build.script_compactor_test;

import 'package:transformer_test/utils.dart';
import 'package:web_components/build/messages.dart';
import 'package:web_components/build/script_compactor.dart';
import 'package:test/test.dart';

var transformer = new ScriptCompactorTransformer();
var phases = [
  [transformer]
];

main() {
  group('basic', basicTests);
  group('code extraction tests', codeExtractorTests);
  group('fixes import/export/part URIs', dartUriTests);
  group('validates script-tag URIs', validateUriTests);
}

void basicTests() {
  testPhases(
      'single script',
      phases,
      {
        'a|web/index.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="index.dart"></script>
        </body></html>''',
        'a|web/index.dart': '''
        library a.index;
        main(){}''',
      },
      {
        'a|web/index.html': '''
        <!DOCTYPE html><html><head></head><body>
        <script type="application/dart" src="index.bootstrap.dart"></script>
        </body></html>''',
        'a|web/index.bootstrap.dart': '''
        library a.web.index_bootstrap_dart;

        import 'index.dart' as i0;

        main() => i0.main();''',
        'a|web/index.dart': '''
        library a.index;
        main(){}''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'multiple scripts from nested html import',
      phases,
      {
        'a|web/index.html': '''
        <!DOCTYPE html><html>
          <head>
            <link rel="import" href="packages/b/a.html">
          </head>
          <body>
            <script type="application/dart" src="index.dart"></script>
          </body>
        </body></html>''',
        'a|web/index.dart': '''
        library a.index;
        main(){}''',
        'b|lib/a.html': '''
        <link rel="import" href="b/b.html">
        <link rel="import" href="../../packages/c/c.html">
        <script type="application/dart" src="a.dart"></script>''',
        'b|lib/b/b.html':
            '<script type="application/dart" src="b.dart"></script>',
        'b|lib/a.dart': 'library b.a;',
        'b|lib/b/b.dart': 'library b.b.b;',
        'c|lib/c.html':
            '<script type="application/dart" src="c.dart"></script>',
        'c|lib/c.dart': 'library c.c;',
      },
      {
        'a|web/index.html': '''
        <!DOCTYPE html><html>
        <head>
          <link rel="import" href="packages/b/a.html">
        </head>
        <body>
          <script type="application/dart" src="index.bootstrap.dart"></script>
        </body></html>''',
        'a|web/index.bootstrap.dart': '''
        library a.web.index_bootstrap_dart;

        import 'package:b/b/b.dart' as i0;
        import 'package:c/c.dart' as i1;
        import 'package:b/a.dart' as i2;
        import 'index.dart' as i3;

        main() => i3.main();''',
        'b|lib/a.html': '''
        <link rel="import" href="b/b.html">
        <link rel="import" href="../../packages/c/c.html">
        <script type="application/dart" src="a.dart"></script>''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'inline scripts',
      phases,
      {
        'a|web/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <link rel="import" href="packages/a/foo.html">
          </head>
          <body>
            <script type="application/dart">
              library a.index;
              main(){}
            </script>
          </body>
        </html>''',
        'a|lib/foo.html': '''
        <script type="application/dart">
          library a.foo;

          import 'bar.dart';
        </script>''',
      },
      {
        'a|web/index.html': '''
        <!DOCTYPE html>
        <html>
          <head>
            <link rel="import" href="packages/a/foo.html">
          </head>
          <body>
            <script type="application/dart" src="index.bootstrap.dart"></script>
          </body>
        </html>''',
        'a|web/index.html.1.dart': '''
        library a.index;
        main(){}''',
        'a|web/index.html.0.dart': '''
        library a.foo;

        import 'package:a/bar.dart';''',
        'a|web/index.bootstrap.dart': '''
        library a.web.index_bootstrap_dart;

        import 'index.html.0.dart' as i0;
        import 'index.html.1.dart' as i1;

        main() => i1.main();''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'Cleans library names generated from file paths.',
      phases,
      {
        'a|web/01_test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">/*1*/</script>
        </head></html>''',
        'a|web/foo_02_test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">/*2*/</script>
        </head></html>''',
        'a|web/test_03.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">/*3*/</script>
        </head></html>''',
        'a|web/*test_%foo_04!.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">/*4*/</script>
        </head></html>''',
        'a|web/%05_test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">/*5*/</script>
        </head></html>''',
      },
      {
        // Appends an _ if it starts with a number.
        'a|web/01_test.html.0.dart': 'library a.web._01_test_html_0;\n/*1*/',
        // Allows numbers in the middle.
        'a|web/foo_02_test.html.0.dart':
            'library a.web.foo_02_test_html_0;\n/*2*/',
        // Allows numbers at the end.
        'a|web/test_03.html.0.dart': 'library a.web.test_03_html_0;\n/*3*/',
        // Replaces invalid characters with _.
        'a|web/*test_%foo_04!.html.0.dart':
            'library a.web._test__foo_04__html_0;\n/*4*/',
        // Replace invalid character followed by number.
        'a|web/%05_test.html.0.dart': 'library a.web._05_test_html_0;\n/*5*/',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'file names with hyphens are ok',
      phases,
      {
        'a|web/a-b.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="a-b.dart"></script>
        </body></html>''',
        'a|web/a-b.dart': '''
        library a.a_b;
        main(){}''',
      },
      {
        'a|web/a-b.html': '''
        <!DOCTYPE html><html><head></head><body>
        <script type="application/dart" src="a-b.bootstrap.dart"></script>
        </body></html>''',
        'a|web/a-b.bootstrap.dart': '''
        library a.web.a_b_bootstrap_dart;

        import 'a-b.dart' as i0;

        main() => i0.main();''',
        'a|web/a-b.dart': '''
        library a.a_b;
        main(){}''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'package names with hyphens give an error',
      phases,
      {
        'a-b|web/a.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="a.dart"></script>
        </body></html>''',
        'a-b|web/a.dart': '''
        library a.a;
        main(){}''',
      },
      {},
      messages: [
        'error: Invalid package name `a-b`. Package names should be '
            'valid dart identifiers, as indicated at '
            'https://www.dartlang.org/tools/pub/pubspec.html#name.'
      ],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'package names that start with a period are not allowed',
      phases,
      {
        '.a|web/a.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="a.dart"></script>
        </body></html>''',
        '.a|web/a.dart': '''
        library a.a;
        main(){}''',
      },
      {},
      messages: [
        'error: Invalid package name `.a`. Package names should be '
            'valid dart identifiers, as indicated at '
            'https://www.dartlang.org/tools/pub/pubspec.html#name.'
      ],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'package names that end with a period are not allowed',
      phases,
      {
        'a.|web/a.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="a.dart"></script>
        </body></html>''',
        'a.|web/a.dart': '''
        library a.a;
        main(){}''',
      },
      {},
      messages: [
        'error: Invalid package name `a.`. Package names should be '
            'valid dart identifiers, as indicated at '
            'https://www.dartlang.org/tools/pub/pubspec.html#name.'
      ],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'package names with double periods are not allowed',
      phases,
      {
        'a..b|web/a.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="a.dart"></script>
        </body></html>''',
        'a..b|web/a.dart': '''
        library a.a;
        main(){}''',
      },
      {},
      messages: [
        'error: Invalid package name `a..b`. Package names should be '
            'valid dart identifiers, as indicated at '
            'https://www.dartlang.org/tools/pub/pubspec.html#name.'
      ],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'package names with internal periods are allowed',
      phases,
      {
        'a.b|web/a.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="a.dart"></script>
        </body></html>''',
        'a.b|web/a.dart': '''
        library a.b.a;
        main(){}''',
      },
      {
        'a.b|web/a.bootstrap.dart': '''
      library a.b.web.a_bootstrap_dart;

      import 'a.dart' as i0;

      main() => i0.main();''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);
}

void codeExtractorTests() {
  testPhases('no dart script', phases,
      {'a|web/test.html': '<!DOCTYPE html><html></html>',}, {},
      messages: [
        'error: Found either zero or multiple dart scripts in the entry point '
            '`web/test.html`. Exactly one was expected.',
      ],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'single script, no library in script',
      phases,
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">main() { }</script>''',
      },
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <script type="application/dart" src="test.bootstrap.dart">
          </script>
        </head><body></body></html>''',
        'a|web/test.html.0.dart': '''
        library a.web.test_html_0;
        main() { }''',
        'a|web/test.bootstrap.dart': '''
        library a.web.test_bootstrap_dart;

        import 'test.html.0.dart' as i0;

        main() => i0.main();''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'single script, with library',
      phases,
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">
          library f;
          main() { }
        </script>''',
      },
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <script type="application/dart" src="test.bootstrap.dart">
          </script>
        </head><body></body></html>''',
        'a|web/test.html.0.dart': '''
        library f;
        main() { }''',
        'a|web/test.bootstrap.dart': '''
        library a.web.test_bootstrap_dart;

        import 'test.html.0.dart' as i0;

        main() => i0.main();''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'under lib/ directory not transformed',
      phases,
      {
        'a|lib/test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">
          library f;
          main() { }
        </script>''',
      },
      {
        'a|lib/test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">
          library f;
          main() { }
        </script>''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'multiple scripts - error',
      phases,
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
        <script type="application/dart">
            library a1;
            main1() { }
        </script>
        <script type="application/dart">library a2;\nmain2() { }</script>''',
      },
      {},
      messages: [
        'error: Found either zero or multiple dart scripts in the entry point '
            '`web/test.html`. Exactly one was expected.',
      ],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'multiple imported scripts',
      phases,
      {
        'a|web/test.html': '''
        <link rel="import" href="test2.html">
        <link rel="import" href="bar/test.html">
        <link rel="import" href="packages/a/foo/test.html">
        <link rel="import" href="packages/b/test.html">
        <script type="application/dart" src="test.dart"></script>''',
        'a|web/test.dart': 'library a.test;',
        'a|web/test2.html': '<script type="application/dart">main1() { }',
        'a|web/bar/test.html': '<script type="application/dart">main2() { }',
        'a|lib/foo/test.html': '<script type="application/dart">main3() { }',
        'b|lib/test.html': '<script type="application/dart">main4() { }',
      },
      {
        'a|web/test.html': '''
        <html>
          <head>
            <link rel="import" href="test2.html">
            <link rel="import" href="bar/test.html">
            <link rel="import" href="packages/a/foo/test.html">
            <link rel="import" href="packages/b/test.html">
            <script type="application/dart" src="test.bootstrap.dart"></script>
          </head><body></body></html>''',
        'a|web/test.bootstrap.dart': '''
        library a.web.test_bootstrap_dart;
        import 'test.html.0.dart' as i0;
        import 'test.html.1.dart' as i1;
        import 'test.html.2.dart' as i2;
        import 'test.html.3.dart' as i3;
        import 'test.dart' as i4;

        main() => i4.main();
        ''',
        'a|web/test.html.0.dart': '''
        library a.web.test_html_0;
        main1() { }''',
        'a|web/test.html.1.dart': '''
        library a.web.test_html_1;
        main2() { }''',
        'a|web/test.html.2.dart': '''
        library a.web.test_html_2;
        main3() { }''',
        'a|web/test.html.3.dart': '''
        library a.web.test_html_3;
        main4() { }''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);
}

dartUriTests() {
  testPhases(
      'from web folder',
      phases,
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <link rel="import" href="test2/foo.html">
          <script type="application/dart" src="test.dart"></script>
        </head><body></body></html>''',
        'a|web/test.dart': 'library a.test;',
        'a|web/test2/foo.html': '''
      <!DOCTYPE html><html><head></head><body>
      <script type="application/dart">
        import 'package:qux/qux.dart';
        import 'foo.dart';
        export 'bar.dart';
        part 'baz.dart';
      </script>
      </body></html>''',
      },
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <link rel="import" href="test2/foo.html">
          <script type="application/dart" src="test.bootstrap.dart"></script>
        </head><body></body></html>''',
        'a|web/test.html.0.dart': '''
        library a.web.test_html_0;

        import 'package:qux/qux.dart';
        import 'test2/foo.dart';
        export 'test2/bar.dart';
        part 'test2/baz.dart';''',
        'a|web/test2/foo.html': '''
        <!DOCTYPE html><html><head></head><body>
          <script type="application/dart" src="foo.bootstrap.dart">
          </script>
        </body></html>''',
        'a|web/test2/foo.html.0.dart': '''
        library a.web.test2.foo_html_0;

        import 'package:qux/qux.dart';
        import 'foo.dart';
        export 'bar.dart';
        part 'baz.dart';''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'from lib folder',
      phases,
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
        <link rel="import" href="packages/a/test2/foo.html">
        <script type="application/dart" src="test.dart"></script>
        </head><body></body></html>''',
        'a|web/test.dart': 'library a.test;',
        'a|lib/test2/foo.html': '''
        <!DOCTYPE html><html><head></head><body>
        <script type="application/dart">
          import 'package:qux/qux.dart';
          import 'foo.dart';
          export 'bar.dart';
          part 'baz.dart';
        </script>
        </body></html>''',
      },
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <link rel="import" href="packages/a/test2/foo.html">
          <script type="application/dart" src="test.bootstrap.dart"></script>
        </head><body></body></html>''',
        'a|web/test.html.0.dart': '''
        library a.web.test_html_0;

        import 'package:qux/qux.dart';
        import 'package:a/test2/foo.dart';
        export 'package:a/test2/bar.dart';
        part 'package:a/test2/baz.dart';''',
        'a|lib/test2/foo.html': '''
        <!DOCTYPE html><html><head></head><body>
        <script type="application/dart">
          import 'package:qux/qux.dart';
          import 'foo.dart';
          export 'bar.dart';
          part 'baz.dart';
        </script>
        </body></html>''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases(
      'from another pkg',
      phases,
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <link rel="import" href="packages/b/test2/foo.html">
          <script type="application/dart" src="test.dart"></script>
        </head><body></body></html>''',
        'a|web/test.dart': 'library a.test;',
        'b|lib/test2/foo.html': '''
      <!DOCTYPE html><html><head></head><body>
      <script type="application/dart">
      import 'package:qux/qux.dart';
      import 'foo.dart';
      export 'bar.dart';
      part 'baz.dart';
      </script>
      </body></html>''',
      },
      {
        'a|web/test.html': '''
        <!DOCTYPE html><html><head>
          <link rel="import" href="packages/b/test2/foo.html">
          <script type="application/dart" src="test.bootstrap.dart"></script>
        </head><body></body></html>''',
        'a|web/test.html.0.dart': '''
        library a.web.test_html_0;

        import 'package:qux/qux.dart';
        import 'package:b/test2/foo.dart';
        export 'package:b/test2/bar.dart';
        part 'package:b/test2/baz.dart';''',
      },
      messages: [],
      formatter: StringFormatter.noNewlinesOrSurroundingWhitespace);
}

validateUriTests() {
  testPhases('script src is invalid', phases, {
    'a|web/test.html': '''
        <!DOCTYPE html><html><body>
        <script type="application/dart" src="a.dart"></script>
        </body></html>''',
  }, {}, messages: [
    'warning: ${scriptFileNotFound.create({'url': 'a|web/a.dart'}).snippet} '
        '(web/test.html 1 8)',
  ]);
}
