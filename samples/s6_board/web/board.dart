import 'dart:convert';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:risk/risk.dart';
import 'package:risk_engine/client.dart';
import 'package:risk_engine/snapshot.dart';

@CustomTag('risk-board')
class RiskBoard extends AbstractRiskBoardElement {
  @observable
  var paths;

  @observable
  String selectedCountryId;

  @published
  RiskGameState game = loadEvents(new RiskGameStateImpl(), SNAPSHOT_GAME_ATTACK);
  
  @published
  int playerId = 2;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('res/country-paths.json').then(JSON.decode).then((e) => paths = e);
  }

  countryClick(Event e, var detail, Element target) {
    var handler = getClickHandler(target.dataset['country'], game.activePlayerId, game.turnStep, selectedCountryId);
    handler(e, detail, target);
  }

  countrySelect(Event e, var detail, Element target) => selectedCountryId = target.dataset['country'];
  countryUnselect(Event e, var detail, Element target) => selectedCountryId = null;
  countryPlaceArmy(Event e, var detail, Element target) => fire('selection', detail: target.dataset['country']);
  countryAttack(Event e, var detail, Element target) => fire('attack', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });
  countryMove(Event e, var detail, Element target) => fire('move', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });

  String color(int playerId) {
    return playerId == null ? "white" : game.players[playerId].color;
  }
}
