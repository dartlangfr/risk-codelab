# Risk game events

* There is two kind of events:
  * `PlayerEvent` is an event sent by the player from the UI
  * `EngineEvent` is an event sent by the game Engine from the server
* All `EngineEvent` are broadcasted to every players.
* All `EngineEvent` are kept in an events history.
* When player connects to the WebSocket:
  * The server assign a `playerId` to sending him a `WelcomeEvent`.
  * Then, the server sends him all events in history so he is able to restore the game state.
* All `PlayerEvent` contains the `playerId` of the player who sent the event.

## Player events

| Event | Game phase | Comments |
| ----- | ----- | ----- |
| JoinGame | Players enrollment | The player joins the game |
| StartGame | Players enrollment | One of the player starts the game |
| PlaceArmy | Setup | Each player adds one army to a country one by one during the setup phase |
| PlaceArmy | Reinforcement | Player adds one army to a country at the beginning of his turn |
| Attack | Attack | The player attacks from a country to one of opposing neighbour with 1 to 3 armies |
| MoveArmy | Attack | When conquered, the player chooses the number of armies to move in the country (at least 1 army) |
| EndAttack | Attack | The player ends attacking and starts fortification |
| MoveArmy | Fortification | The player can move armies from a country to a neighbour |
| EndTurn | Fortification | The player ends fortication and finishes his turn |

## Engine events

| Event | Game phase | Comments |
| ----- | ----- | ----- |
| Welcome | Any | Technical event sent to identify immediately after the player connects |
| PlayerJoined | Players enrollment | Sent when a player joined the game |
| GameStarted | Players enrollment | Sent when the game starts |
| NextPlayer | Setup | Sent when the next player has to place an army during the setup phase |
| ArmyPlaced | Setup | Sent when a player added one army to a country one by one during the setup phase |
| SetupEnded | Setup | Sent when all armies are placed. |
| NextPlayer | Reinforcement | Sent when it's the turn of the next player. It gives the number of reinforcement armies |
| ArmyPlaced | Reinforcement | Sent when the active player added one army to a country at the beginning of his turn |
| NextStep | Reinforcement | Sent when the active player placed all of his reinforcement armies |
| BattleEnded | Attack | Sent the result of a battle when the player attacked a country |
| ArmyMoved | Attack | Sent when the player moved armies in the conquered contry |
| NextStep | Attack | Sent when the active player ended attacking and started fortification |
| ArmyMoved | Fortification | Sent when the active player move armies for fortification |
