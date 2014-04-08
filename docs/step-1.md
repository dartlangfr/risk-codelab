## Step 1: Run the app, and view its code

In this step, you open the source files for the first version of the
app under `risk-codelab-master`.
After familiarizing yourself with the app's code,
you run the app.

_**Keywords**: main, pub, Dartium, Polymer_


### Use Dart Editor to open the server app's directories

&rarr;  In Dart Editor, use **File > Open Existing Folder...**
to open the directory `risk-codelab-master/samples/s1-basics`.

&rarr;  Open the `bin` directory by
clicking the little arrow ► to the left of its name.

&rarr;  Open the `web` directory by
clicking the little arrow ► to the left of its name.

![Each step has its own pubspec.* files, defining the app's dependencies; a packages directory appears; the final code for the step is under web/.](img/s1-open-sample.png).

<!-- PENDING: delete `img/fileview.png` -->


**Note:**
If you see red X’s
at the left of the filenames or if the `packages` directory doesn't appear,
the packages are not properly installed.
Right-click `pubspec.yaml` and select **Pub Get**.
(Do **not** use pub upgrade.
This code lab is tied to a specific version of Polymer.dart.)

### Open the app's source files

The initial app uses the following source files:
* `pubspec.yaml`: The app's description and dependencies, used by the Dart package manager
* `bin/main.dart`: The server app
* `lib/`: Public libraries shared between server and client app
* `test/`: The tests scripts
* `web/index.html`: The web app's template
* `web/css`, `web/fonts` and `web/img`: The app's appearance (we'll skip this for now)

&rarr;  In Dart Editor, open `pubspec.yaml` (in the top directory) by
double-clicking its filename.
To see its raw source code,
click the **Source** tab at the bottom of the edit view.

&rarr;  Still in Dart Editor,
under the `web` directory
double-click `index.html` and `main.dart`.

![Open 3 source files](img/s1-open-files.png)

<!-- PENDING: delete `img/openfiles.png` -->

### Review the code

Get familiar with `pubspec.yaml`, and with the HTML and Dart code
for the skeleton version of the app.

#### pubspec.yaml

The `pubspec.yaml` file in the project root gives information
about this app and the packages it depends on.
In particular, the dependency on **polymer** gives the Dart tools
the information they need to download the
[polymer package](https://pub.dartlang.org/packages/polymer).

``` yaml
  name: risk
  description: A two hour exercise, based on the Risk game, to learn Polymer.dart.
  dependencies:
    polymer: 0.9.5
    browser: any
    bootstrap_for_pub: any
    morph: any
    http_server: any
  dev_dependencies:
    unittest: any
    mock: any
  transformers:
  - polymer:
      entry_points: web/index.html
```

Key information:

* All Polymer.dart apps depend on `polymer`.
* Like most Dart web apps, this app also depends on `browser`.
* Polymer depends on other packages (including `browser`, as it happens).
  The pub package manager automatically finds the right versions of these packages.
* You can find many Dart packages, including polymer,
  on [pub.dartlang.org](http://pub.dartlang.org/).
* For more information about the pub package manager, see the
  [pub documentation](https://www.dartlang.org/tools/pub/).
* `transformers` section helps to build a deployable version of your app. 


#### index.html

The first version of this HTML file contains no Polymer components.
However, it does set you up to add Polymer components in the next step.

```HTML
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Risk</title>
    <link rel="stylesheet" href="css/risk.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap-theme.min.css">

    <script type="application/dart">export 'package:polymer/init.dart';</script>
    <script src="packages/browser/dart.js"></script>
  </head>
  <body>
    <h1>Risk</h1>
    
    <div>
      TO DO: Put the UI widgets here.
    </div>
  </body>
</html>
```
Key information:
- The first `<script>` tag automatically initializes polymer elements without 
  having to write a main for your application.
- The `packages/browser/dart.js` script checks for native Dart support and
  either bootstraps the Dart VM or loads compiled JavaScript instead.


#### game.html

This is a simple example of a Polymer web component.
It contains the game template.

```HTML
<!DOCTYPE html>

<polymer-element name="risk-game" noscript>
  <template>
    <link rel="stylesheet" href="css/risk.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap-theme.min.css">

    <section class="container-fluid">
      <div class="row">
        <!-- Risk Board -->
        <img src="img/board.svg" alt="Board" class="col-md-8">
        <div class="col-md-4">
          <!-- Players List -->
          <!-- ... -->
        </div>
      </div>
    </section>
  </template>
</polymer-element>
```

Key information:
* The `name`  attribute is required and **must** contain a `-`. 
  It specifies the name of the HTML tag you’ll instantiate in markup 
  (in this case `<risk-game>`).
* The `noscript` attribute indicates that this is a simple element 
  that doesn’t include any script. An element declared with noscript 
  is registered automatically.
* The `template` tag contains the content of the web component. For now,
  it's static content.


### Run the app in Dartium

&rarr; Right-click `index.html` and select **Run in Dartium**.

![Click the run button](img/s1-run-in-dartium.png).

<!-- PENDING: delete `img/clickrun.png` -->

Dart Editor launches _Dartium_, a special build of Chromium that has the Dart Virtual Machine built in, and loads the `index.html` file.
The `index.html` file loads the app and calls the `main()` function in `package:polymer/init.dart` script.
You should see the `Risk` title and a TO DO comment on the left.

<!-- Add screenshot? -->

## [Home](../README.md) | [< Previous](step-0.md) | [Next >](step-2.md)
