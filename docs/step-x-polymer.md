# Backup for Polymer setup and introduction

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

  
  
  
The `index.html` file loads the app and calls the `main()` function in `package:polymer/init.dart` script.
  