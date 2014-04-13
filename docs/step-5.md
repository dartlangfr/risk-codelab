## Step 5: Polymer templates

In this step, ...

_**Keywords**: ..._

### Create a `risk-players` element

Create a new custom element, as follows.

&rarr; Create a new file `web/players.html`.

```HTML
<!DOCTYPE html>

<polymer-element name="risk-players">
  <template>
    <link rel="stylesheet" href="css/risk.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap-theme.min.css">

    <ul id="players" class="list-group list-group-inverse img-rounded">
      <li class="list-group-item">
        <!-- In the following tag, bind player avatar and color -->
        <img src="img/avatars/castro.png" style="border-color: green" class="img-rounded" alt="Avatar">
        <!-- Bind here player name -->
        <span><b>Paul McCartney</b></span>
        <span class="badge pull-right">
          <i class="riskicon riskicon-soldier"></i>
          <i class="riskicon riskicon-soldier"></i>
          <!-- Bind here player reinforcement -->
          2
        </span>
      </li>
    </ul>
  </template>
  <script type="application/dart" src="players.dart"></script>
</polymer-element>
```

&rarr; Create a new file `web/players.dart`.

```Dart
import 'package:polymer/polymer.dart';
import 'package:risk_engine/risk_engine.dart';
import 'package:risk/risk.dart';

@CustomTag('risk-players')
class RiskPlayers extends PolymerElement {
  PlayerState player = new PlayerStateImpl(2, "John Lennon", "kadhafi.png", "blue", reinforcement: 2);

  RiskPlayers.created(): super.created();
}
```

&rarr; In the element template, bind the `player` fields to see his `name`, his `avatar`, his `color` and his `reinforcement` number. Follow this example:

```HTML
<span><b>{{player.name}}</b></span>
```

&rarr; Import this new component in `web/index.html` and use its tag.  
&rarr; Run in Dartium

You should see something like:

![Single player](img/s5-player.png).

Key information:
* Properties on the model and in the scope are looked up via simple property names, like `{{player}}`. Property names are looked up first in the top-level variables, next in the model, then recursively in parent scopes. Properties on objects can be access with dot notation like `{{player.name}}`.
* Polymer expressions allow you to write complex binding expressions, with property access, function invocation, list/map indexing, and two-way filtering like.
* For more information about Polymer expressions, see the [Polymer expressions documentation](https://pub.dartlang.org/packages/polymer_expressions).

### Filter function

We want to uppercase the player name, to do so, follow this instructions:

&rarr; Add a `uppercase` filter function in `web/players.dart`:

```Dart
class RiskPlayers extends PolymerElement {
  // ...
  String uppercase(String s) => s.toUpperCase();
  // ...
}
```

&rarr; Use it to upper-case the player `name` in `web/players.html`:

```HTML
<span><b>{{player.name | uppercase}}</b></span>
```

&rarr; Run in Dartium

You should see the upper-case player name:

![Single player](img/s5-player-uppercase.png).

Key information:
* A filter is a function that transforms a value into another, used via the pipe syntax: `value | filter`. Any function that takes exactly one argument can be used as a filter.
* The top-level function named `uppercase` is in the scope so if `player.name` is "John Lennon", then `person.name | uppercase` will have the value "JOHN LENNON".

### Conditional template

We want to display soldier icons in function of the number of player reinforcement:

- ![!](img/soldier.png) if `reinforcement` is less or equal to `1`
- ![!](img/soldier.png)![!](img/soldier.png)![!] if `reinforcement` is equal `2`
- ![!](img/soldier.png)![!](img/soldier.png)![!](img/soldier.png) if `reinforcement` is greater or equal to `3`

&rarr; In `web/players.html`, use conditional templates:

```HTML
<span class="badge pull-right">
  <i class="riskicon riskicon-soldier"></i>
  <!-- TODO complete the if expression -->
  <template if="{{ true }}">
    <i class="riskicon riskicon-soldier"></i>
  </template>
  <!-- TODO complete the if expression -->
  <template if="{{ false }}">
    <i class="riskicon riskicon-soldier"></i>
  </template>
  {{ player.reinforcement }}
</span>
```

&rarr; Run in Dartium, and try to change the value of player `reinforcement`.

Key information:
* Control the UI with declarative conditionals in templates.
* Template conditionals are part of the data binding infrastructure. If `player.reinforcement` changes, the templates are automatically re-evaluated.

### Learn more
 - [Polymer.dart](https://www.dartlang.org/polymer-dart/)
 - [Polymer expressions](https://pub.dartlang.org/packages/polymer_expressions)
 
### Problems?
Check your code against the files in [s5_template](../samples/s5_template).

## [Home](../README.md) | [< Previous](step-4.md) | [Next >](step-6.md)
