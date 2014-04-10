part of risk;

/// Country class.
class Country {
  /// The country id.
  final String id;
  /// The country neighbours.
  final List<String> neighbours;

  /// Default constructor
  Country(this.id, this.neighbours);
}

/// List of all existing countries
final List<Country> COUNTRIES = [//
  // australia
  new Country('eastern_australia', ['western_australia', 'new_guinea']), //
  new Country('indonesia', ['siam', 'new_guinea', 'western_australia']), //
  new Country('new_guinea', ['indonesia', 'eastern_australia', 'western_australia']), //
  new Country('western_australia', ['eastern_australia', 'indonesia', 'new_guinea']), //
  // south_america
  new Country('argentina', ['brazil', 'peru']), //
  new Country('brazil', ['north_africa', 'venezuela', 'argentina', 'peru']), //
  new Country('peru', ['venezuela', 'brazil', 'argentina']), //
  new Country('venezuela', ['central_america', 'brazil', 'peru']), //
  // africa
  new Country('congo', ['east_africa', 'south_africa', 'north_africa']), //
  new Country('egypt', ['southern_europe', 'middle_east', 'east_africa', 'north_africa']), //
  new Country('east_africa', ['middle_east', 'madagascar', 'south_africa', 'congo', 'north_africa', 'egypt']), //
  new Country('madagascar', ['east_africa', 'south_africa']), //
  new Country('north_africa', ['southern_europe', 'western_europe', 'brazil', 'egypt', 'east_africa', 'congo']), //
  new Country('south_africa', ['madagascar', 'east_africa', 'congo']), //
  // north_america
  new Country('alaska', ['kamchatka', 'northwest_territory', 'alberta']), //
  new Country('alberta', ['alaska', 'ontario', 'northwest_territory', 'western_united_states']), //
  new Country('central_america', ['venezuela', 'eastern_united_states', 'western_united_states']), //
  new Country('eastern_united_states', ['quebec', 'ontario', 'western_united_states', 'central_america']), //
  new Country('greenland', ['iceland', 'ontario', 'northwest_territory', 'quebec']), //
  new Country('northwest_territory', ['alaska', 'ontario', 'greenland', 'alberta']), //
  new Country('ontario', ['northwest_territory', 'greenland', 'eastern_united_states', 'western_united_states', 'quebec', 'alberta']), //
  new Country('quebec', ['greenland', 'ontario', 'eastern_united_states']), //
  new Country('western_united_states', ['alberta', 'ontario', 'eastern_united_states', 'central_america']), //
  // europe
  new Country('great_britain', ['iceland', 'western_europe', 'northern_europe', 'scandinavia']), //
  new Country('iceland', ['greenland', 'great_britain', 'scandinavia']), //
  new Country('northern_europe', ['ukraine', 'scandinavia', 'great_britain', 'western_europe', 'southern_europe']), //
  new Country('scandinavia', ['iceland', 'great_britain', 'northern_europe', 'ukraine']), //
  new Country('southern_europe', ['north_africa', 'egypt', 'middle_east', 'ukraine', 'northern_europe', 'western_europe']), //
  new Country('ukraine', ['ural', 'afghanistan', 'middle_east', 'southern_europe', 'northern_europe', 'scandinavia']), //
  new Country('western_europe', ['north_africa', 'southern_europe', 'northern_europe', 'great_britain']), //
  // asia
  new Country('afghanistan', ['ukraine', 'ural', 'china', 'india', 'middle_east']), //
  new Country('china', ['siberia', 'ural', 'afghanistan', 'india', 'siam', 'mongolia']), //
  new Country('india', ['middle_east', 'afghanistan', 'china', 'siam']), //
  new Country('irkutsk', ['siberia', 'kamchatka', 'mongolia', 'yakursk']), //
  new Country('japan', ['kamchatka', 'mongolia']), //
  new Country('kamchatka', ['alaska', 'yakursk', 'irkutsk', 'mongolia', 'japan']), //
  new Country('ural', ['siberia', 'china', 'afghanistan', 'ukraine']), //
  new Country('middle_east', ['southern_europe', 'ukraine', 'afghanistan', 'india', 'egypt', 'east_africa']), //
  new Country('mongolia', ['china', 'siberia', 'irkutsk', 'kamchatka', 'japan']), //
  new Country('siam', ['india', 'china', 'indonesia']), //
  new Country('siberia', ['yakursk', 'irkutsk', 'mongolia', 'china', 'ural']), //
  new Country('yakursk', ['kamchatka', 'siberia', 'irkutsk'])//
];

/// All [Country]s indexed by country id
final Map<String, Country> COUNTRY_BY_ID = new Map.fromIterable(COUNTRIES, key: (country) => country.id);

/// Continent class.
class Continent {
  /// The continent id.
  final String id;
  /// The reinforcement bonus given if the same player owns all continent countries.
  final int bonus;
  /// The countries of this continent.
  final List<String> countries;

  /// Default constructor
  Continent(this.id, this.bonus, this.countries);
}

/// List of all existing continents
final List<Continent> CONTINENTS = [//
  new Continent('australia', 2, ["eastern_australia", "indonesia", "new_guinea", "western_australia"]), //
  new Continent('north_america', 5, ["alaska", "alberta", "central_america", "eastern_united_states", "greenland", "northwest_territory", "ontario", "quebec",
      "western_united_states"]), //
  new Continent('south_america', 2, ["argentina", "brazil", "peru", "venezuela"]), //
  new Continent('africa', 3, ["congo", "egypt", "east_africa", "madagascar", "north_africa", "south_africa"]), //
  new Continent('europe', 5, ["great_britain", "iceland", "northern_europe", "scandinavia", "southern_europe", "ukraine", "western_europe"]), //
  new Continent('asia', 7, ["afghanistan", "china", "india", "irkutsk", "japan", "kamchatka", "ural", "middle_east", "mongolia", "siam", "siberia", "yakursk"]),//
];
