library risk_engine;

// Declare libraries needed for Polymer in dart2js version
// risk should be declared in risk library but it's here just for exercise simplification
@MirrorsUsed(targets: const ['risk_engine', 'risk'])
import 'dart:mirrors';

import 'dart:html';
import 'package:polymer/polymer.dart';

// Import common sources to be visible in this library scope
import 'risk_engine.dart';
// Export common sources to be visible to this library's users
export 'risk_engine.dart';

// Include specific client sources

/// Brings some logical facilitation for RiskBoard
abstract class AbstractRiskBoardElement extends PolymerElement {
  /// The selected country
  String get selectedCountryId;
  set selectedCountryId(String value);
  /// The Risk game state
  RiskGameState get game;
  /// The connected playerId
  @published
  int playerId = 2;

  AbstractRiskBoardElement.created(): super.created();

  /**
   * Returns true if a country is selectable depending on the given arguments.
   */
  selectableCountry(String countryId, int activePlayerId, String turnStep, String selectedCountryId) {
    var handler = getClickHandler(countryId, activePlayerId, turnStep, selectedCountryId);
    return handler != countryUnselect && (selectedCountryId == null || handler != countrySelect);
  }

  countryClick(Event e, var detail, Element target) {
    var handler = getClickHandler(target.dataset['country'], game.activePlayerId, game.turnStep, selectedCountryId);
    handler(e, detail, target);
  }

  /**
   * Returns the correct click handler for a country depending on the given arguments.
   */
  getClickHandler(String countryId, int activePlayerId, String turnStep, String selectedCountryId) {
    if (activePlayerId != playerId) {
      return countryUnselect;
    } else if (turnStep == RiskGameState.TURN_STEP_REINFORCEMENT) {
      if (isMine(countryId)) return countryPlaceArmy;
    } else if (turnStep == RiskGameState.TURN_STEP_ATTACK) {
      if (countryId == selectedCountryId) return countryUnselect; else if (canAttackFrom(countryId)) return countrySelect; else if (selectedCountryId != null && canAttackTo(
          selectedCountryId, countryId)) return countryAttack;
    } else if (turnStep == RiskGameState.TURN_STEP_FORTIFICATION) {
      if (countryId == selectedCountryId) return countryUnselect; else if (canFortifyFrom(countryId)) return countrySelect; else if (selectedCountryId != null && canFortifyTo(
          selectedCountryId, countryId)) return countryMove;
    }
    return countryUnselect;
  }

  /// When a country is selected
  countrySelect(Event e, var detail, Element target) => selectedCountryId = target.dataset['country'];
  /// When a country is unselected
  countryUnselect(Event e, var detail, Element target) => selectedCountryId = null;
  /// When country is clicked to place an army
  countryPlaceArmy(Event e, var detail, Element target) => fire('selection', detail: target.dataset['country']);
  /// When country to attack is clicked with a previously selected country
  countryAttack(Event e, var detail, Element target) => fire('attack', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });
  /// When country where to move armies is clicked with a previously selected country
  countryMove(Event e, var detail, Element target) => fire('move', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });

  bool isMine(String country) => game.countries[country].playerId == playerId;
  bool isNotMine(String country) => !isMine(country);
  bool areNeighbours(String myCountry, String strangeCountry) => game.countryNeighbours(myCountry).contains(strangeCountry);
  bool canAttackFrom(String country) => isMine(country) && game.countries[country].armies > 1 && game.countryNeighbours(country).any((to) => isNotMine(to));
  bool canAttackTo(String from, String to) => isNotMine(to) && areNeighbours(from, to);
  bool canFortifyFrom(String country) => isMine(country) && game.countries[country].armies > 1 && game.countryNeighbours(country).any((to) => isMine(to));
  bool canFortifyTo(String from, String to) => isMine(to) && areNeighbours(from, to);
}
