## Step 6: Risk board

In this step, ...

_**Keywords**: ..._


### Template loop

We want to display a list of players.

&rarr; In `web/players.dart`, ...:

```Dart
...
```

&rarr; In `web/players.html`, ...:

```HTML
...
```

&rarr; Complete the `tokenList` filter to enable `active` class if it is the active player in function of `activePlayerId` value.  
&rarr; Run in Dartium.

You should see something like:

![Players list](img/s5-players.png).

Key information:
* `{{ player in players }}` loops through a collection, instantiating a template for every item in the collection.
* Template loops are part of the data binding infrastructure. If an item is added or removed from `players`, the contents of `<ul>` are automatically updated.
* The `tokenList` filter is useful for binding to the class attribute. It allows you to dynamically set/remove class names based on the object passed to it. If the object key is truthy, the name will be applied as a class.

### Learn more
 - [Polymer.dart](https://www.dartlang.org/polymer-dart/)
 - [Polymer expressions](https://pub.dartlang.org/packages/polymer_expressions)
 
### Problems?
Check your code against the files in [s5_template](../samples/s5_template).

## [Home](../README.md) | [< Previous](step-5.md) | [Next >](step-7.md)
