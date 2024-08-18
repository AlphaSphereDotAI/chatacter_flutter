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
  final String? postId;
  final String? initialMessage;
  final String? initialImageUrl;

  const NewPostModal({
    super.key,
    this.postId,
    this.initialMessage,
    this.initialImageUrl,
  });

  @override
  State<NewPostModal> createState() => _NewPostModalState();
}

class _NewPostModalState extends State<NewPostModal> {
  late String? userId;

  FilePickerResult? _filePickerResult;
  late TextEditingController postMessageController;
  bool _isPosting = false;
  double _initialChildSize = 0.62;
  late FocusNode _focusNode;
  int _minLines = 1;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserDataProvider>(context, listen: false).getUserId;

    // Initialize the FocusNode
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          _minLines = _focusNode.hasFocus ? 4 : 1;
          _initialChildSize = _focusNode.hasFocus ? 0.9 : 0.62;
        });
      });

    postMessageController = TextEditingController(text: widget.initialMessage);
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
      initialChildSize: _initialChildSize,
      minChildSize: 0.3,
      maxChildSize: 1.0,
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
                  widget.postId == null
                      ? AppStrings.insertMessage
                      : 'Edit Message',
                  style: AppText.header1,
                ),
                SizedBox(height: 16),
                ExtendableTextField(
                  hint: AppStrings.whatAreYouThinkingAbout,
                  controller: postMessageController,
                  focusNode: _focusNode,
                  minLines: _minLines,
                ),
                SizedBox(height: 16),
                Text(
                  AppStrings.addImage,
                  style: AppText.header1,
                ),
                SizedBox(height: 16),
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
                          : (widget.initialImageUrl != null
                              ? Image.network(
                                  'https://cloud.appwrite.io/v1/storage/buckets/66a7ad9d001be085ac46/files/${widget.initialImageUrl!}/view?project=667d37b30023f69f7f74&mode=admin',
                                  fit: BoxFit.cover,
                                )
                              : Text(AppStrings.uploadFromGallery)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          setState(() {
                            _isPosting = true;
                          });
                          final imageUrl = await uploadPostImage();
                          final postProvider =
                              Provider.of<PostProvider>(context, listen: false);
                          if (widget.postId == null) {
                            // Create new post
                            await postProvider.createNewPost(
                              message: postMessageController.text,
                              ownerId: userId!,
                              timeStamp: DateTime.now(),
                              image: imageUrl ?? widget.initialImageUrl!,
                            );
                          } else {
                            // Edit existing post
                            await postProvider.editPost(
                              postId: widget.postId!,
                              message: postMessageController.text,
                              image: imageUrl ?? widget.initialImageUrl,
                            );
                          }
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.postId == null
                                  ? 'Post Published Successfully'
                                  : 'Post Updated Successfully'),
                            ),
                          );
                          setState(() {
                            _isPosting = false;
                          });
                        },
                  child: _isPosting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.postId == null ? AppStrings.publish : 'Update',
                          style: AppText.subtitle2,
                        ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
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
