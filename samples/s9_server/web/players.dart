import 'package:polymer/polymer.dart';
import 'package:risk_engine/risk_engine.dart';
import 'package:risk/risk.dart';

@CustomTag('risk-players')
class RiskPlayers extends PolymerElement {
  @published
  Iterable<PlayerState> players = [ //
    new PlayerStateImpl(1, "Paul McCartney", "castro.png", "green", reinforcement: 0), //
    new PlayerStateImpl(2, "John Lennon", "kadhafi.png", "blue", reinforcement: 2), //
    new PlayerStateImpl(3, "Ringo Starr", "staline.png", "yellow", reinforcement: 0), //
    new PlayerStateImpl(4, "George Harrison", "kim-jong-il.png", "red", reinforcement: 0), //
  ];

  @published
  int activePlayerId = 2;

  @published
  List<int> playersOrder = [3, 4, 2, 1];

  RiskPlayers.created(): super.created();

  sort(List<int> playersOrder) => (Iterable<PlayerState> players) => new List.from(players) //
      ..sort((PlayerState a, PlayerState b) => playersOrder.indexOf(a.playerId).compareTo(playersOrder.indexOf(b.playerId)));
}
