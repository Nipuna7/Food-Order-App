class UserModel {
  String? uid;
  String? email;
  String? name;
  String? contactNumber;
  String? profilePicture; // Base64 encoded string

  UserModel({
    this.uid,
    this.email,
    this.name,
    this.contactNumber,
    this.profilePicture,
  });

  // Convert UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'contactNumber': contactNumber,
      'profilePicture': profilePicture,
    };
  }

  // Create UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      contactNumber: map['contactNumber'],
      profilePicture: map['profilePicture'],
    );
  }
}