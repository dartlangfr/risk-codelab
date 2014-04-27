library risk_engine;

// Declare libraries needed for Polymer in dart2js version
// risk should be declared in risk library but it's here just for exercise simplification
@MirrorsUsed(targets: const ['risk_engine', 'risk_engine.client', 'risk'])
import 'dart:mirrors';

// Common sources between client and server
part 'src/event.dart';
part 'src/game.dart';
