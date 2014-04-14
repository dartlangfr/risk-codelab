part of risk_engine;

//////////////// PLAYER EVENTS

/// Event produced by Player
abstract class PlayerEvent {
  /// The player id who sent this event
  int get playerId;
}

/// sent by player that is ready to join a game
class JoinGame implements PlayerEvent {
  int playerId;
  /// The player name
  String name;
  /// The player avatar
  String avatar;
  /// The player color
  String color;
}

/// sent by the first player to start a game
class StartGame implements PlayerEvent {
  int playerId;
}

/// sent by player when he put an army on a country
class PlaceArmy implements PlayerEvent {
  int playerId;
  /// The country id where the player want to put an army
  String country;
}

/// sent by player when he attacks a country
class Attack implements PlayerEvent {
  int playerId;
  /// The country id from where the player takes armies to attack
  String from;
  /// The country id to where the player sends armies to attack
  String to;
  /// The number of armies the player sends
  int armies;
}

/// sent by player to stop attacking and start fortification
class EndAttack implements PlayerEvent {
  int playerId;
}

/// sent by player to move an army from a country to another
class MoveArmy implements PlayerEvent {
  int playerId;
  /// The country id from where the player takes armies to move
  String from;
  /// The country id to where the player sends armies
  String to;
  /// The number of armies the player moves
  int armies;
}

/// sent by player to end its turn
class EndTurn implements PlayerEvent {
  int playerId;
}

//////////////// ENGINE EVENTS

/// Event produced by the Game Engine
abstract class EngineEvent {}

/// sent by engine to identify player when he arrives
class Welcome implements EngineEvent {
  /// Give an identity to the incoming player
  int playerId;
}

/// sent when player joins the game
class PlayerJoined implements EngineEvent {
  /// The player id who joined the game
  int playerId;
  /// The player name
  String name;
  /// The player avatar
  String avatar;
  /// The player color
  String color;
}

/// sent by the engine when countries are affected
class GameStarted implements EngineEvent {
  /// The number of armies by player
  int armies;
  /// The players order
  List<int> playersOrder;
}

/// sent by engine when army is placed on a country
class ArmyPlaced implements EngineEvent {
  /// The player id who placed an army
  int playerId;
  /// The country id where the player want to put an army
  String country;
}

/// sent by the engine to change user
class NextPlayer implements EngineEvent {
  /// The player id who has to play
  int playerId;
  /// The number of reinforcement armies
  int reinforcement;
}

/// sent by the engine when setup phase is ended
class SetupEnded implements EngineEvent {}

/// sent by the engine when turn step changed to the following
class NextStep implements EngineEvent {}

/// sent by engine the result of battle
class BattleEnded implements EngineEvent {
  /// Result of the battle for the attacker
  BattleOpponentResult attacker;
  /// Result of the battle for the defender
  BattleOpponentResult defender;
  /// True if the country is conquered
  bool conquered;
}

/// Battle result for one opponent
class BattleOpponentResult {
  /// The player id of the opponent
  int playerId;
  /// The rolled dices of the battle for the opponent
  List<int> dices;
  /// The country id of the opponent
  String country;
  /// The remaining armies after the battle in his country
  int remainingArmies;
}

/// sent by engine when an army is moved from a country to another
class ArmyMoved implements EngineEvent {
  /// The player id who moved armies
  int playerId;
  /// The country id from where the player took armies to move
  String from;
  /// The country id to where the player sent armies
  String to;
  /// The number of armies the player moved
  int armies;
}

/// sent by engine when a player lost the game
class PlayerLost implements EngineEvent {
  /// The player id who lost the game
  int playerId;
}

/// sent by engine when a player win the game
class PlayerWon implements EngineEvent {
  /// The player id who won the game
  int playerId;
}