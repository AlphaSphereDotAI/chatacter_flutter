class UserData {
  final String? name;
  final String? lastName;
  final String? birthday;
  final String? location;
  final String? gender;
  final String phone;
  final String id;
  final String? profilePicture;
  final String? deviceToken;
  final bool? isOnline;

  UserData(
      {this.name,
      this.lastName,
      this.birthday,
      this.location,
      this.gender,
      required this.phone,
      required this.id,
      this.profilePicture,
      this.deviceToken,
      this.isOnline});

  // To convert document data to user data
  factory UserData.toMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'] ?? '',
      lastName: map['last_name'] ?? '',
      birthday: map['birthday'] ?? '',
      location: map['location'] ?? '',
      gender: map['gender'] ?? '',
      phone: map['phone_number'] ?? '',
      id: map['id'] ?? '',
      profilePicture: map['profile_picture'] ?? '',
      deviceToken: map['device_token'] ?? '',
      isOnline: map['is_online'] ?? false,
    );
  }
}
