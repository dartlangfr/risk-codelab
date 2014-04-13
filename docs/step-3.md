## Step 3: Risk Game

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

&rarr; Under `lib/src`, create a file named `game.dart`.

To do this in Dart Editor, right-click the `lib/src` directory, choose **New File...**, and specify the name `game.dart`.

```Dart
part of risk;

// TODO: implement RiskGameState
```

You've just added a new implementation file!

Key information:

* `library risk;` declares that this is a library named `risk`.
* `part 'src/game.dart';` adds an implementation file in the library located by the given path.
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
  String name;
  /// The player's avatar.
  String avatar;
  /// The player's color.
  String color;
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

Key information:

* `CountryState` stores the state of a country: the player who owns the country and the number of armies in place.
* `PlayerState` stores the state of a player: the player's information, the number of armies he get at the beginning of his turn and if he's dead.
* `RiskGameState` stores the state of the whole game: the board with the countries states, the players states and the progress of the game.
* A class implements one or more interfaces by declaring them in an `implements` clause and then providing the APIs required by the interfaces. 
* You can explore the source code of the interfaces: right click on the interface name (e.g. `RiskGameState`), then _Open Declaration_. 

### Implementation of `RiskGameState`

`RiskGameState` also provides few logical functions needed for the game engine and it is also capable of updating itself for an incoming `EngineEvent`.

Continue to edit `src/game.dart`.

&rarr; Right click on the `RiskGameStateImpl` class name, then _Quick Fix_ and select _Create 5 missing override(s)_. It should add new methods in the class:

```Dart
  // TODO: implement allCountryIds
  /// Returns all possible countryIds
  @override
  List<String> get allCountryIds => null;

  /// Returns neighbours ids for the given [countryId].
  @override
  List<String> countryNeighbours(String countryId) {
    // TODO: implement countryNeighbours
  }

  /// Computes attacker loss comparing rolled [attacks] and [defends] dices.
  /// This method assumes that [attacks] and [defends] are sorted in a descending order
  @override
  int computeAttackerLoss(List<int> attacks, List<int> defends) {
    // TODO: implement computeAttackerLoss
  }

  /**
   * Computes reinforcement for a [playerId] in this game.
   * Reinforcement = (Number of countries player owns) / 3 + (Continent bonus)
   * Continent bonus is added if player owns all the countries of a continent.
   * If reinforcement is less than three, round up to three.
   */
  @override
  int computeReinforcement(int playerId) {
    // TODO: implement computeReinforcement
  }

  /// Updates this Risk game state for the incoming [event].
  @override
  void update(EngineEvent event) {
    // TODO: implement update
  }
```

&rarr; Implements those methods and run tests in `test/s3_game_test.dart` to check if your implementation is correct.

Key information:
* `RiskGameStateImpl` implements an abstract class. Unlike _Java_ there's no real interface in _Dart_. [Every class implicitly defines an interface](https://www.dartlang.org/docs/dart-up-and-running/contents/ch02.html#ch02-implicit-interfaces) containing all the instance members of the class and of any interfaces it implements. So every class can be used in `implements` clause.
* `@override` is an annotation that marks an instance member as overriding a superclass member with the same name.
* `allCountryIds` returns all existing countries. Use `COUNTRIES` or `COUNTRY_BY_ID` to get them.
* `countryNeighbours` computes the number of reinforcement armies at the beginning of a player turn. Follow the [Risk rules](rules.md).
* `computeAttackerLoss` takes rolled dices in parameter in descending order. It returns the number of lost armies for the attacker according to the [Risk rules](rules.md).
* `computeReinforcement` computes the number of reinforcement armies at the beginning of a player turn. Follow the [Risk rules](rules.md) and use the [collection API](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-core.Iterable).
  Advise: create a method `playerCountries` that returns the country ids owned by the player.
* `update` updates the game state in function of the incoming event. Follow the [Events bible](events.md) and run the tests.

### Learn more
 - [Dart Language - Libraries](https://www.dartlang.org/docs/dart-up-and-running/contents/ch02.html#libraries)
 - [Collection API](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-core.Iterable)

### Problems?
Check your code against the files in [s3_game](../samples/s3_game).

## [Home](../README.md) | [< Previous](step-2.md) | [Next >](step-4.md)
