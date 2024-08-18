import 'package:chatacter/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chatacter/components/post_item.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          // print('Consumer Invoked');
          if (postProvider.posts.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                postProvider.loadMorePosts();
              }
              return true;
            },
            child: ListView.separated(
              itemBuilder: (context, index) {
                return PostItem(
                  post: postProvider.posts[index],
                  favorite: false,
                );
              },
              itemCount: postProvider.posts.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 24,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
