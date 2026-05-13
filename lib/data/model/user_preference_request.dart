/// Normalize API date (e.g. "2002-10-02T00:00:00.000Z") to "YYYY-MM-DD".
String? _dateFromApi(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  if (s.length >= 10) return s.substring(0, 10);
  return null;
}

/// Request body for POST /v1/userPreference (and PATCH).
/// Send only what the user has selected; omit or use defaults for unselected.
/// Also used to bind GET /v1/userPreference response via fromJson.
class UserPreferenceRequest {
  const UserPreferenceRequest({
    this.services,
    this.personalDetails,
    this.importantPeople,
    this.foodPreferences,
    this.shoppingHabits,
    this.healthPreferences,
    this.travelPreferences,
    this.homeServices,
    this.budgetAndDeals,
    this.notificationSettings,
  });

  final UserPreferenceServices? services;
  final UserPreferencePersonalDetails? personalDetails;
  final List<UserPreferenceImportantPerson>? importantPeople;
  final UserPreferenceFoodPreferences? foodPreferences;
  final UserPreferenceShoppingHabits? shoppingHabits;
  final UserPreferenceHealthPreferences? healthPreferences;
  final UserPreferenceTravelPreferences? travelPreferences;
  final UserPreferenceHomeServices? homeServices;
  final UserPreferenceBudgetAndDeals? budgetAndDeals;
  final UserPreferenceNotificationSettings? notificationSettings;

  UserPreferenceRequest copyWith({
    UserPreferenceServices? services,
    UserPreferencePersonalDetails? personalDetails,
    List<UserPreferenceImportantPerson>? importantPeople,
    UserPreferenceFoodPreferences? foodPreferences,
    UserPreferenceShoppingHabits? shoppingHabits,
    UserPreferenceHealthPreferences? healthPreferences,
    UserPreferenceTravelPreferences? travelPreferences,
    UserPreferenceHomeServices? homeServices,
    UserPreferenceBudgetAndDeals? budgetAndDeals,
    UserPreferenceNotificationSettings? notificationSettings,
  }) {
    return UserPreferenceRequest(
      services: services ?? this.services,
      personalDetails: personalDetails ?? this.personalDetails,
      importantPeople: importantPeople ?? this.importantPeople,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      shoppingHabits: shoppingHabits ?? this.shoppingHabits,
      healthPreferences: healthPreferences ?? this.healthPreferences,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      homeServices: homeServices ?? this.homeServices,
      budgetAndDeals: budgetAndDeals ?? this.budgetAndDeals,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (services != null) map['services'] = services!.toJson();
    if (personalDetails != null) map['personalDetails'] = personalDetails!.toJson();
    if (importantPeople != null && importantPeople!.isNotEmpty) {
      map['importantPeople'] = importantPeople!.map((e) => e.toJson()).toList();
    }
    if (foodPreferences != null) map['foodPreferences'] = foodPreferences!.toJson();
    if (shoppingHabits != null) map['shoppingHabits'] = shoppingHabits!.toJson();
    if (healthPreferences != null) map['healthPreferences'] = healthPreferences!.toJson();
    if (travelPreferences != null) map['travelPreferences'] = travelPreferences!.toJson();
    if (homeServices != null) map['homeServices'] = homeServices!.toJson();
    if (budgetAndDeals != null) map['budgetAndDeals'] = budgetAndDeals!.toJson();
    if (notificationSettings != null) {
      map['notificationSettings'] = notificationSettings!.toJson();
    }
    return map;
  }

  /// Parse GET response "data" map into request (ignores _id, userId, createdAt, updatedAt).
  static UserPreferenceRequest? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserPreferenceRequest(
      services: json['services'] != null
          ? UserPreferenceServices.fromJson(json['services'] as Map<String, dynamic>)
          : null,
      personalDetails: json['personalDetails'] != null
          ? UserPreferencePersonalDetails.fromJson(json['personalDetails'] as Map<String, dynamic>)
          : null,
      importantPeople: json['importantPeople'] is List
          ? (json['importantPeople'] as List)
              .map((e) => UserPreferenceImportantPerson.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      foodPreferences: json['foodPreferences'] != null
          ? UserPreferenceFoodPreferences.fromJson(json['foodPreferences'] as Map<String, dynamic>)
          : null,
      shoppingHabits: json['shoppingHabits'] != null
          ? UserPreferenceShoppingHabits.fromJson(json['shoppingHabits'] as Map<String, dynamic>)
          : null,
      healthPreferences: json['healthPreferences'] != null
          ? UserPreferenceHealthPreferences.fromJson(json['healthPreferences'] as Map<String, dynamic>)
          : null,
      travelPreferences: json['travelPreferences'] != null
          ? UserPreferenceTravelPreferences.fromJson(json['travelPreferences'] as Map<String, dynamic>)
          : null,
      homeServices: json['homeServices'] != null
          ? UserPreferenceHomeServices.fromJson(json['homeServices'] as Map<String, dynamic>)
          : null,
      budgetAndDeals: json['budgetAndDeals'] != null
          ? UserPreferenceBudgetAndDeals.fromJson(json['budgetAndDeals'] as Map<String, dynamic>)
          : null,
      notificationSettings: json['notificationSettings'] != null
          ? UserPreferenceNotificationSettings.fromJson(json['notificationSettings'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// services: pass true for each category the user selected
class UserPreferenceServices {
  const UserPreferenceServices({
    this.food = false,
    this.services = false,
    this.travel = false,
    this.education = false,
    this.groceries = false,
    this.package = false,
    this.deals = false,
    this.tickets = false,
    this.pharmacy = false,
    this.shopping = false,
    this.donation = false,
    this.moneywiz = false,
  });

  final bool food;
  final bool services;
  final bool travel;
  final bool education;
  final bool groceries;
  final bool package;
  final bool deals;
  final bool tickets;
  final bool pharmacy;
  final bool shopping;
  final bool donation;
  final bool moneywiz;

  Map<String, dynamic> toJson() => {
        'food': food,
        'services': services,
        'travel': travel,
        'education': education,
        'groceries': groceries,
        'package': package,
        'deals': deals,
        'tickets': tickets,
        'pharmacy': pharmacy,
        'shopping': shopping,
        'donation': donation,
        'moneywiz': moneywiz,
      };

  static UserPreferenceServices fromJson(Map<String, dynamic> json) {
    return UserPreferenceServices(
      food: json['food'] as bool? ?? false,
      services: json['services'] as bool? ?? false,
      travel: json['travel'] as bool? ?? false,
      education: json['education'] as bool? ?? false,
      groceries: json['groceries'] as bool? ?? false,
      package: json['package'] as bool? ?? false,
      deals: json['deals'] as bool? ?? false,
      tickets: json['tickets'] as bool? ?? false,
      pharmacy: json['pharmacy'] as bool? ?? false,
      shopping: json['shopping'] as bool? ?? false,
      donation: json['donation'] as bool? ?? false,
      moneywiz: json['moneywiz'] as bool? ?? false,
    );
  }
}

/// personalDetails: dateOfBirth "YYYY-MM-DD", gender "male"|"female", preferredLanguage "en"
class UserPreferencePersonalDetails {
  const UserPreferencePersonalDetails({
    this.dateOfBirth,
    this.gender = 'male',
    this.preferredLanguage = 'en',
  });

  final String? dateOfBirth; // "YYYY-MM-DD"
  final String gender;
  final String preferredLanguage;

  Map<String, dynamic> toJson() => {
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        'gender': gender,
        'preferredLanguage': preferredLanguage,
      };

  static UserPreferencePersonalDetails fromJson(Map<String, dynamic> json) {
    return UserPreferencePersonalDetails(
      dateOfBirth: _dateFromApi(json['dateOfBirth']),
      gender: json['gender'] as String? ?? 'male',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );
  }
}

/// importantPeople: each entry relation (spouse/child/father/...), name, dateOfBirth, anniversary, gender
class UserPreferenceImportantPerson {
  const UserPreferenceImportantPerson({
    required this.relation,
    required this.name,
    this.dateOfBirth,
    this.anniversary,
    this.gender = 'male',
  });

  final String relation; // lowercase: spouse, child, father, mother, other
  final String name;
  final String? dateOfBirth; // "YYYY-MM-DD"
  final String? anniversary; // "YYYY-MM-DD"
  final String gender; // "male" | "female"

  Map<String, dynamic> toJson() => {
        'relation': relation.toLowerCase(),
        'name': name,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (anniversary != null) 'anniversary': anniversary,
        'gender': gender.toLowerCase(),
      };

  static UserPreferenceImportantPerson fromJson(Map<String, dynamic> json) {
    return UserPreferenceImportantPerson(
      relation: json['relation'] as String? ?? 'other',
      name: json['name'] as String? ?? '',
      dateOfBirth: _dateFromApi(json['dateOfBirth']),
      anniversary: _dateFromApi(json['anniversary']),
      gender: json['gender'] as String? ?? 'male',
    );
  }
}

/// foodPreferences: favoriteCuisines, dietaryPreferences - pass selected as arrays
class UserPreferenceFoodPreferences {
  const UserPreferenceFoodPreferences({
    this.favoriteCuisines = const [],
    this.dietaryPreferences = const [],
  });

  final List<String> favoriteCuisines; // e.g. ["indian", "chinese", "thai", "italian"]
  final List<String> dietaryPreferences; // e.g. ["vegetarian", "non-veg", "vegan", "jain"]

  Map<String, dynamic> toJson() => {
        'favoriteCuisines': favoriteCuisines,
        'dietaryPreferences': dietaryPreferences,
      };

  static UserPreferenceFoodPreferences fromJson(Map<String, dynamic> json) {
    return UserPreferenceFoodPreferences(
      favoriteCuisines: (json['favoriteCuisines'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dietaryPreferences: (json['dietaryPreferences'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// shoppingHabits: groceryFrequency "weekly", categories ["fashion", "electronics", "home_living"]
class UserPreferenceShoppingHabits {
  const UserPreferenceShoppingHabits({
    this.groceryFrequency = 'weekly',
    this.categories = const [],
  });

  final String groceryFrequency;
  final List<String> categories;

  Map<String, dynamic> toJson() => {
        'groceryFrequency': groceryFrequency,
        'categories': categories,
      };

  static UserPreferenceShoppingHabits fromJson(Map<String, dynamic> json) {
    return UserPreferenceShoppingHabits(
      groceryFrequency: json['groceryFrequency'] as String? ?? 'weekly',
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// healthPreferences: hasRecurringPrescriptions, reminderFrequency, interests
class UserPreferenceHealthPreferences {
  const UserPreferenceHealthPreferences({
    this.hasRecurringPrescriptions = false,
    this.reminderFrequency = 'weekly',
    this.interests = const [],
  });

  final bool hasRecurringPrescriptions;
  final String reminderFrequency; // daily, weekly, bi-weekly, monthly
  final List<String> interests; // fitness, nutrition, yoga, wellness

  Map<String, dynamic> toJson() => {
        'hasRecurringPrescriptions': hasRecurringPrescriptions,
        'reminderFrequency': reminderFrequency,
        'interests': interests,
      };

  static UserPreferenceHealthPreferences fromJson(Map<String, dynamic> json) {
    return UserPreferenceHealthPreferences(
      hasRecurringPrescriptions: json['hasRecurringPrescriptions'] as bool? ?? false,
      reminderFrequency: json['reminderFrequency'] as String? ?? 'weekly',
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// travelPreferences: travelFrequency, purposes, entertainmentInterests
class UserPreferenceTravelPreferences {
  const UserPreferenceTravelPreferences({
    this.travelFrequency = 'frequent',
    this.purposes = const [],
    this.entertainmentInterests = const [],
  });

  final String travelFrequency; // frequent, occasional, rarely
  final List<String> purposes; // business, vacation, family_visits, adventure
  final List<String> entertainmentInterests; // movies, concerts, sports, events

  Map<String, dynamic> toJson() => {
        'travelFrequency': travelFrequency,
        'purposes': purposes,
        'entertainmentInterests': entertainmentInterests,
      };

  static UserPreferenceTravelPreferences fromJson(Map<String, dynamic> json) {
    return UserPreferenceTravelPreferences(
      travelFrequency: json['travelFrequency'] as String? ?? 'frequent',
      purposes: (json['purposes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      entertainmentInterests: (json['entertainmentInterests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// homeServices: servicesUsed, preferredServiceTime "morning"
class UserPreferenceHomeServices {
  const UserPreferenceHomeServices({
    this.servicesUsed = const [],
    this.preferredServiceTime = 'morning',
  });

  final List<String> servicesUsed; // cleaning, plumbing, carpentry, electrical, painting, appliance_repair
  final String preferredServiceTime; // morning, afternoon, evening, flexible

  Map<String, dynamic> toJson() => {
        'servicesUsed': servicesUsed,
        'preferredServiceTime': preferredServiceTime,
      };

  static UserPreferenceHomeServices fromJson(Map<String, dynamic> json) {
    return UserPreferenceHomeServices(
      servicesUsed: (json['servicesUsed'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      preferredServiceTime: json['preferredServiceTime'] as String? ?? 'morning',
    );
  }
}

/// budgetAndDeals: dealImportance, monthlyBudgetRange { min, max }, donationCauses
class UserPreferenceBudgetAndDeals {
  const UserPreferenceBudgetAndDeals({
    this.dealImportance = 'moderate',
    this.monthlyBudgetRange,
    this.donationCauses = const [],
  });

  final String dealImportance; // very_important, moderate, low
  final UserPreferenceBudgetRange? monthlyBudgetRange;
  final List<String> donationCauses; // education, healthcare, environment, animals

  Map<String, dynamic> toJson() => {
        'dealImportance': dealImportance,
        if (monthlyBudgetRange != null) 'monthlyBudgetRange': monthlyBudgetRange!.toJson(),
        'donationCauses': donationCauses,
      };

  static UserPreferenceBudgetAndDeals fromJson(Map<String, dynamic> json) {
    UserPreferenceBudgetRange? range;
    if (json['monthlyBudgetRange'] is Map<String, dynamic>) {
      final r = json['monthlyBudgetRange'] as Map<String, dynamic>;
      final min = r['min'];
      final max = r['max'];
      if (min != null && max != null) {
        range = UserPreferenceBudgetRange(
          min: (min is int) ? min : int.tryParse(min.toString()) ?? 0,
          max: (max is int) ? max : int.tryParse(max.toString()) ?? 0,
        );
      }
    }
    return UserPreferenceBudgetAndDeals(
      dealImportance: json['dealImportance'] as String? ?? 'moderate',
      monthlyBudgetRange: range,
      donationCauses: (json['donationCauses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class UserPreferenceBudgetRange {
  const UserPreferenceBudgetRange({required this.min, required this.max});
  final int min;
  final int max;
  Map<String, dynamic> toJson() => {'min': min, 'max': max};
}

/// notificationSettings: reminderBefore "1_week", preferredTime "09:00", reminderTypes
class UserPreferenceNotificationSettings {
  const UserPreferenceNotificationSettings({
    this.reminderBefore = '1_week',
    this.preferredTime = '09:00',
    this.reminderTypes = const [],
  });

  final String reminderBefore; // 1_week, 3_days, 1_day
  final String preferredTime; // 09:00, 14:00, 18:00
  final List<String> reminderTypes; // birthdays, deals, order_updates, service_bookings

  Map<String, dynamic> toJson() => {
        'reminderBefore': reminderBefore,
        'preferredTime': preferredTime,
        'reminderTypes': reminderTypes,
      };

  static UserPreferenceNotificationSettings fromJson(Map<String, dynamic> json) {
    return UserPreferenceNotificationSettings(
      reminderBefore: json['reminderBefore'] as String? ?? '1_week',
      preferredTime: json['preferredTime'] as String? ?? '09:00',
      reminderTypes: (json['reminderTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
