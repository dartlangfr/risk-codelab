import 'dart:convert';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:risk/risk.dart';
import 'package:risk_engine/client.dart';
import 'package:risk_engine/snapshot.dart';

@CustomTag('risk-board')
class RiskBoard extends AbstractRiskBoardElement {
  @observable
  Map<String, Map> paths;

  @observable
  String selectedCountryId;

  @published
  RiskGameState game = loadEventsAsync(new RiskGameStateImpl(), SNAPSHOT_GAME_ATTACK);

  RiskBoard.created(): super.created() {
    HttpRequest.getString('res/country-paths.json').then(JSON.decode).then(toObservable).then((e) => paths = e);
  }

  countrySelect(Event e, var detail, Element target) {
    selectedCountryId = target.dataset['country'];
  }

  String color(int playerId) {
    return playerId == null ? "white" : game.players[playerId].color;
  }
}
