library risk.main;

import '../lib/risk.dart';

main() {
  Country country = new Country('eastern_australia', ['western_australia', 'new_guinea', 'eastern_australia']);
  var neighbours = country.neighbours;
  print("Hello ${country.id} and $neighbours!");
}