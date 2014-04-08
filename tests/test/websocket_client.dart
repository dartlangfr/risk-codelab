import 'dart:convert';
import 'dart:html';
import 'package:risk_engine/client.dart';

final playerEvents = {
  "JoinGame": (playerId) => new JoinGame()
      ..playerId = playerId
      ..name = "John Lennon"
      ..avatar = "kadhafi.png",
  "StartGame": (playerId) => new StartGame()..playerId = playerId,
  "PlaceArmy": (playerId) => new PlaceArmy()
      ..playerId = playerId
      ..country = "eastern_australia",
  "Attack": (playerId) => new Attack()
      ..playerId = playerId
      ..from = "eastern_australia"
      ..to = "western_australia"
      ..armies = 3,
  "EndAttack": (playerId) => new EndAttack()..playerId = playerId,
  "MoveArmy": (playerId) => new MoveArmy()
      ..playerId = playerId
      ..from = "eastern_australia"
      ..to = "western_australia"
      ..armies = 1,
  "EndTurn": (playerId) => new EndTurn()..playerId = playerId,
};

Element logs = querySelector("#logs");
InputElement sendButton = querySelector("#sendButton");
TextAreaElement eventInput = querySelector("#eventInput");
SelectElement eventTemplate = querySelector("#eventTemplate");

const url = "ws://127.0.0.1:8080/ws";
final ws = new WebSocket(url);
int playerId;

main() {
  eventTemplate.children.addAll(playerEvents.keys.map((e) => new OptionElement(
      data: e, value: e)));
  eventTemplate.onChange.listen(templateChanged);

  sendButton.onClick.listen((_) => ws.send(eventInput.value));

  var eventStream = ws.onMessage.map((e) => e.data).map(JSON.decode).map(
      printEvent).map(EVENT.decode).listen(handleEvents);
}

printEvent(event) {
  logs.children.add(new LIElement()..text = "$event");
  return event;
}

handleEvents(event) {
  if (event is Welcome) {
    playerId = event.playerId;
    eventTemplate.selectedIndex = 1;
    templateChanged(null);
  }
}

templateChanged(_) {
  var event = playerEvents[eventTemplate.value];
  eventInput.text = event == null ? "" : JSON.encode(EVENT.encode(event(playerId
      )));
}
