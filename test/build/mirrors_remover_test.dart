// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.build.mirrors_remover_test;

import 'package:code_transformers/tests.dart';
import 'package:web_components/build/mirrors_remover.dart';
import 'package:unittest/compact_vm_config.dart';
import 'package:unittest/unittest.dart';

main() {
  useCompactVMConfiguration();

  var transformer = new MirrorsRemoverTransformer();
  var phases = [[transformer]];

  testPhases('basic', phases, {
    'a|lib/src/init.dart': '''
        libary web_components.init;

        import 'src/mirror_initializer.dart' as init;
        export 'src/mirror_initializer.dart' show deployMode;

        foo() {}
        ''',
  }, {
    'a|lib/src/init.dart': '''
        libary web_components.init;

        import 'src/static_initializer.dart' as init;
        export 'src/static_initializer.dart' show deployMode;

        foo() {}
        ''',
  }, []);
}
