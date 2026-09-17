class Student {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phone_number;
  final String email;
  final String role;

  Student({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    required this.email,
    this.phone_number,
    required this.role,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      phone_number: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone': phone_number,
      'role': role,
    };
  }
}