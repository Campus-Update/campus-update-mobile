import 'Student.dart';

class Staff extends Student {
  final String? staffId;

  Staff({
    required int id,
    String? firstName,
    String? lastName,
    String? username,
    required String email,
    required String role,
    this.staffId,
  }) : super(
         id: id,
         firstName: firstName,
         lastName: lastName,
         username: username,
         email: email,
         role: role,
       );

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      staffId: json['agency_name'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({'staff_id': staffId});
    return data;
  }
}
