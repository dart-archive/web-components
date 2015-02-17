// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.build.import_crawler_test;

import 'package:barback/barback.dart';
import 'package:code_transformers/tests.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:web_components/build/import_crawler.dart';
import 'package:unittest/compact_vm_config.dart';

class _TestTransformer extends Transformer {
  final String _entryPoint;
  Map<AssetId, ImportData> documents;

  _TestTransformer(this._entryPoint);

  isPrimary(AssetId id) => id.path == _entryPoint;

  apply(Transform transform) {
    var primaryInput = transform.primaryInput;
    var logger = new BuildLogger(transform, primaryId: primaryInput.id);
    var crawler = new ImportCrawler(transform, primaryInput.id, logger);
    return crawler.crawlImports().then((docs) {
      documents = docs;
      transform.addOutput(new Asset.fromString(
          new AssetId('a', 'web/result.txt'), '${documents.keys}'));
    });
  }
}

main() {
  useCompactVMConfiguration();

  testPhases('basic', [[new _TestTransformer('web/index.html')]], {
    'a|web/index.html': '''
      <link rel="import" href="foo.html">
      <link rel="import" href="packages/a/foo.html">
      <link rel="import" href="packages/b/foo.html">
      <link rel="import" href="packages/b/foo/bar.html">
      <div>a|web/index.html</div>
      ''',
    'a|web/foo.html': '<div>a|web/foo.html</div>',
    'a|lib/foo.html': '<div>a|lib/foo.html</div>',
    'b|lib/foo.html': '''
      <link rel="import" href="foo/bar.html">
      <div>b|lib/foo.html</div>
      ''',
    'b|lib/foo/bar.html': '<div>b|lib/foo/bar.html</div>',
  }, {
    'a|web/result.txt': '''
      (a|web/foo.html, a|lib/foo.html, b|lib/foo/bar.html, b|lib/foo.html, a|web/index.html)
      ''',
  }, [], StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases('cycle', [[new _TestTransformer('web/index.html')]], {
    'a|web/index.html': '''
      <link rel="import" href="packages/a/foo.html">
      <div>a|web/index.html</div>
      ''',
    'a|lib/foo.html': '''
      <link rel="import" href="bar.html">
      <div>a|lib/foo.html</div>''',
    'a|lib/bar.html': '''
      <link rel="import" href="foo.html">
      <div>a|lib/bar.html</div>''',
  }, {
    'a|web/result.txt': '''
      (a|lib/bar.html, a|lib/foo.html, a|web/index.html)
      ''',
  }, [], StringFormatter.noNewlinesOrSurroundingWhitespace);

  testPhases('deep imports', [[new _TestTransformer('web/index.html')]], {
    'a|web/index.html': '''
      <link rel="import" href="packages/a/foo.html">
      <div>a|web/index.html</div>
      ''',
    'a|lib/foo.html': '''
      <link rel="import" href="one/bar.html">
      <div>a|lib/foo.html</div>''',
    'a|lib/one/bar.html': '''
      <link rel="import" href="two/baz.html">
      <div>a|lib/one/bar.html</div>''',
    'a|lib/one/two/baz.html': '''
      <link rel="import" href="three/zap.html">
      <div>a|lib/one/two/baz.html</div>''',
    'a|lib/one/two/three/zap.html': '''
      <div>a|lib/one/two/three/zap.html</div>''',
  }, {
    'a|web/result.txt':
        '(a|lib/one/two/three/zap.html, a|lib/one/two/baz.html, '
        'a|lib/one/bar.html, a|lib/foo.html, a|web/index.html)',
  }, [], StringFormatter.noNewlinesOrSurroundingWhitespace);
}
