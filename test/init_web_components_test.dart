// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@initializeTracker
@TestOn('browser')
library web_components.test.init_web_components_test;

import 'package:test/test.dart';
import 'package:initialize/initialize.dart' show LibraryIdentifier;
import 'package:initialize/src/initialize_tracker.dart';
import 'package:web_components/web_components.dart';

const String importPath = 'my_import.html';

main() {
  test('can initialize scripts from html imports', () {
    return initWebComponents().then((_) {
      var expectedInitializers = [
        const LibraryIdentifier(
            #web_components.test.deps.b, null, 'deps/b.dart'),
        // This one changes based on deploy mode because its an inline script.
        const LibraryIdentifier(
            #web_components.test.deps.c,
            null,
            deployMode
                ? 'init_web_components_test.html.0.dart'
                : 'deps/c.html'),
        const LibraryIdentifier(
            #web_components.test.deps.a, null, 'deps/a.dart'),
        const LibraryIdentifier(#web_components.test.init_web_components_test,
            null, 'init_web_components_test.dart'),
      ];
      expect(InitializeTracker.seen, expectedInitializers);
    });
  });
}
