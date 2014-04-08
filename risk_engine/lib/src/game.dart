part of risk_engine;

/**
 * Stores the Risk game state.
 */
abstract class RiskGameState {
  static const PLAYERS_MIN = 2;
  static const PLAYERS_MAX = 6;
  static const START_ARMIES = const [0, 0, 40, 35, 30, 25, 20];
  static const TURN_STEP_REINFORCEMENT = 'REINFORCEMENT';
  static const TURN_STEP_ATTACK = 'ATTACK';
  static const TURN_STEP_FORTIFICATION = 'FORTIFICATION';

  /// Returns all possible countryIds
  List<String> get allCountryIds;

  /// Returns the countryId / country state map.
  Map<String, CountryState> get countries;
  /// Returns the playerId / player state map.
  Map<int, PlayerState> get players;
  /// Returns the players order.
  List<int> get playersOrder;
  /// Returns the player who is playing.
  int get activePlayerId;

  /// True if the game is started.
  bool get started;
  /// True if the game is setuping player countries.
  bool get setupPhase;
  /// Return the turn step of the active player (REINFORCEMENT, ATTACK, FORTIFICATION).
  String get turnStep;

  /**
   * Updates this Risk game state for the incoming [event].
   */
  void update(EngineEvent event);

  /**
   * Computes attacker loss comparing rolled [attacks] and [defends] dices.
   */
  int computeAttackerLoss(List<int> attacks, List<int> defends);

  /**
   * Computes reinforcement for a [playerId] in this game.
   * Reinforcement = (Number of countries player owns) / 3 + (Continent bonus)
   * Continent bonus is added if player owns all the countries of a continent.
   * If reinforcement is less than three, round up to three.
   */
  int computeReinforcement(int playerId);

  /**
   * Returns neighbours ids for the given [countryId].
   */
  List<String> countryNeighbours(String countryId);
}

/**
 * Stores the state of a country.
 */
abstract class CountryState {
  /// The countryId for this CountryState.
  String get countryId;
  /// The playerId who owns this country.
  int get playerId;
  /// The number of armies in this country.
  int get armies;
}

/**
 * Stores the state of a player.
 */
abstract class PlayerState {
  /// The playerId for this CountryState.
  int get playerId;
  /// The player's name.
  String get name;
  /// The player's avatar.
  String get avatar;
  /// The player's color.
  String get color;
  /// The number of available armies for the player.
  int get reinforcement;
}
