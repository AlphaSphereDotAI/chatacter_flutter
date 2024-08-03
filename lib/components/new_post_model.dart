import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:chatacter/components/app_textfield.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class NewPostModal extends StatefulWidget {
  const NewPostModal({super.key});

  @override
  State<NewPostModal> createState() => _NewPostModalState();
}

class _NewPostModalState extends State<NewPostModal> {
  FilePickerResult? _filePickerResult;
  TextEditingController postMessageController = TextEditingController();

  late String? userId = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      userId = userDataProvider.getUserId;
    });
  }

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

  Future<String?> uploadPostImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file = _filePickerResult!.files.first;
        final fileBytes = await File(file.path!).readAsBytes();
        final inputFile =
            InputFile.fromBytes(bytes: fileBytes, filename: file.name);

        // Create a new image and upload it to the bucket
        final imageUrl = await savePostImageToBucket(image: inputFile);
        return imageUrl;
      } else {
        print('No image selected.');
        return null;
      }
    } catch (e) {
      print('Error when uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openFilePicker();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.insertMessage,
              style: AppText.header1,
            ),
            SizedBox(
              height: 16,
            ),
            AppTextfield(
              hint: AppStrings.whatAreYouThinkingAbout,
              controller: postMessageController,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              AppStrings.addImage,
              style: AppText.header1,
            ),
            SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                _openFilePicker();
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: _filePickerResult != null
                      ? Image.file(
                          File(_filePickerResult!.files.first.path!),
                          fit: BoxFit.cover,
                        )
                      : Text(AppStrings.uploadFromGallery),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                // Upload image if available and get the URL
                final imageUrl = await uploadPostImage();
                createPost(
                  message: postMessageController.text,
                  ownerId: userId!,
                  image: imageUrl ?? '',
                );
              },
              child: Text(
                AppStrings.publish,
                style: AppText.subtitle3,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
