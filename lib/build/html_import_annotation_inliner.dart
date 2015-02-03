// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library web_components.build.html_import_annotation_inliner;

import 'dart:async';
import 'package:analyzer/analyzer.dart';
import 'package:barback/barback.dart';
import 'package:html5lib/dom.dart' as dom;
import 'package:html5lib/parser.dart';
import 'package:initialize/plugin_transformer.dart';
import 'package:source_maps/refactor.dart';
import '../src/normalize_path.dart';

/// Given an html entry point with a single dart bootstrap file created by the
/// `initialize` transformer, this will open that dart file and remove all
/// `HtmlImport` initializers from it. Then it appends those imports to the head
/// of the html entry point.
/// Notes: Does not inline the import, it just puts the <link rel="import"> tag.
/// This also has a few limitations, it only supports string literals (to avoid
/// using the analyzer to resolve references) and doesn't support const
/// references to HtmlImport annotations (for the same reason).
class HtmlImportAnnotationInliner extends InitializePluginTransformer {
  final String _bootstrapFile;
  final String _htmlEntryPoint;
  TransformLogger _logger;
  final Set<String> importPaths = new Set();

  HtmlImportAnnotationInliner(String bootstrapFile, this._htmlEntryPoint)
      : super(bootstrapFile),
        _bootstrapFile = bootstrapFile;

  factory HtmlImportAnnotationInliner.asPlugin(BarbackSettings settings) {
    var bootstrapFile = settings.configuration['bootstrap_file'];
    if (bootstrapFile is! String || !bootstrapFile.endsWith('.dart')) {
      throw new ArgumentError(
          '`bootstrap_file` should be a string path to a dart file');
    }
    var htmlEntryPoint = settings.configuration['html_entry_point'];
    if (htmlEntryPoint is! String || !htmlEntryPoint.endsWith('.html')) {
      throw new ArgumentError(
          '`html_entry_point` should be a string path to an html file');
    }
    return new HtmlImportAnnotationInliner(bootstrapFile, htmlEntryPoint);
  }

  classifyPrimary(AssetId id) {
    var superValue = super.classifyPrimary(id);
    if (superValue != null) return superValue;
    // Group it with the bootstrap file.
    if (_htmlEntryPoint == id.path) return _bootstrapFile;
    return null;
  }

  apply(AggregateTransform transform) {
    _logger = transform.logger;
    return super.apply(transform).then((_) {
      var htmlEntryPoint =
          allAssets.firstWhere((asset) => asset.id.path == _htmlEntryPoint);
      return htmlEntryPoint.readAsString().then((html) {
        var doc = parse(html);
        for (var importPath in importPaths) {
          var import = new dom.Element.tag('link')
            ..attributes = {'rel': 'import', 'href': importPath,};
          doc.head.append(import);
        }
        transform
            .addOutput(new Asset.fromString(htmlEntryPoint.id, doc.outerHtml));
      });
    });
  }

  // Executed for each initializer constructor in the bootstrap file. We filter
  // out the HtmlImport ones and inline them.
  initEntry(
      InstanceCreationExpression expression, TextEditTransaction transaction) {
    // Filter out extraneous values.
    if (expression is! InstanceCreationExpression) return;
    var args = expression.argumentList.arguments;
    // Only support InstanceCreationExpressions. Const references to HtmlImport
    // annotations can't be cheaply discovered.
    if (args[0] is! InstanceCreationExpression) return;
    if (!'${args[0].constructorName.type.name}'.contains('.HtmlImport')) return;

    // Grab the raw path supplied to the HtmlImport. Only string literals are
    // supported for the transformer.
    var originalPath = args[0].argumentList.arguments[0];
    if (originalPath is SimpleStringLiteral) {
      originalPath = originalPath.value;
    } else {
      _logger.warning('Found HtmlImport constructor which was supplied an '
          'expression. Only raw strings are currently supported for the '
          'transformer, so $originalPath will be injected dynamically');
      return;
    }

    // Now grab the package from the LibraryIdentifier, we know its either a
    // string or null literal.
    var package = args[1].argumentList.arguments[1];
    if (package is SimpleStringLiteral) {
      package = package.value;
    } else if (package is NullLiteral) {
      package = null;
    } else {
      _logger.error('Invalid LibraryIdentifier declaration. The 2nd argument '
          'be a literal string or null. `${args[1]}`');
    }

    // And finally get the original dart file path, this is always a string
    // literal.
    var dartPath = args[1].argumentList.arguments[2];
    if (dartPath is SimpleStringLiteral) {
      dartPath = dartPath.value;
    } else {
      _logger.error('Invalid LibraryIdentifier declaration. The 3rd argument '
          'be a literal string. `${args[1]}`');
    }

    // Add the normalized path to our list and remove the expression from the
    // bootstrap file.
    importPaths.add(normalizeHtmlImportPath(originalPath, package, dartPath));
    removeInitializer(expression, transaction);
  }
}
