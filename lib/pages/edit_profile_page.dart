import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/components/app_textfield.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

enum Gender { none, male, female, other }

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  var gender = Gender.none;

  FilePickerResult? _filePickerResult;

  late String? imageId = '';
  late String? userId = '';

  final _nameKey = GlobalKey<FormState>();
  final _lastNameKey = GlobalKey<FormState>();
  final _locationKey = GlobalKey<FormState>();
  final _birthdayKey = GlobalKey<FormState>();

  bool _isDataLoaded = false;

  @override
  void initState() {
    // Try to load data from local database
    super.initState();
    Future.delayed(Duration.zero, () {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      userId = userDataProvider.getUserId;
      userDataProvider.loadUserData(userId!);
      imageId = userDataProvider.getUserProfilePicture;

      // Listen for changes in the user data
      userDataProvider.addListener(() {
        if (!_isDataLoaded) {
          setState(() {
            _isDataLoaded = true;
            switch (userDataProvider.getUserGender.toLowerCase()) {
              case 'male':
                gender = Gender.male;
                break;
              case 'female':
                gender = Gender.female;
                break;
              case 'other':
                gender = Gender.other;
                break;
              default:
                gender = Gender.none;
            }
          });
        }
      });
    });
  }

  // To open the file picker
  void _openFilePicker() async {
    var storageStatus = await permission.Permission.storage.status;
    if (!storageStatus.isGranted) {
      await permission.Permission.storage.request();
    }

    storageStatus = await permission
        .Permission.storage.status; // Re-check the permission status
    if (storageStatus.isGranted) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      setState(() {
        _filePickerResult = result;
      });
    } else {
      // Handle the case where permission is denied
      print('Storage permission is denied.');
    }
  }

  // Upload user profile image and save it to database
  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file = _filePickerResult!.files.first;
        final fileBytes = await File(file.path!).readAsBytes();
        final inputFile =
            InputFile.fromBytes(bytes: fileBytes, filename: file.name);

        // if the image already exists for user profile
        if (imageId != null && imageId != '') {
          //then update the image
          await updateImageOnBucket(oldImageId: imageId!, image: inputFile)
              .then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        } else {
          // create a new image and upload it to bucket
          await saveImageToBucket(image: inputFile).then((value) {
            if (value != null) {
              imageId = value;
            }
          });
        }
      } else {
        print('Something went wrong');
      }
    } catch (e) {
      print('Error when uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dataPassed =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Consumer<UserDataProvider>(builder: (context, value, child) {
      // Set the text controllers' values only if they are empty
      if (_nameController.text.isEmpty) {
        _nameController.text = value.getUserName;
      }
      if (_lastNameController.text.isEmpty) {
        _lastNameController.text = value.getUserLastName;
      }
      if (_locationController.text.isEmpty) {
        _locationController.text = value.getUserLocation;
      }
      if (_birthdayController.text.isEmpty) {
        _birthdayController.text = value.getUserBirthday;
      }
      if (_phoneNumberController.text.isEmpty) {
        _phoneNumberController.text = value.getUserPhone;
      }

      return Scaffold(
        appBar: ToolBar(
          title: dataPassed['title'] == 'edit'
              ? AppStrings.editProfile
              : AppStrings.addDetails,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 90,
                      backgroundImage: _filePickerResult != null
                          ? Image(
                                  image: FileImage(File(
                                      _filePickerResult!.files.first.path!)))
                              .image
                          : value.getUserProfilePicture != ''
                              ? CachedNetworkImageProvider(
                                  'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${value.getUserProfilePicture}/view?project=667d37b30023f69f7f74&mode=admin')
                              : Image(image: AssetImage(AppIcons.userIcon))
                                  .image,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _openFilePicker();
                        },
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Icon(
                              Icons.edit,
                              size: 25,
                              color: AppColors.black,
                            )),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: _nameKey,
                        child: AppTextfield(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Can\'t be empty!';
                            }
                            return null;
                          },
                          hint: AppStrings.firstName,
                          controller: _nameController,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Form(
                        key: _lastNameKey,
                        child: AppTextfield(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Can\'t be empty!';
                            }
                            return null;
                          },
                          hint: AppStrings.lastName,
                          controller: _lastNameController,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                AppTextfield(
                  hint: AppStrings.phoneNumber,
                  enabled: false,
                  controller: _phoneNumberController,
                ),
                SizedBox(
                  height: 16,
                ),
                Form(
                  key: _locationKey,
                  child: AppTextfield(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Can\'t be empty!';
                      }
                      return null;
                    },
                    hint: AppStrings.location,
                    controller: _locationController,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Form(
                  key: _birthdayKey,
                  child: AppTextfield(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Can\'t be empty!';
                      }
                      return null;
                    },
                    hint: AppStrings.birthday,
                    controller: _birthdayController,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: EdgeInsets.only(left: 12, right: 12, top: 6),
                  decoration: BoxDecoration(
                      color: AppColors.fieldColor,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.gender,
                        style: AppText.body1,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile(
                              activeColor: AppColors.fieldCursorColor,
                              visualDensity: VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity),
                              contentPadding: EdgeInsets.all(0),
                              title: Text(
                                AppStrings.male,
                                style: AppText.body1,
                              ),
                              value: Gender.male,
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = Gender.male;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              activeColor: AppColors.fieldCursorColor,
                              visualDensity: VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity),
                              contentPadding: EdgeInsets.all(0),
                              title: Text(
                                AppStrings.female,
                                style: AppText.body1,
                              ),
                              value: Gender.female,
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = Gender.female;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              activeColor: AppColors.fieldCursorColor,
                              visualDensity: VisualDensity(
                                  horizontal: VisualDensity.minimumDensity,
                                  vertical: VisualDensity.minimumDensity),
                              contentPadding: EdgeInsets.all(0),
                              title: Text(
                                AppStrings.other,
                                style: AppText.body1,
                              ),
                              value: Gender.other,
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = Gender.other;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onPressed: () async {
                          if (_nameKey.currentState!.validate() &&
                              _lastNameKey.currentState!.validate() &&
                              _locationKey.currentState!.validate() &&
                              _birthdayKey.currentState!.validate()) {
                            if (gender == Gender.none) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please select your gender'),
                                ),
                              );
                              return;
                            }
                            // upload the image if file is picked
                            if (_filePickerResult != null) {
                              await uploadProfileImage();
                            }
                            // save the data to database
                            await updateUserDetails(
                                imageId ?? '', _locationController.text,
                                id: userId!,
                                name: _nameController.text,
                                lastName: _lastNameController.text,
                                birthday: _birthdayController.text,
                                gender: gender == Gender.male
                                    ? 'male'
                                    : gender == Gender.female
                                        ? 'female'
                                        : 'other');

                            dataPassed['title'] == 'edit'
                                ? ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Updated Successfully'),
                                    ),
                                  )
                                :
                                //Navigate user to main
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.main, (route) => false);
                          }
                        },
                        child: Text(
                          AppStrings.save,
                          style: TextStyle(color: AppColors.black),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
