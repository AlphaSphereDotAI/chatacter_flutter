import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/characters/characters.dart';
import 'package:chatacter/characters/llm.dart';
import 'package:chatacter/components/message_item.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/models/message.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:chatacter/providers/chat_provider.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editMessageController = TextEditingController();

  late String currentUserId;
  late String currentUserName;

  late LLM _llm;
  List<Map<String, String>> chatHistory = [];

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<UserDataProvider>(context, listen: false).getUserName;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    super.initState();
  }

  // to open file picker
  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  // to upload files to our storage bucket and our database
  void uploadAllImage(UserData receiver) async {
    if (_filePickerResult != null) {
      for (var path in _filePickerResult!.paths) {
        if (path != null) {
          var file = File(path);
          final fileBytes = file.readAsBytesSync();
          final inputfile = InputFile.fromBytes(
              bytes: fileBytes, filename: file.path.split("/").last);

          // saving image to our storage bucket
          saveImageToBucket(image: inputfile).then((imageId) {
            if (imageId != null) {
              createNewChat(
                message: imageId,
                senderId: currentUserId,
                receiverId: receiver.id,
                isImage: true,
              ).then((value) {
                if (value) {
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      Message(
                        message: imageId,
                        sender: currentUserId,
                        receiver: receiver.id,
                        timestamp: DateTime.now(),
                        isSeenByReceiver: false,
                        isImage: false,
                      ),
                      currentUserId,
                      [UserData(phone: "", id: currentUserId), receiver]);
                  // sendNotificationtoOtherUser(
                  //     notificationTitle: '$currentUserName sent you an image',
                  //     notificationBody: "check it out.",
                  //     deviceToken: receiver.deviceToken!);
                }
              });
            }
          });
        }
      }
    } else {
      print("file pick cancelled by user");
    }
  }

  void _sendMessageToLLM({required UserData receiver}) async {
    chatHistory = [
      {
        "role": "system",
        "content":
            "You are ${AiCharacters.characters[receiver.id]}. Respond to the user's questions and comments as ${AiCharacters.characters[receiver.id]} would, without explicitly stating that you are ${AiCharacters.characters[receiver.id]}. use very short sentences."
      }
    ];
    _llm = LLM();

    if (messageController.text.isNotEmpty) {
      setState(() {
        chatHistory.add({"role": "user", "content": messageController.text});

        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.id,
                isImage: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                Message(
                    message: messageController.text,
                    sender: currentUserId,
                    receiver: receiver.id,
                    timestamp: DateTime.now(),
                    isSeenByReceiver: false),
                currentUserId,
                [UserData(phone: '', id: currentUserId), receiver]);
            messageController.clear();
          }
        });
      });

      final responseContent = await _llm.sendPostRequest(chatHistory);
      setState(() {
        chatHistory.add({"role": "assistant", "content": responseContent});

        createNewChat(
                message: responseContent,
                senderId: receiver.id,
                receiverId: currentUserId,
                isImage: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                Message(
                    message: responseContent,
                    sender: receiver.id,
                    receiver: currentUserId,
                    timestamp: DateTime.now(),
                    isSeenByReceiver: false),
                receiver.id,
                [receiver, UserData(phone: '', id: currentUserId)]);
            messageController.clear();
          }
        });
      });
    }
  }

  //to send a text messages
  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.id,
                isImage: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                Message(
                    message: messageController.text,
                    sender: currentUserId,
                    receiver: receiver.id,
                    timestamp: DateTime.now(),
                    isSeenByReceiver: false),
                currentUserId,
                [UserData(phone: '', id: currentUserId), receiver]);
            messageController.clear();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChat[receiver.id] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].id == receiver.id
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        List<String> receivedMessagesList = [];

        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              receivedMessagesList.add(chat.message.id!);
            }
          }
        }

        updateIsSeen(chatsIds: receivedMessagesList);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.videocam_rounded),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.videoCall,
                    arguments: receiver,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.voiceCall,
                    arguments: receiver,
                  );
                  // Add your voice call logic here
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Add your settings logic here
                },
              ),
            ],
            backgroundColor: AppColors.background,
            leadingWidth: 40,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: receiver.profilePicture == null ||
                          receiver.profilePicture == null
                      ? Image.asset(AppIcons.userIcon).image
                      : CachedNetworkImageProvider(
                          'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${receiver.profilePicture}/view?project=667d37b30023f69f7f74&mode=admin'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style: AppText.friendChatNameFont,
                    ),
                    Text(
                      otherUserOnline == true
                          ? AppStrings.online
                          : AppStrings.offline,
                      style: AppText.onlineFont,
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        reverse: true,
                        itemCount: userAndOtherChats.length,
                        itemBuilder: (context, index) {
                          final msg = userAndOtherChats[
                                  userAndOtherChats.length - 1 - index]
                              .message;
                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: msg.isImage == true
                                      ? const Text(
                                          AppStrings.chooseWhatToDoWithImage)
                                      : Text(
                                          '${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ...'),
                                  content: msg.isImage == true
                                      ? Text(msg.sender == currentUserId
                                          ? AppStrings.delete
                                          : AppStrings.cantBeDeleted)
                                      : Text(msg.sender == currentUserId
                                          ? AppStrings.chooseWhatToDoWithMessage
                                          : AppStrings.cantBeDeleted),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(AppStrings.cancel)),
                                    msg.sender == currentUserId
                                        ? TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              editMessageController.text =
                                                  msg.message;

                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: const Text(
                                                            AppStrings
                                                                .editThisMessage),
                                                        content: TextFormField(
                                                          controller:
                                                              editMessageController,
                                                          maxLines: 10,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              editChat(
                                                                  chatId:
                                                                      msg.id!,
                                                                  message:
                                                                      editMessageController
                                                                          .text);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              editMessageController
                                                                  .text = '';
                                                            },
                                                            child: const Text(
                                                                AppStrings
                                                                    .edit),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                AppStrings
                                                                    .cancel),
                                                          ),
                                                        ],
                                                      ));
                                            },
                                            child: const Text(AppStrings.edit))
                                        : const SizedBox(),
                                    msg.sender == currentUserId
                                        ? TextButton(
                                            onPressed: () {
                                              Provider.of<ChatProvider>(context,
                                                      listen: false)
                                                  .deleteMessage(
                                                msg,
                                                currentUserId,
                                              );
                                              Navigator.pop(context);
                                            },
                                            child:
                                                const Text(AppStrings.delete))
                                        : const SizedBox(),
                                  ],
                                ),
                              );
                            },
                            child: MessageItem(
                                message: msg,
                                currentUser: currentUserId,
                                isImage: msg.isImage ?? false),
                          );
                        }),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) {
                          _sendMessage(receiver: receiver);
                        },
                        controller: messageController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: AppStrings.typeMessage,
                            hintStyle: TextStyle(color: AppColors.secondary)),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _openFilePicker(receiver);
                        },
                        icon: const Icon(Icons.image,
                            color: AppColors.secondary)),
                    IconButton(
                      onPressed: () {
                        if (AiCharacters.charactersIds
                            .contains(receiver.id.toString().trim())) {
                          _sendMessageToLLM(receiver: receiver);
                        } else {
                          _sendMessage(receiver: receiver);
                        }
                      },
                      icon: const Icon(Icons.send, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
