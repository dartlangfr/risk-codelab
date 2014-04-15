## Step 8: Event serialization

In this step, you serialize the game events to make them sendable through the network.

_**Keywords**: serialization, reflection, mirrors_

### Add new source files in the library

&rarr; Edit `lib/risk.dart`, as follows.

```dart
library risk;

import 'dart:math';
import 'dart:convert';

import 'package:risk_engine/risk_engine.dart';
import 'package:observe/observe.dart';
import 'package:morph/morph.dart';

part 'src/map.dart';
part 'src/game.dart';
part 'src/event_codec.dart';
```

You have added 3 lines:
* `import 'dart:convert'`: [dart:convert](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-convert) provides encoders and decoders for converting between different data representations, including JSON and UTF-8. It particullarly contains a standard [Codec](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-convert.Codec) class you will implement.
* `import 'package:morph/morph.dart'`: [morph](http://pub.dartlang.org/packages/morph) is a mirror based serializer and deserializer of Dart objects.
* `part 'src/event_codec.dart'`: your new file containing serialization stuff.

&rarr; Create a new file `lib/src/event_codec.dart`, with the following content:

```dart
part of risk;

const EVENT = const EventCodec();

/**
 * Encodes and decodes Event from/to JSON.
 */
class EventCodec extends Codec<Object, Map> {
  final decoder = const EventDecoder();
  final encoder = const EventEncoder();
  const EventCodec();
}

/**
 * Decodes Event from JSON.
 */
class EventDecoder extends Converter<Map, Object> {
  const EventDecoder();
  Object convert(Map input) {
    // TODO implement the conversion from JSON to object
  }
}

/**
 * Encodes Event to JSON.
 */
class EventEncoder extends Converter<Object, Map> {
  const EventEncoder();
  Map convert(Object input) {
    // TODO implement the conversion from object to JSON
  }
}
```

Key information:
* The `Codec<S, T>` class contains 2 abstract getters (`Converter<S, T> get encoder` and `Converter<T, S> get decoder`) that need to be defined.
* The `const` keyword is used for variables that you want to be compile-time constants. To allow `EventCodec` to be a constant you have to define the constructor with the `const` keyword as prefix and to only use const fields.

### Basic implementation of an encoder/decoder

&rarr; Edit `lib/src/event_codec.dart` and try to make `test/s8_event_codec_test_single.dart` pass.

The Object to serialize in this test is:

```dart
new PlaceArmy()
    ..playerId = 1
    ..country = 'alaska'
```

The converted datas should be:

```dart
{
  'event': 'PlaceArmy',
  'data': {
    'playerId': 1,
    'country': 'alaska'
  }
}
```

Tips:
* To test the type of an object you can use `if (o is PlaceArmy) {....}`.
* Use the cascade operator (`..`) when you want to perform a series of operations on the members of a single object

### Implementation using reflection

The manual implementation can be done but is really heavy and long to do due to the large number of events.

There are several packages to perform serialization: [morph](http://pub.dartlang.org/packages/morph), [dartson](http://pub.dartlang.org/packages/dartson) or [serialization](http://pub.dartlang.org/packages/serialization). You will go with _morph_.

&rarr; Edit `lib/src/event_codec.dart` with the following.

```dart
part of risk;

const EVENT = const EventCodec();
final _MORPH = new Morph();

/**
 * Encodes and decodes Event from/to JSON.
 */
class EventCodec extends Codec<Object, Map> {
  final decoder = const EventDecoder();
  final encoder = const EventEncoder();
  const EventCodec();
}

/**
 * Decodes Event from JSON.
 */
class EventDecoder extends Converter<Map, Object> {
  final _classes = const {
    "JoinGame": JoinGame,
    "StartGame": StartGame,
    "PlaceArmy": PlaceArmy,
    "Attack": Attack,
    "EndAttack": EndAttack,
    "MoveArmy": MoveArmy,
    "EndTurn": EndTurn,
    "Welcome": Welcome,
    "PlayerJoined": PlayerJoined,
    "GameStarted": GameStarted,
    "ArmyPlaced": ArmyPlaced,
    "NextPlayer": NextPlayer,
    "SetupEnded": SetupEnded,
    "NextStep": NextStep,
    "BattleEnded": BattleEnded,
    "ArmyMoved": ArmyMoved,
    "PlayerLost": PlayerLost,
    "PlayerWon": PlayerWon,
  };

  const EventDecoder();
  Object convert(Map input) {
    var event = input == null ? null : input['event'];
    var type = _classes[event];
    return type == null ? null : _MORPH.deserialize(type, input['data']);
  }
}

/**
 * Encodes Event to JSON.
 */
class EventEncoder extends Converter<Object, Map> {
  const EventEncoder();
  Map convert(Object input) => {
    'event': '${input.runtimeType}',
    'data': _MORPH.serialize(input)
  };
}
```

Key information:
* _morph_ (like other packages mentionned above) uses reflection provided by [dart:mirrors](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-mirrors) to make the conversion.

&rarr; Run `test/s8_event_codec_test.dart` to ensure the conversion works.

### Conversion from Object to String

You now have a `EventCodec` to encode/decode `Object` to/from JSON data structure.
The `dart:convert` library nativelly provides several codecs. One of them is the [JSON codec](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-convert#id_JSON).
To create a new codec `Codec<Object,String>` you only have to compose the one you just created and the `JSON` provided by `dart:convert` with the [fuse method](https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart-convert.Codec#id_fuse):

```dart
final EVENT_JSON_CODEC = EVENT.fuse(JSON);
```

This actually does not work due to an incompatibility between the generic types we used but you see how powerful can be compositions.

### Learn more
 - [dart:convert - Decoding and Encoding JSON, UTF-8, and more](https://www.dartlang.org/docs/dart-up-and-running/contents/ch03.html#ch03-dart-convert)
 - [dart:mirrors - Reflection](https://www.dartlang.org/docs/dart-up-and-running/contents/ch03.html#ch03-mirrors)
 
### Problems?
Check your code against the files in [s8_serialization](../samples/s8_serialization).

## [Home](../README.md#code-lab-polymerdart) | [< Previous](step-7.md#step-7-player-enrollment) | [Next >](step-9.md#step-9-server-side)

