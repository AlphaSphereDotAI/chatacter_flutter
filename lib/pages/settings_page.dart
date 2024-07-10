import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/data/local_saved_data.dart';
import 'package:chatacter/providers/chat_provider.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          AppStrings.profile,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.editProfile, arguments: {'title': 'edit'}),
            leading:
                Consumer<UserDataProvider>(builder: (context, value, child) {
              return CircleAvatar(
                backgroundImage: value.getUserProfilePicture != ''
                    ? CachedNetworkImageProvider(
                        'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${Provider.of<UserDataProvider>(context, listen: false).getUserProfilePicture}/view?project=667d37b30023f69f7f74&mode=admin')
                    : Image(image: AssetImage(AppIcons.userIcon)).image,
              );
            }),
            title: Text(
              Provider.of<UserDataProvider>(context, listen: false)
                      .getUserName +
                  ' ' +
                  Provider.of<UserDataProvider>(context, listen: false)
                      .getUserLastName,
            ),
            subtitle: Text(Provider.of<UserDataProvider>(context, listen: false)
                .getUserPhone),
            trailing: Icon(Icons.edit_outlined),
          ),
          Divider(),
          ListTile(
            onTap: () async {
              updateOnlineStatus(
                  status: false,
                  userId: Provider.of<UserDataProvider>(context, listen: false)
                      .getUserId);
              await LocalSavedData.clearAllData();
              Provider.of<UserDataProvider>(context, listen: false)
                  .clearAllProviders();
              Provider.of<ChatProvider>(context, listen: false).clearChats();
              await logoutUser();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            leading: Icon(Icons.logout_outlined),
            title: Text(AppStrings.logOut),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppStrings.about),
          ),
        ],
      ),
    );
  }
}
