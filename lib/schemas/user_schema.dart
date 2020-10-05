import 'package:flutter/foundation.dart';
import 'package:ricker_app/utils/helper.dart';

enum UserRoles {
  superadmin,
  supervisor,
  driver,
}

class User {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final UserRoles role;
  final String registration;

  User({
    @required this.id,
    @required this.name,
    @required this.email,
    @required this.imageUrl,
    @required this.role,
    @required this.registration,
  });

  User.fromJson(Map json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        imageUrl = json['imageUrl'],
        role = Helper.getEnumFromString(UserRoles.values, json['role']),
        registration = json['registration'];

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, imageUrl: $imageUrl, role: $role, registration: $registration)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "email": email,
      "imageUrl": imageUrl,
      "role": role.toString(),
      "registration": registration
    };
  }
}
