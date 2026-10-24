/// The school tree returned by `GET /api/v1/schools`.
///
/// One response carries institution → faculty → department → programme →
/// level in a single nested document, so the questions never need a second
/// call as the user narrows down.
library;

class AcademicLevel {
  const AcademicLevel({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory AcademicLevel.fromJson(Map<String, dynamic> json) => AcademicLevel(
    id: json['id'] as String,
    name: json['name'] as String,
    sortOrder: json['sortOrder'] as int? ?? 0,
  );

  final String id;
  final String name;
  final int sortOrder;
}

class Programme {
  const Programme({
    required this.id,
    required this.name,
    this.code,
    this.levels = const [],
  });

  factory Programme.fromJson(Map<String, dynamic> json) => Programme(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String?,
    levels: _list(json['levels'], AcademicLevel.fromJson)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
  );

  final String id;
  final String name;
  final String? code;
  final List<AcademicLevel> levels;
}

class Department {
  const Department({
    required this.id,
    required this.name,
    this.code,
    this.programmes = const [],
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String?,
    programmes: _list(json['programmes'], Programme.fromJson),
  );

  final String id;
  final String name;
  final String? code;
  final List<Programme> programmes;
}

class Faculty {
  const Faculty({
    required this.id,
    required this.name,
    this.code,
    this.departments = const [],
  });

  factory Faculty.fromJson(Map<String, dynamic> json) => Faculty(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String?,
    departments: _list(json['departments'], Department.fromJson),
  );

  final String id;
  final String name;
  final String? code;
  final List<Department> departments;
}

class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.slug,
    this.acronym,
    this.logoUrl,
    this.faculties = const [],
  });

  factory Institution.fromJson(Map<String, dynamic> json) => Institution(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String? ?? '',
    acronym: json['acronym'] as String?,
    logoUrl: json['logoUrl'] as String?,
    faculties: _list(json['faculties'], Faculty.fromJson),
  );

  final String id;
  final String name;
  final String slug;
  final String? acronym;
  final String? logoUrl;
  final List<Faculty> faculties;

  /// The design shows a location and marks schools not yet live as "coming
  /// soon". `InstitutionResponse` carries neither, though the table behind it
  /// has `State` and `IsActive` — raised with the backend. Until the DTO
  /// exposes them, a school counts as live if it has anything published under
  /// it, which is the closest honest signal available.
  bool get isAvailable => faculties.isNotEmpty;

  String get subtitle => isAvailable ? '' : 'coming soon';
}

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) =>
    raw is List
    ? raw.whereType<Map<String, dynamic>>().map(parse).toList(growable: false)
    : const [];
