#### 0.12.5
  * Update to not use deprecated analyzer apis.
  * Update analyzer minimum version to 0.27.1.

#### 0.12.4
  * Update to JS version
    [0.7.23](https://github.com/webcomponents/webcomponentsjs/tree/v0.7.23).
  * Update `analyzer`, `code_transformers`, and `html` version constraints.

#### 0.12.3
  * Update to JS version
    [0.7.21](https://github.com/webcomponents/webcomponentsjs/tree/v0.7.21).

#### 0.12.2+2

* Update to transformer_test `0.2.x`.

#### 0.12.2+2

* Add support for code_transformers `0.4.x`.

#### 0.12.2+1
  * Allow periods in package names (but can't end or begin with one).

#### 0.12.2
  * Update to JS version
    [0.7.20](https://github.com/webcomponents/webcomponentsjs/tree/v0.7.20).

#### 0.12.1
  * Update analyzer to `^0.27.0` and update to the test package.

#### 0.12.0+4
  * The transformer will now give an informative error on package names with
    hyphens.

#### 0.12.0+3
  * Update analyzer dependency to `<0.27.0` and fix up some tests.

#### 0.12.0+2
  * Don't create new resolvers each time the transformer runs on a file.

#### 0.12.0+1
  * Fix hang on reload with the `web_components` transformer in pub serve,
    [27](https://github.com/dart-lang/web-components/issues/27).

#### 0.12.0
  * Update to js version
    [0.7.3](https://github.com/webcomponents/webcomponentsjs/tree/v0.7.3).
  * Some release notes
    (here)[http://webcomponents.org/articles/polyfills-0-6-0/].
  * Also added all the individual polyfills as well as the
    `webcomponents-lite.js` version, which does not include shadow dom.

#### 0.11.4+2
  * Don't inline type="css" imports.

#### 0.11.4+1
  * Fix erroneous messages about invalid package paths in html imports
    [72](https://github.com/dart-lang/polymer-dart/issues/72).

#### 0.11.4
  * Update to analyzer `<0.26.0`.

#### 0.11.3+1
  * Fix bootstrap to return the result of the original main.

#### 0.11.3
  * Add support for the new `link[rel="x-dart-test"]` tags from the `test`
    package to the transformer.

#### 0.11.2
  * Copied `DomProxyMixin` from `custom_element_apigen` to this package and
    renamed it `CustomElementProxyMixin`. This can be mixed into any class that
    is using the `@CustomElementProxy` annotation and provides easy access to
    the underlying javascript element via the `jsElement` getter. For instance
    the following is a simple example of a dart class that wraps a custom
    javascript element `foo-element` with a method `doFoo` and a property `foo`.

        @CustomElementProxy('foo-element')
        class FooElement extends HtmlElement with CustomElementProxyMixin {
          FooElement.created() : super.created();

          void doFoo(int arg1) => jsElement.callMethod('doFoo', [arg1]);

          int get foo => jsElement['foo'];
          void set foo(int newFoo) {
            jsElement['foo'] = newFoo;
          }
        }

#### 0.11.1+3
  * Switch `html5lib` package dependency to `html`.

#### 0.11.1+2
  * Added a runtime warning about bad packages paths in html imports to
    `initWebComponents`.

#### 0.11.1+1
  * fixes unknown HTML elements if using interop_support.js

#### 0.11.1
  * Added `initWebComponents` function which performs html import aware
    initialization of an application. This is done by crawling all imported
    documents for dart script tags and initializing them. Any applications using
    this package should switch to this method instead of calling `run` from the
    `initialize` package directly.
  * You may also now just export `package:web_components/init.dart` to
    initialize your app, and then stick your startup code inside a method marked
    with `@initMethod`, for instance:

        library my_app;
        export 'package:web_components/init.dart';

        @initMethod
        void startup() {
          // custom app code here.
        }

#### 0.11.0
  * Add `bindingStartDelimiters` option to the `ImportInlinerTransformer`. Any
    urls which contain any of the supplied delimiters before the first `/` will
    be left alone since they can't be reasoned about. If you want these urls to
    be treated as relative to the current path you should add a `./` in front.
  * The `ScriptCompactorTransformer` now names its bootstrap file based on the
    entry point html file, instead of the original dart file. This is ensure it
    is the original package.

#### 0.10.5+3
  * Fix normalization of relative paths inside of deep relative imports,
    https://github.com/dart-lang/polymer-dart/issues/30.
  * Update analyzer and code_transformers versions and use new mock sdk from
    code_transformers.

#### 0.10.5+2
  * Append html imports in front of the dart script tag, if one exists in
    `document.head`.

#### 0.10.5+1
  * Fix @HtmlImport with relative paths from within folders in deployment mode.

#### 0.10.5
  * Update `ImportCrawler` with support for pre-parsed initial documents. This
    allows it to work better with other transformers in the same step (you can
    pass in a modified document).

#### 0.10.4+2
  * Fix `@CustomElement` test in internet explorer.

#### 0.10.4+1
  * Update `initialize` lower bound to get bug fixes.
  * Make sure to always use `path.url` in transformers.

#### 0.10.4
  * Added `CustomElement` annotation. This can be added to any class to register
    it with a tag in the main document.
  * Added a `web_components.dart` file which exports all the annotations
    provided by this package. Note that in later breaking releases
    `html_import_annotation.dart` and `custom_element_proxy.dart` will likely
    move into the `src` folder, so switching to the `web_components.dart` import
    is recommended.

#### 0.10.3
  * Added `generateWebComponentsBootstrap` method to the main `web_components`
    transformer file which accepts a `Transform` and a `Resolver`. You can use
    this function from any transformer and share the resolver you already have.
  * Fixed up the bootstrap call in `ScriptCompactor` to not use `=>` syntax
    since it has a declared return type of `void`. This could previously cause
    a checked mode error if the original program returned something from `main`.

#### 0.10.2+1
  * Minor cleanup to changelog and tests.
  * ImportInliner now throws warnings instead of errors.

#### 0.10.2
  * Added the `HtmlImport` annotation. This can be added to any library
    declaration and it will inject an html import to the specified path into the
    head of the current document, which allows dart files to declare their html
    dependencies. Paths can be relative to the current dart file or they can be
    in `package:` form.

    *Note*: Html imports included this way cannot contain dart script tags. The
    mirror based implementation injects the imports dynamically and dart script
    tags are not allowed to be injected in that way.

    *Note*:  Relative urls cannot be used in inlined script tags. Either move
    the script code to a Dart file, use a `package:` url, or use a normal HTML
    import. See https://github.com/dart-lang/web-components/issues/6.

  * Added a `web_components` transformer. This should be used in place of the
    `initialize` transformer if that already exists in your application (it will
    call that transformer). This will inline html imports (including @HtmlImport
    annotations) into the head of your document at compile time, it can be used
    like this:

        transformers:
        - web_components:
            entry_points:
              - web/index.html

    If no `entry_points` option is supplied then any html file under `web` or
    `test` will be treated as an entry point.

#### 0.10.1
  * Added the `CustomElementProxy` annotation. This can be added to any class
    which proxies a javascript custom element and is the equivalent of calling
    `registerDartType`. In order to use this you will need to be using the
    `initialize` package, and call its `run` method from your main function. It
    is also recommended that you include the transformer from that package to
    remove the use of mirrors at runtime, see
    [initialize](https://github.com/dart-lang/initialize) for more information.

#### 0.10.0
  * Updated to the `0.5.1` js version.
  * **Breaking Change** To remain consistent with the js repository all the
    `platform.js` has been replaced with `webcomponents.js`. Also, the default
    file is now unminified, and the minified version is called
    `webcomponents.min.js`.

#### 0.9.0+1
  * Remove all `.map` and `.concat.js` files during release mode.

#### 0.9.0
  * Updated to platform version 0.4.2, internally a deprecated API was removed,
    hence the bump in the version number.

  * split dart_support.js in two. dart_support.js only contains what is
    necessary in order to use platform.js,
    interop_support.js/interop_support.html can be imported separately when
    providing Dart APIs for js custom elements.

#### 0.8.0
  * Re-apply changes from 0.7.1+1 and also cherry pick
    [efdbbc](https://github.com/polymer/CustomElements/commit/efdbbc) to fix
    the customElementsTakeRecords function.
  * **Breaking Change** The customElementsTakeRecords function now has an
    an optional argument `node`. There is no longer a single global observer,
    but one for each ShadowRoot and one for the main document. The observer that
    is actually used defaults to the main document, but if `node` is supplied
    then it will walk up the document tree and use the first observer that it
    finds.

#### 0.7.1+2
  * Revert the change from 0.7.1+1 due to redness in FF/Safari/IE.

#### 0.7.1+1
  * Cherry pick [f280d](https://github.com/Polymer/ShadowDOM/commit/f280d) and
    [165c3](https://github.com/Polymer/CustomElements/commit/165c3) to fix
    memory leaks.

#### 0.7.1
  * Update to platform version 0.4.1-d214582.

#### 0.7.0+1
  * Cherry pick https://github.com/Polymer/ShadowDOM/pull/506 to fix IOS 8.

#### 0.7.0
  * Updated to 0.4.0-5a7353d release, with same cherry pick as 0.6.0+1.
  * Many features were moved into the polymer package, this package is now
    purely focused on polyfills.
  * Change Platform.deliverDeclarations to
    Platform.consumeDeclarations(callback).
  * Cherry pick https://github.com/Polymer/ShadowDOM/pull/505 to fix mem leak.

#### 0.6.0+1
  * Cherry pick https://github.com/Polymer/ShadowDOM/pull/500 to fix
    http://dartbug.com/20141. Fixes getDefaultComputedStyle in firefox.

#### 0.6.0
  * Upgrades to platform master as of 8/25/2014 (see lib/build.log for details).
    This is more recent than the 0.3.5 release as there were multiple breakages
    that required updating past that.
  * There is a bug in this version where selecting non-rendered elements doesn't
    work, but it shouldn't affect most people. See
    https://github.com/Polymer/ShadowDOM/issues/495.

#### 0.5.0+1
  * Backward compatible change to prepare for upcoming change of the user agent
    in Dartium.

#### 0.5.0
  * Upgrades to platform version 0.3.4-02a0f66 (see lib/build.log for details).

#### 0.4.0
  * Adds `registerDartType` and updates to platform 0.3.3-29065bc
    (re-applies the changes in 0.3.5).

#### 0.3.5+1
  * Reverts back to what we had in 0.3.4. (The platform.js updates in 0.3.5 had
    breaking changes so we are republishing it in 0.4.0)

#### 0.3.5
  * Added `registerDartType` to register a Dart API for a custom-element written
    in Javascript.
  * Updated to platform 0.3.3-29065bc

#### 0.3.4
  * Updated to platform 0.2.4 (see lib/build.log for details)
