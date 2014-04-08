library risk.map.test;

import 'package:unittest/unittest.dart';
import 'package:risk_engine/server.dart';
import 'package:risk/risk.dart';

main() {
  test('there should be 6 continents', () {
    expect(CONTINENTS.length, equals(6));
  });

  test('each continent should contain countries', () {
    for (final Continent continent in CONTINENTS) {
      expect(continent.countries.length, isPositive);
    }
  });

  test('there should be 42 countries', () {
    expect(COUNTRIES.length, equals(42));
    for (final String country in COUNTRIES.keys) {
      expect(COUNTRIES[country].id, equals(country));
    }
  });

  test('each country should belong to only one continent', () {
    for (final String country in COUNTRIES.keys) {
      expect(CONTINENTS.where((c) => c.countries.contains(country)).length, equals(1));
    }
  });

  test('each country should have at least 1 neighbour', () {
    for (final Country country in COUNTRIES.values) {
      expect(country.neighbours.length, isPositive);
    }
  });

  test('each neighbourhood should be mutual', () {
    for (final Country country in COUNTRIES.values) {
      for (final String neighbour in country.neighbours) {
        expect(COUNTRIES[neighbour].neighbours, contains(country.id), reason:
            '${country.id} and ${neighbour} are not mutual neighbours');
      }
    }
  });
}
