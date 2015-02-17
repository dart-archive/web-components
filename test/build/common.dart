// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.build.common;

// Simple mock of initialize.
const mockInitialize = '''
library initialize;

abstract class Initializer<T> {}

class _InitMethod implements Initializer<Function> {
  const _InitMethod();
}
const _InitMethod initMethod = const _InitMethod();''';

// Simple mock of web_components/lib/html_import_annotation.dart
const mockHtmlImportAnnotation = '''
library web_components.html_import_annotation;

import 'package:initialize/initialize.dart';

class HtmlImport implements Initializer<LibraryIdentifier> {
  final String filePath;

  const HtmlImport(this.filePath);
}''';
