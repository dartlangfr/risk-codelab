library risk.map.test;

import 'package:unittest/unittest.dart';
import '../lib/risk.dart';

const NoSuchMethodErrorMatcher = const isInstanceOf<NoSuchMethodError>();

main() {
  test('Country should be instanciable', () {
    var country = new Country('eastern_australia', ['western_australia', 'new_guinea']);
    expect(country, isNotNull);
    expect(country.id, equals('eastern_australia'));
    expect(country.neighbours, equals(['western_australia', 'new_guinea']));
  });

  test('Continent should be instanciable', () {
    var continent = new Continent('australia', 2, ["eastern_australia", "indonesia", "new_guinea", "western_australia"]);
    expect(continent, isNotNull);
    expect(continent.id, equals('australia'));
    expect(continent.bonus, equals(2));
    expect(continent.countries, equals(["eastern_australia", "indonesia", "new_guinea", "western_australia"]));
  });

  test('Continent should be instanciable', () {
    var continent = new Continent('australia', 2, ["eastern_australia", "indonesia", "new_guinea", "western_australia"]);
    expect(continent, isNotNull);
    expect(continent.id, equals('australia'));
    expect(continent.bonus, equals(2));
    expect(continent.countries, equals(["eastern_australia", "indonesia", "new_guinea", "western_australia"]));
  });

  test('Continent should be immutable', () {
    var continent = new Continent('australia', 2, ["eastern_australia", "indonesia", "new_guinea", "western_australia"]);
    expect(() => continent.id = 1, throwsA(NoSuchMethodErrorMatcher));
    expect(() => continent.bonus = 1, throwsA(NoSuchMethodErrorMatcher));
    expect(() => continent.countries = [], throwsA(NoSuchMethodErrorMatcher));
  });

  var countryIds = COUNTRIES.map((c) => c.id);

  group('COUNTRIES', () {
    test('should have 42 countries', () {
      expect(COUNTRIES.length, equals(42));
    });

    test('for each country should have at least 1 neighbour', () {
      for (final Country country in COUNTRIES) {
        expect(country.neighbours.length, isPositive);
      }
    });

    test('for each country should not be its own neighbour', () {
      for (final Country country in COUNTRIES) {
        expect(country.neighbours.contains(country.id), isFalse, reason: '${country.id} is its own neighbour');
      }
    });

    test('for each neighbourhood should be mutual', () {
      for (final Country country in COUNTRIES) {
        for (final String neighbour in country.neighbours) {
          expect(COUNTRIES.firstWhere((c) => c.id == neighbour).neighbours, contains(country.id), reason: '${country.id} and ${neighbour} are not mutual neighbours');
        }
      }
    });
  });

  group('COUNTRY_BY_ID', () {
    test('should have 42 countries', () {
      expect(COUNTRY_BY_ID.keys.length, equals(42));
    });

    test('should be correctly indexed', () {
      expect(COUNTRY_BY_ID.keys.length, equals(42));
      for (final String country in countryIds) {
        expect(COUNTRY_BY_ID[country].id, equals(country));
      }
    });
  });

  group('CONTINENTS', () {
    test('should contain 6 continents', () {
      expect(CONTINENTS.length, equals(6));
    });

    test('for each continent should contain countries', () {
      for (final Continent continent in CONTINENTS) {
        expect(continent.countries.length, isPositive);
      }
    });

    test('for each country should belong to only one continent', () {
      for (final String country in countryIds) {
        expect(CONTINENTS.where((c) => c.countries.contains(country)).length, equals(1), reason: '${country} doesn\'t belong to only one continent');
      }
    });
  });
}
