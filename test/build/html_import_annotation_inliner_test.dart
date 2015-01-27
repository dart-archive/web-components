// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.build.html_import_annotation_inliner_test;

import 'common.dart';
import 'package:web_components/build/html_import_annotation_inliner.dart';
import 'package:unittest/compact_vm_config.dart';

main() {
  useCompactVMConfiguration();

  var transformer = new HtmlImportAnnotationInliner(
      'web/index.bootstrap.dart', 'web/index.html');

  testPhases('basic', [[transformer]], {
    'foo|web/index.html': '''
        <html><head></head><body>
          <script type="application/dart" src="index.bootstrap.dart"></script>
        </body></html>
        '''.replaceAll('        ', ''),
    'foo|web/index.bootstrap.dart': '''
        import 'package:initialize/src/static_loader.dart';
        import 'package:initialize/src/initializer.dart';
        import 'index.dart' as i0;
        import 'package:web_components/html_import_annotation.dart' as i1;
        import 'package:baz/baz.dart' as i2;

        main() {
          initializers.addAll([
            new InitEntry(const i2.initMethod, i0.baz),
            new InitEntry(const i1.HtmlImport('foo.html'), const LibraryIdentifier(#foo, null, 'web/foo.dart')),
            new InitEntry(const i1.HtmlImport('foo.html'), const LibraryIdentifier(#foo, null, 'web/foo/foo.dart')),
            new InitEntry(const i1.HtmlImport('foo.html'), const LibraryIdentifier(#foo, null, 'lib/foo.dart')),
            new InitEntry(const i1.HtmlImport('foo.html'), const LibraryIdentifier(#foo, null, 'lib/foo/foo.dart')),
            new InitEntry(const i1.HtmlImport('../foo.html'), const LibraryIdentifier(#foo, null, 'lib/foo/foo.dart')),
            new InitEntry(const i1.HtmlImport('package:foo/foo.html'), const LibraryIdentifier(#foo, null, 'lib/foo.dart')),
            new InitEntry(const i1.HtmlImport('package:foo/foo/foo.html'), const LibraryIdentifier(#foo, null, 'lib/foo/foo.dart')),
            new InitEntry(const i1.HtmlImport('bar.html'), const LibraryIdentifier(#bar, 'bar', 'lib/bar.dart')),
            new InitEntry(const i1.HtmlImport('bar.html'), const LibraryIdentifier(#bar.Bar, 'bar', 'lib/bar/bar.dart')),
            new InitEntry(const i1.HtmlImport('package:bar/bar.html'), const LibraryIdentifier(#bar, 'bar', 'lib/bar.dart')),
            new InitEntry(const i1.HtmlImport('package:bar/bar/bar.html'), const LibraryIdentifier(#bar.Bar, 'bar', 'lib/bar/bar.dart')),
          ]);

          i0.main();
        }
        ''',
  }, {
    'foo|web/index.html': '''
        <html><head><link rel="import" href="foo.html"><link rel="import" href="foo/foo.html"><link rel="import" href="packages/foo/foo.html"><link rel="import" href="packages/foo/foo/foo.html"><link rel="import" href="packages/bar/bar.html"><link rel="import" href="packages/bar/bar/bar.html"></head><body>
          <script type="application/dart" src="index.bootstrap.dart"></script>

        </body></html>'''.replaceAll('        ', ''),
    'foo|web/index.bootstrap.dart': '''
        import 'package:initialize/src/static_loader.dart';
        import 'package:initialize/src/initializer.dart';
        import 'index.dart' as i0;
        import 'package:web_components/html_import_annotation.dart' as i1;
        import 'package:baz/baz.dart' as i2;

        main() {
          initializers.addAll([
            new InitEntry(const i2.initMethod, i0.baz),
          ]);

          i0.main();
        }
        '''
  }, []);
}
