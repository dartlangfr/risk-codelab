## Step 10: Put it all together

In this step, you put all together what you done in the previous and play the game :)

_**Keywords**: WebSocket client, enjoy_

### Update the `risk-game` element

&rarr; Copy and paste the template below in `web/game.html`:

```HTML
<!DOCTYPE html>

<link rel="import" href="board.html">
<link rel="import" href="hello.html">
<link rel="import" href="players.html">
<link rel="import" href="modal.html">
<link rel="import" href="registration.html">
<link rel="import" href="packages/risk_engine/components/history.html">
<link rel="import" href="packages/risk_engine/components/panel.html">

<polymer-element name="risk-game">
  <template>
    <link rel="stylesheet" href="css/risk.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="packages/bootstrap_for_pub/3.1.0/css/bootstrap-theme.min.css">

    <section class="container-fluid">
      <div class="row">
        <!-- Risk Board -->
        <risk-board id='board' game="{{ game }}" playerId="{{ playerId }}" class="col-md-9"
          on-attack="{{ attack }}"
          on-move="{{ move }}"
          on-selection="{{ selection }}"></risk-board>

        <div class="col-md-3">
          <hello-world name="{{ game.players[playerId].name }}"></hello-world>

          <risk-players players="{{ game.players.values }}" activePlayerId="{{ game.activePlayerId }}" playersOrder="{{ game.playersOrder }}"></risk-players>

          <risk-panel game="{{ game }}" playerId="{{ playerId }}" pendingMove="{{ pendingMove }}"
            on-startgame="{{ startGame }}"
            on-movearmies="{{ moveArmies }}"
            on-endattack="{{ endAttack }}"
            on-endturn="{{ endTurn }}"></risk-panel>

          <risk-history game="{{ game }}"></risk-history>
        </div>
      </div>
    </section>

    <template if="{{ !game.started && game.players[playerId] == null }}">
      <risk-modal title="Player registration">
        <risk-registration on-done='{{ joinGame }}'></risk-registration>
      </risk-modal>
    </template>
  </template>
  
  <script type="application/dart" src="game.dart"></script>
</polymer-element>
```

&rarr; In `web/game.html`, extend `RiskGame` with `AbstractRiskGame` and implement the missing methods:

```Dart
import 'dart:convert';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:risk_engine/client.dart';
import 'package:risk/risk.dart';

@CustomTag('risk-game')
class RiskGame extends AbstractRiskGame {
  RiskGame.created(): super.created();

  // TODO: return the engine event Codec you previously implemented
  @override
  Codec<Object, Map> get eventEngineCodec => null;

  // TODO: Instantiate a RiskGameStateImpl
  @override
  final RiskGameState game = null;

  /// Listen events on the given [webSocket].
  @override
  void listen(WebSocket ws) {
    // TODO: listen message coming from the given WebSocket, decode them and handle them with `handleEvents`
  }

  /// Send the given [event] through the WebSocket 
  @override
  void sendEvent(PlayerEvent event) {
    // TODO: encode and send the given event through the WebSocket
  }

  /// Send a JoinGame event though the WebSocket
  joinGame(CustomEvent e, var detail, Element target) {
    // TODO: send a JoinGame event, filled with the data in `detail`
  }
}
```

Key information:
* `AbstractRiskGame` class opens the WebSocket on the same url as the window location. It also provides logical in `handleEvents` to handle `EngineEvent`. It already implements Player interaction events sending the right `PlayerEvent`.
* The `risk-panel` custom element provided in the `risk_engine` lib and handles some of the user interactions.
* The `risk-history` displays all the human readable incoming events.

### Play the game

Congratulations!
You finish this codelab. Enjoy your job and play Risk with your friends :)

&rarr; **Run** the server `bin/main.dart`

&rarr; **Launch Dartium** with the url http://localhost:8080

### Learn more
 - [Polymer.dart](https://www.dartlang.org/polymer-dart/)
 - [Polymer expressions](https://pub.dartlang.org/packages/polymer_expressions)
 
### Problems?
Check your code against the files in [s10_alltogether](../samples/s10_alltogether).

## [Home](../README.md#code-lab-polymerdart) | [< Previous](step-9.md#step-9-server-side)

