class User {
  final int? id;
  final String name;
  final String email;
  final String? password; // Store securely or use Firebase Auth
  final String? phoneNumber;
  final String? address;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
    );
  }
}
