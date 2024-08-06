import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:chatacter/components/extendable_text_field.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/providers/post_provider.dart';
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
  String? userId;
  bool _isPosting = false; // Track the posting state
  double _initialChildSize = 0.62; // Default initial size
  late FocusNode _focusNode;
  int _minLines = 1; // Initial minLines value

  @override
  void initState() {
    super.initState();

    // Initialize the FocusNode
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          // Ensure _minLines is updated correctly
          _minLines = _focusNode.hasFocus ? 4 : 1;
          // Update the initial size when the TextField gains or loses focus
          _initialChildSize = _focusNode.hasFocus ? 0.9 : 0.62;
        });
      });

    // Use WidgetsBinding to ensure userId is set after the build context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      userId = userDataProvider.getUserId;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the FocusNode
    postMessageController.dispose();
    super.dispose();
  }

  void _openFilePicker() async {
    var storageStatus = await permission.Permission.storage.status;
    if (!storageStatus.isGranted) {
      await permission.Permission.storage.request();
    }

    storageStatus = await permission.Permission.storage.status;
    if (storageStatus.isGranted) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      setState(() {
        _filePickerResult = result;
      });
    } else {
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: _initialChildSize, // Use the dynamic size
      minChildSize: 0.3, // Minimum height of the sheet
      maxChildSize: 1.0, // Maximum height of the sheet
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
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
                // Container to control the minimum height of the TextField
                ExtendableTextField(
                  hint: AppStrings.whatAreYouThinkingAbout,
                  controller: postMessageController,
                  focusNode: _focusNode, // Attach the focus node
                  minLines: _minLines, // Set the minLines value
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
                  onPressed: _isPosting
                      ? null
                      : () async {
                          setState(() {
                            _isPosting = true; // Start posting
                          });
                          final imageUrl = await uploadPostImage();
                          if (imageUrl != null && userId != null) {
                            final postProvider = Provider.of<PostProvider>(
                                context,
                                listen: false);
                            await postProvider.createNewPost(
                              message: postMessageController.text,
                              ownerId: userId!,
                              timeStamp: DateTime.now(),
                              image: imageUrl,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Post Published Successfully'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error publishing post'),
                              ),
                            );
                          }
                          setState(() {
                            _isPosting = false; // Reset button state
                          });
                        },
                  child: _isPosting
                      ? CircularProgressIndicator(
                          color: Colors.white) // Show loading spinner
                      : Text(
                          AppStrings.publish,
                          style: AppText.subtitle2,
                        ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    backgroundColor:
                        AppColors.primary, // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 14), // Button padding
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
