import 'package:polymer/polymer.dart';
import 'package:risk_engine/risk_engine.dart';
import 'package:risk/risk.dart';

@CustomTag('risk-players')
class RiskPlayers extends PolymerElement {
  PlayerState player = new PlayerStateImpl(2, "John Lennon", "kadhafi.png", "blue", reinforcement: 2);
  
  @published
  Iterable<PlayerState> players = [ //
    new PlayerStateImpl(1, "Paul McCartney", "castro.png", "green", reinforcement: 0), //
    new PlayerStateImpl(2, "John Lennon", "kadhafi.png", "blue", reinforcement: 2), //
    new PlayerStateImpl(3, "Ringo Starr", "staline.png", "yellow", reinforcement: 1), //
    new PlayerStateImpl(4, "George Harrison", "kim-jong-il.png", "red", reinforcement: 4), //
  ];

  @published
  int activePlayerId = 2;

  RiskPlayers.created(): super.created();

  String capitalize(String s) => s.toUpperCase();
}
