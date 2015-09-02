// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.test.custom_element_test;

import 'dart:async';
import 'dart:html';
import 'package:unittest/html_config.dart';
import 'package:unittest/unittest.dart';
import 'package:web_components/web_components.dart';

@CustomElement('basic-element')
class BasicElement extends HtmlElement {
  BasicElement.created() : super.created();

  factory BasicElement() => document.createElement('basic-element');
}

@CustomElement('child-element')
class ChildElement extends BasicElement {
  ChildElement.created() : super.created();

  factory ChildElement() => document.createElement('child-element');
}

@CustomElement('extended-element', extendsTag: 'input')
class ExtendedElement extends InputElement {
  ExtendedElement.created() : super.created();

  factory ExtendedElement() =>
      document.createElement('input', 'extended-element');
}

main() {
  useHtmlConfiguration();
  initWebComponents().then((_) {
    var container = querySelector('#container') as DivElement;

    setUp(() {
      return new Future(() {});
    });

    tearDown(() {
      container.children.clear();
    });

    test('basic custom element', () {
      expect(document.querySelector('basic-element') is BasicElement, isTrue);
      container.append(new BasicElement());
      container.appendHtml('<basic-element></basic-element>',
          treeSanitizer: nullSanitizer);
      // elements are upgraded asynchronously
      return new Future(() {}).then((_) {
        var elements = container.querySelectorAll('basic-element');
        expect(elements.length, 2);
        for (var element in elements) {
          expect(element is BasicElement, isTrue);
        }
      });
    });

    test('child custom element', () {
      expect(document.querySelector('child-element') is ChildElement, isTrue);
      container.append(new ChildElement());
      container.appendHtml('<child-element></child-element>',
          treeSanitizer: nullSanitizer);
      // elements are upgraded asynchronously
      return new Future(() {}).then((_) {
        var elements = container.querySelectorAll('child-element');
        expect(elements.length, 2);
        for (var element in elements) {
          expect(element is ChildElement, isTrue);
        }
      });
    });

    test('extends input element', () {
      expect(document.querySelector('input') is ExtendedElement, isTrue);
      container.append(new ExtendedElement());
      container.appendHtml('<input is="extended-element" />',
          treeSanitizer: nullSanitizer);
      // elements are upgraded asynchronously
      return new Future(() {}).then((_) {
        var elements = container.querySelectorAll('input');
        expect(elements.length, 2);
        for (var element in elements) {
          expect(element is ExtendedElement, isTrue);
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
