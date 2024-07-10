import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final UserData arguments;
  final String lastMessage;
  final String timestamp;
  final String unreadMessages;
  final bool isSent;
  final bool? isImage;
  final bool? isOnline;

  const ChatItem({
    super.key,
    required this.arguments,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadMessages,
    required this.isSent,
    required this.isImage,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, AppRoutes.chat,
          arguments: arguments), // Use arguments here
      leading: Stack(children: [
        CircleAvatar(
          backgroundImage: arguments.profilePicture == null ||
                  arguments.profilePicture == ''
              ? Image.asset(AppIcons.userIcon).image
              : CachedNetworkImageProvider(
                  'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${arguments.profilePicture}/view?project=667d37b30023f69f7f74&mode=admin'),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            radius: 6,
            backgroundColor:
                isOnline == true ? Colors.green : Colors.grey.shade600,
          ),
        )
      ]),
      title: Text('${arguments.name!} ${arguments.lastName!}'),
      subtitle: Text(
        '${isSent ? 'You' : arguments.name}: ${isImage != null ? lastMessage : 'Sent an Image.'}',
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !isSent
              ? CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 10,
                  child: Text(
                    unreadMessages,
                    style: AppText.numberOfMessagesFont,
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 8,
          ),
          Text(timestamp)
        ],
      ),
    );
  }
}
