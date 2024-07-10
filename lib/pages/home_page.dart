import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chatacter/components/post_item.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/app_strings.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  List<String> users = [];

  @override
  Widget build(BuildContext context) {
    mockUsersFromServer();
    return Scaffold(
      appBar: ToolBar(
        title: AppStrings.appName,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.nearby);
              },
              icon: SvgPicture.asset(AppIcons.locationIcon))
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return PostItem(
            user: users[index],
          );
        },
        itemCount: users.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 24,
          );
        },
      ),
    );
  }

  mockUsersFromServer() {
    for (var i = 0; i < 500; i++) {
      users.add("User Number $i");
    }
  }
}
