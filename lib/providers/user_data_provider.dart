import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/data/local_saved_data.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:flutter/material.dart';

class UserDataProvider extends ChangeNotifier {
  String _userId = '';
  String _userName = '';
  String _userLastName = '';
  String _userBirthday = '';
  String _userLocation = '';
  String _userGender = '';
  String _userPhone = '';
  String _userProfilePicture = '';
  String _userDeviceToken = '';

  String get getUserId => _userId;
  String get getUserName => _userName;
  String get getUserLastName => _userLastName;
  String get getUserBirthday => _userBirthday;
  String get getUserLocation => _userLocation;
  String get getUserGender => _userGender;
  String get getUserPhone => _userPhone;
  String get getUserProfilePicture => _userProfilePicture;
  String get getUserDeviceToken => _userDeviceToken;

  // To load the data from local device
  Future<void> loadDataFromLocal() async {
    _userId = LocalSavedData.getUserId();
    _userName = LocalSavedData.getUserName();
    _userLastName = LocalSavedData.getUserLastName();
    _userBirthday = LocalSavedData.getUserBirthday();
    _userLocation = LocalSavedData.getUserLocation();
    _userGender = LocalSavedData.getUserGender();
    _userPhone = LocalSavedData.getUserPhone();
    _userProfilePicture = LocalSavedData.getUserProfilePicture();

    print(
        'Data loaded from local:\nID: $_userId\nName: $_userName\nLastname: $_userLastName\nBirthday: $_userBirthday\nLocation: $_userLocation\nGender: $_userGender\nPhone: $_userPhone');

    notifyListeners();
  }

  // To load the data from our AppWrite database
  Future<void> loadUserData(String userId) async {
    UserData? user = await getUserDetails(userId: userId);
    if (user != null) {
      _userName = user.name ?? '';
      _userLastName = user.lastName ?? '';
      _userBirthday = user.birthday ?? '';
      _userLocation = user.location ?? '';
      _userGender = user.gender ?? '';
      _userProfilePicture = user.profilePicture ?? '';
      notifyListeners();
    }
  }

  void setUserId(String id) {
    _userId = id;
    LocalSavedData.saveUserId(id);
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    LocalSavedData.saveUserName(name);
    notifyListeners();
  }

  void setUserLastName(String lastName) {
    _userLastName = lastName;
    LocalSavedData.saveUserLastName(lastName);
    notifyListeners();
  }

  void setUserBirthday(String birthday) {
    _userBirthday = birthday;
    LocalSavedData.saveUserBirthday(birthday);
    notifyListeners();
  }

  void setUserLocation(String location) {
    _userLocation = location;
    LocalSavedData.saveUserLocation(location);
    notifyListeners();
  }

  void setUserGender(String gender) {
    _userGender = gender;
    LocalSavedData.saveUserGender(gender);
    notifyListeners();
  }

  void setUserPhone(String phone) {
    _userPhone = phone;
    LocalSavedData.saveUserPhone(phone);
    notifyListeners();
  }

  void setUserProfilePicture(String picture) {
    _userProfilePicture = picture;
    LocalSavedData.saveUserProfilePicture(picture);
    notifyListeners();
  }

  void setUserDeviceToken(String token) {
    _userDeviceToken = token;
    notifyListeners();
  }

  void clearAllProviders() {
    _userId = '';
    _userName = '';
    _userLastName = '';
    _userBirthday = '';
    _userGender = '';
    _userProfilePicture = '';
    _userLocation = '';
    _userDeviceToken = '';
    _userPhone = '';

    notifyListeners();
  }
}
