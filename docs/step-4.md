## Step 4: Polymer custom element

In this step, extend the lexicon of HTML with your own custom element. 
You also specify element-defined style and expose an custom element attribute.

_**Keywords**: polymer, custom element, template, custom attribute, binding_


### Bootstrap Polymer

Edit `web/index.html`, as follows.

```HTML
<html>
  <head>
    <!-- ... -->

    <!-- Polymer bootstrap -->
    <script type="application/dart">export 'package:polymer/init.dart';</script>
    <script src="packages/browser/dart.js"></script>
  </head>
  <body>
```

Key information:
* The first `<script>` tag automatically initializes polymer elements without 
  having to write a main for your application.
* The `packages/browser/dart.js` script checks for native Dart support and
  either bootstraps the Dart VM or loads compiled JavaScript instead.
* When run in browser, the `index.html` file loads the app and calls the `main()` function in `package:polymer/init.dart` script.

### Add a basic custom element

Continue to edit `web/index.html`.

&rarr; Declare a custom element named `hello-world`.

```HTML
<html>
  <!-- ... -->
  <body>
    <!-- Declare a custom element named hello-world -->
    <polymer-element name="hello-world" noscript>
      <template>
        <h3>Hello World!</h3>
      </template>
    </polymer-element>
```

&rarr; Use it twice in the HTML code.

```HTML
<body>
  <!-- ... -->

  <div>
    TO DO: Put the UI widgets here.
    <!-- Use the hello-world custom element -->
    <hello-world></hello-world>
    <hello-world></hello-world>
  </div>
</body>
```

&rarr; Run in Dartium `web/index.html`.

You should see twice _"Hello World!"_.

**Got questions? Having trouble?** Ask the organizer team.

Key information:
* The `polymer-element` tag is the way to declare your custom element.
* The `name`  attribute is required and **must** contain a `-`. 
  It specifies the name of the HTML tag you’ll instantiate in markup 
  (in this case `<hello-world>`).
* The `noscript` attribute indicates that this is a simple element 
  that doesn’t include any script. An element declared with noscript 
  is registered automatically.
* The `template` tag contains the content of the element. For now,
  it's static content.

### Add element-defined styles

To add element-defined styles, edit the element in `web/index.html`.

&rarr; Add the following code to declare style:

```HTML
<polymer-element name="hello-world" noscript>
  <template>
    <style>
      :host {
        text-align: center;
      }

      h3 {
        text-decoration: underline;
      }
    </style>
    <h3>Hello World!</h3>
  </template>
</polymer-element>
```

&rarr; Run in Dartium

You should see centered and underlined _"Hello World!"_.

&rarr; Try to affect the style of the element adding other styles outside of it.

```HTML
<html>
  <head>
    <style>
      hello-world {
        text-align: right;
      }
      h3 {
        color: red;
      }
    </style>
  </head>
```

Key information:
* `:host` refers to the custom element itself and has the lowest specificity. This allows users to override your styling from the outside.
* Polymer creates _Shadow DOM_ from the topmost <template> of your <polymer-element> definition, so styles defined internally to your element are scoped to your element. There’s no need to worry about duplicating an id from the outside or using a styling rule that’s too broad.

### Externalize element

Create a new file `web/hello.html`.

&rarr; Move the element declaration from `web/index.html` to `web/hello.html`:

```HTML
<!DOCTYPE html>

<polymer-element name="hello-world" noscript>
  <template>
    <style>
      /* ... */
    </style>
    <h3>Hello World!</h3>
  </template>
</polymer-element>
```

&rarr; Import the element with an [HTML Import](http://www.polymer-project.org/platform/html-imports.html).

```HTML
<html>
  <head>
    <!-- ... -->

    <link rel="import" href="hello.html">

    <script type="application/dart">export 'package:polymer/init.dart';</script>
    <script src="packages/browser/dart.js"></script>
  </head>
  <body>
    <!-- Previous hello-world element declaration is removed -->

    <!-- ... -->

    <div>
      TO DO: Put the UI widgets here.
      <!-- Use the hello-world custom element -->
      <hello-world></hello-world>
      <hello-world></hello-world>
    </div>
  </body>
</html>
```

Key information:
* HTML Imports are a way to include and reuse HTML documents in other HTML documents.
* For HTML imports use the `import` relation on a standard `<link>` tag.

### Add custom behavior

Create a new file `web/hello.dart`.

&rarr; Add the following code:

```Dart
import 'package:polymer/polymer.dart';

@CustomTag('hello-world')
class HelloWorld extends PolymerElement {
  String name = "You";

  HelloWorld.created(): super.created();
}
```

&rarr; In `web/hello.html`, remove the `noscript` attribute.  
&rarr; Add the `script` tag specifying the URL to `hello.dart`.  
&rarr; Add the binding to the field `name` of `HelloWorld` class:

```HTML
<!DOCTYPE html>

<polymer-element name="hello-world">
  <template>
    ...
    <h3>Hello {{name}}!</h3>
  </template>
  <script type="application/dart" src="hello.dart"></script>
</polymer-element>
```

&rarr; Run in Dartium

You should see _"Hello You!"_.

Key information:
* The `script` tag specifies the path to the underlying dart script.
* Any Polymer element class extends `PolymerElement`.
* `CustomTag` specifies the name of the element.
* The `super.created()` constructor must be called in the custom element constructor.
* `{{name}}` is a Polymer expression. It is bound to the `name` field in `HelloWorld` class.

### Add custom attribute

Attributes are a great way for users of your element to configure it, declaratively.

&rarr; In `web/hello.dart`, add the `@published` annotation to the `name` field:

```Dart
class HelloWorld extends PolymerElement {
  @published
  String name = "You";
  // ...
}
```

&rarr; In `web/index.html`, take advantage of the new attribute:

```HTML
<html>
  <body>
    <!-- ... -->

    <div>
      TO DO: Put the UI widgets here.
      <hello-world name="John"></hello-world>
      <hello-world name="Paul"></hello-world>
    </div>
  </body>
</html>
```

&rarr; Run in Dartium

You should see _"Hello John!"_ and _"Hello Paul!"_.

Key information:
* `@published` means that is is an public attribute.
* `@published` also means that it is observable, so it allows to uses live two-way data binding to synchronize DOM nodes and object models.

### Learn more
 - [Polymer.dart](https://www.dartlang.org/polymer-dart/)
 - [Polymer project](http://www.polymer-project.org/)
 - [A Guide to Styling Elements](http://www.polymer-project.org/articles/styling-elements.html)

### Problems?
Check your code against the files in [s4_element](../samples/s4_element).

## [Home](../README.md) | [< Previous](step-3.md) | [Next >](step-5.md)
