import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData {
  static SharedPreferences? preferences;

  //initialize
  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  //save the user id
  static Future<void> saveUserId(String id) async {
    await preferences!.setString("id", id);
  }

  static String getUserId() {
    return preferences!.getString('id') ?? '';
  }

  //save the user name
  static Future<void> saveUserName(String name) async {
    await preferences!.setString("name", name);
  }

  static String getUserName() {
    return preferences!.getString('name') ?? '';
  }

  //save the user last name
  static Future<void> saveUserLastName(String lastName) async {
    await preferences!.setString("lastName", lastName);
  }

  static String getUserLastName() {
    return preferences!.getString('lastName') ?? '';
  }

  //save the user birthday
  static Future<void> saveUserBirthday(String birthday) async {
    await preferences!.setString("birthday", birthday);
  }

  static String getUserBirthday() {
    return preferences!.getString('birthday') ?? '';
  }

  //save the user location
  static Future<void> saveUserLocation(String location) async {
    await preferences!.setString("location", location);
  }

  static String getUserLocation() {
    return preferences!.getString('location') ?? '';
  }

  //save the user gender
  static Future<void> saveUserGender(String gender) async {
    await preferences!.setString("gender", gender);
  }

  static String getUserGender() {
    return preferences!.getString('gender') ?? '';
  }

  //save the user id
  static Future<void> saveUserPhone(String phone) async {
    await preferences!.setString("Phone", phone);
  }

  static String getUserPhone() {
    return preferences!.getString('Phone') ?? '';
  }

  //save the user id
  static Future<void> saveUserProfilePicture(String picture) async {
    await preferences!.setString("profilePicture", picture);
  }

  static String getUserProfilePicture() {
    return preferences!.getString('profilePicture') ?? '';
  }

  static clearAllData() async {
    final bool data = await preferences!.clear();
    print('Cleared all data from local: $data');
  }
}
