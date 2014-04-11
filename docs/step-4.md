## Step 3: Polymer custom element

In this step, you implement your fisrt Polymer custom element.

_**Keywords**: polymer, custom element, template, binding, filter function_


### Add a new source file in the library

Edit `lib/risk.dart`, as follows.

```Dart
library risk;

import 'dart:math';
import 'package:risk_engine/risk_engine.dart';

part 'src/map.dart';
part 'src/game.dart';
```

The editor complains about inexistant `src/game.dart` file. We'll create it in the section below.  
It also complains about unused imports. Don't worry about that, we'll be using `dart:math` and the engine later in this step.

Create a new file `src/game.dart`, as follows.

```Dart
part of risk;

// TODO: implement RiskGameState
```

You've just added a new implementation file!

Key information:

* `library risk;` declares that this is a library named `risk`.
* `part 'src/game.dart';` adds an implementation file in the library located by the given path.
* `part of risk;` indicates that the file is part of the library `risk` and that it shares the same scope.



### Learn more
 - [Dart Language - Libraries](https://www.dartlang.org/docs/dart-up-and-running/contents/ch02.html#libraries)
 - [Collection API](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-core.Iterable)

### Problems?
Check your code against the files in [s4_element](../samples/s4_element).

## [Home](../README.md) | [< Previous](step-3.md) | [Next >](step-5.md)
