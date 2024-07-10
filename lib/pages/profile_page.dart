import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:provider/provider.dart';

enum ProfileMenu { edit, logout }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? imageId = '';
  late String? userId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToolBar(
        title: "Profile",
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          Consumer<UserDataProvider>(builder: (context, value, child) {
            return CircleAvatar(
              radius: 90,
              backgroundImage: value.getUserProfilePicture != ''
                  ? CachedNetworkImageProvider(
                      'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${Provider.of<UserDataProvider>(context, listen: false).getUserProfilePicture}/view?project=667d37b30023f69f7f74&mode=admin')
                  : Image(image: AssetImage(AppIcons.userIcon)).image,
            );
          }),
          SizedBox(
            height: 24,
          ),
          Text(
            Provider.of<UserDataProvider>(context, listen: false).getUserName +
                ' ' +
                Provider.of<UserDataProvider>(context, listen: false)
                    .getUserLastName,
            style: AppText.header2,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            Provider.of<UserDataProvider>(context, listen: false)
                .getUserLocation,
            style: AppText.subtitle3,
          ),
          SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    "472",
                    style: AppText.header2,
                  ),
                  Text("Followers"),
                ],
              ),
              Column(
                children: [
                  Text(
                    "119",
                    style: AppText.header2,
                  ),
                  Text("Posts"),
                ],
              ),
              Column(
                children: [
                  Text(
                    "860",
                    style: AppText.header2,
                  ),
                  Text("Following"),
                ],
              ),
            ],
          ),
          Divider(
            thickness: 1,
            height: 24,
          ),
        ],
      ),
    );
  }
}
