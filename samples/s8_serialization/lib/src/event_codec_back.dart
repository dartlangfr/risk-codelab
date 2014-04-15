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
