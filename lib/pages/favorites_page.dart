import 'package:chatacter/components/post_item.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatacter/providers/post_provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();

    // Trigger the loading of favorite posts once the page is initialized
    final userId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<PostProvider>(context, listen: false)
        .loadFavoritePosts(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ToolBar(title: AppStrings.favorites),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          final favoritePosts = postProvider.favoritePostsList;

          if (favoritePosts.isEmpty) {
            return Center(child: Text(AppStrings.noFavoritePostsFound));
          }

          return ListView.separated(
            itemBuilder: (context, index) {
              final post = favoritePosts[index];

              return PostItem(
                post: post,
                favorite: true, // Mark as favorite
              );
            },
            itemCount: favoritePosts.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 24);
            },
          );
        },
      ),
    );
  }
}
