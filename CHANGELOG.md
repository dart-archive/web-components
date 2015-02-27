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
