library risk_engine;

// Declare libraries needed for Polymer in dart2js version
// risk should be declared in risk library but it's here just for exercice simplification
@MirrorsUsed(targets: const ['risk_engine', 'risk'])
import 'dart:mirrors';

// Import common sources to be visible in this library scope
import 'risk_engine.dart';
// Export common sources to be visible to this library's users
export 'risk_engine.dart';

// Include specific client sources
