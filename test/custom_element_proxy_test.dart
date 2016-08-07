// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library custom_element_proxy_test;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:test/test.dart';
import 'package:web_components/web_components.dart';

@CustomElementProxy('basic-element')
class BasicElement extends HtmlElement {
  BasicElement.created() : super.created();

  factory BasicElement() => document.createElement('basic-element');

  bool get isBasicElement =>
      new JsObject.fromBrowserObject(this)['isBasicElement'];
}

@CustomElementProxy('extended-element', extendsTag: 'input')
class ExtendedElement extends InputElement {
  ExtendedElement.created() : super.created();

  factory ExtendedElement() =>
      document.createElement('input', 'extended-element');

  bool get isExtendedElement =>
      new JsObject.fromBrowserObject(this)['isExtendedElement'];
}

main() {
  return initWebComponents().then((_) {
    var container = querySelector('#container') as DivElement;

    tearDown(() {
      container.children.clear();
    });

    test('basic custom element', () {
      container.append(new BasicElement());
      container.appendHtml('<basic-element></basic_element>',
          treeSanitizer: nullSanitizer);
      // TODO(jakemac): after appendHtml elements are upgraded asynchronously,
      // why? https://github.com/dart-lang/web-components/issues/4
      return new Future(() {}).then((_) {
        var elements = container.querySelectorAll('basic-element');
        expect(elements.length, 2);
        for (BasicElement element in elements) {
          expect(element.isBasicElement, isTrue);
        }
      });
    });

    test('extends custom element', () {
      container.append(new ExtendedElement());
      container.appendHtml('<input is="extended-element" />',
          treeSanitizer: nullSanitizer);
      // TODO(jakemac): after appendHtml elements are upgraded asynchronously,
      // why? https://github.com/dart-lang/web-components/issues/4
      return new Future(() {}).then((_) {
        var elements = container.querySelectorAll('input');
        expect(elements.length, 2);
        for (ExtendedElement element in elements) {
          expect(element.isExtendedElement, isTrue);
        }
      });
    });
  });
}

class NullTreeSanitizer implements NodeTreeSanitizer {
  const NullTreeSanitizer();
  void sanitizeTree(Node node) {}
}

final nullSanitizer = const NullTreeSanitizer();
