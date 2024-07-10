import 'package:chatacter/components/chat_item.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/functions/format_date.dart';
import 'package:chatacter/models/chat.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:chatacter/providers/chat_provider.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late String currentUserId = '';

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    updateOnlineStatus(status: true, userId: currentUserId);

    subscribeToRealtime(userId: currentUserId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ToolBar(
          title: AppStrings.chats,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.friends);
              },
              icon: Icon(Icons.person_add_alt),
              iconSize: 30,
            )
          ],
        ),
        body: Consumer<ChatProvider>(builder: (context, value, child) {
          if (value.getAllChat.isEmpty) {
            return Center(child: Text(AppStrings.noChats));
          } else {
            List othertUsers = value.getAllChat.keys.toList();

            return ListView.builder(
                itemCount: othertUsers.length,
                itemBuilder: (context, index) {
                  List<Chat> chatData = value.getAllChat[othertUsers[index]]!;
                  int totalChats = chatData.length;

                  UserData otherUser = chatData[0].users[0].id == currentUserId
                      ? chatData[0].users[1]
                      : chatData[0].users[0];

                  int unreadMessages = 0;
                  chatData.fold(unreadMessages, (previousValue, element) {
                    if (element.message.isSeenByReceiver == false) {
                      unreadMessages++;
                    }
                    return unreadMessages;
                  });

                  return ChatItem(
                      arguments: otherUser,
                      lastMessage: chatData[totalChats - 1].message.message,
                      isImage: chatData[totalChats - 1].message.isImage,
                      timestamp: formatDate(
                          chatData[totalChats - 1].message.timestamp),
                      unreadMessages: unreadMessages.toString(),
                      isSent: chatData[totalChats - 1].message.sender ==
                          currentUserId,
                      isOnline: otherUser.isOnline == true);
                });
          }
        }));
  }
}
