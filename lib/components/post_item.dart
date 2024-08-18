import 'package:chatacter/components/new_post_model.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/models/post.dart';
import 'package:chatacter/providers/post_provider.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/styles/app_text.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  final Post post;
  final bool favorite;

  const PostItem({super.key, required this.post, required this.favorite});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late String currentUserId;

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Align items on the left and right
            children: [
              Row(
                children: [
                  if (widget.post.owner?.profilePicture != '')
                    Image.network(
                      'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${widget.post.owner?.profilePicture}/view?project=667d37b30023f69f7f74&mode=admin',
                      width: 40,
                      height: 40,
                    ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    '${widget.post.owner?.name} ${widget.post.owner?.lastName}',
                    style: AppText.subtitle3,
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (String value) async {
                  switch (value) {
                    case 'save':
                      bool success = await addToFavorites(
                          userId: currentUserId, postId: widget.post.id!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppStrings.postAddedToFavorites)),
                        );
                      }
                      break;
                    case 'edit':
                      if (widget.post.owner?.id == currentUserId) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return NewPostModal(
                                postId: widget
                                    .post.id, // Pass the post ID if editing
                                initialMessage: widget
                                    .post.message, // Pass the initial message
                                initialImageUrl: widget.post.image);
                          },
                        );
                      }
                      break;
                    case 'delete':
                      if (widget.post.owner?.id == currentUserId) {
                        String postId = widget.post.id!;
                        await context
                            .read<PostProvider>()
                            .deletePost(postId: postId);
                      }
                      break;
                    case 'remove from favorites':
                      await context
                          .read<PostProvider>()
                          .removePostFromFavorites(
                              userId: currentUserId, postId: widget.post.id!);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    if (widget.favorite)
                      const PopupMenuItem<String>(
                        value: 'remove from favorites',
                        child: Row(
                          children: [
                            Icon(
                              Icons.playlist_remove_outlined,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(AppStrings.removeFromFavorites),
                          ],
                        ),
                      ),
                    if (!widget.favorite)
                      const PopupMenuItem<String>(
                        value: 'save',
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_outline_sharp,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(AppStrings.saveToFavorites),
                          ],
                        ),
                      ),
                    if (widget.post.owner?.id == currentUserId &&
                        !widget.favorite)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(AppStrings.editPost),
                          ],
                        ),
                      ),
                    if (widget.post.owner?.id == currentUserId &&
                        !widget.favorite)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(AppStrings.deletePost),
                          ],
                        ),
                      ),
                  ];
                },
                icon: Icon(Icons.more_vert_outlined),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            alignment: AlignmentDirectional.topStart,
            child: Text(
              style:
                  (widget.post.image != null && widget.post.image!.isNotEmpty)
                      ? AppText.subtitle2
                      : AppText.header2,
              widget.post.message ?? '',
              textAlign: TextAlign.start,
            ),
          ),
          if (widget.post.image != null && widget.post.image!.isNotEmpty)
            SizedBox(
              height: 12,
            ),
          if (widget.post.image != null && widget.post.image!.isNotEmpty)
            Image.network(
              'https://cloud.appwrite.io/v1/storage/buckets/66a7ad9d001be085ac46/files/${widget.post.image}/view?project=667d37b30023f69f7f74&mode=admin',
            ),
          SizedBox(
            height: 12,
          ),
          Divider(
            height: 1,
            thickness: 2,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
