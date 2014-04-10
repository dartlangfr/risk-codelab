## Step 3: Dart algorithm

In this step, you implement few logical functions and the game state.

_**Keywords**: library, syntax, collection api_


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
* `part` adds an implementation file in the library located by the given path.
* `part of risk;` indicates that the file is part of the library `risk` and that it shares the same scope.

### Add state classes

Edit `src/game.dart`, as follows.

&rarr; Add the following classes:

```Dart
/// Stores the state of a country.
class CountryStateImpl implements CountryState {
  /// The countryId for this CountryState.
  final String countryId;
  /// The playerId who owns this country.
  int playerId;
  /// The number of armies in this country.
  int armies;
  CountryStateImpl(this.countryId, {this.playerId, this.armies: 0});
}

/// Stores the state of a player.
class PlayerStateImpl implements PlayerState {
  /// The playerId for this CountryState.
  final int playerId;
  /// The player's name.
  final String name;
  /// The player's avatar.
  final String avatar;
  /// The player's color.
  final String color;
  /// The number of available armies for the player.
  int reinforcement;
  /// True if the player lost the game.
  bool dead;

  PlayerStateImpl(this.playerId, this.name, this.avatar, this.color, {this.reinforcement: 0, this.dead: false});
}

/// Stores the Risk game state.
class RiskGameStateImpl implements RiskGameState {
  /// Returns the countryId / country state map.
  Map<String, CountryStateImpl> countries = {};
  /// Returns the playerId / player state map.
  Map<int, PlayerStateImpl> players = {};
  /// Returns the players order.
  List<int> playersOrder = [];
  /// Returns the player who is playing.
  int activePlayerId;

  /// True if the game is started.
  bool started = false;
  /// True if the game is setuping player countries.
  bool setupPhase = false;
  /// Return the turn step of the active player (REINFORCEMENT, ATTACK, FORTIFICATION).
  String turnStep;

  /// Returns the history of all events
  List<EngineEvent> events = [];
}
```

The editor complains about missing concrete implementation. We'll implement them right after.

Those classes are basics implementation of game state.
* `CountryState` stores the state of a country: the player who owns the country and the number of armies in place.
* `PlayerState` stores the state of a player: the player's information, the number of armies he get at the beginning of his turn and if he is dead.
* `RiskGameState` stores the state of the whole game: the board with the countries states, the players states and the progress of the game.

Key information:

* A class implements one or more interfaces by declaring them in an `implements` clause and then providing the APIs required by the interfaces. 
* You can explore the source code of the interfaces: right click on the interface name (e.g. `RiskGameState`), then _Open Declaration_. 

### `RiskGameState` implementation

`RiskGameState` also provides few logical functions needed for the game engine and it is also capable of updating it self for an incoming `EngineEvent`.

...


### Learn more
 - [Dart Language - Libraries](https://www.dartlang.org/docs/dart-up-and-running/contents/ch02.html#libraries)

### Problems?
Check your code against the files in [s3_algorithm](../samples/s3_algorithm).

## [Home](../README.md) | [< Previous](step-2.md) | [Next >](step-4.md)
