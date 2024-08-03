import 'package:chatacter/models/post.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/styles/app_text.dart';

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Add this line
        children: [
          Row(
            children: [
              if (post.owner?.profilePicture != '')
                Image.network(
                  'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${post.owner?.profilePicture}/view?project=667d37b30023f69f7f74&mode=admin',
                  width: 40,
                  height: 40,
                ),
              SizedBox(
                width: 12,
              ),
              Text(
                '${post.owner?.name} ${post.owner?.lastName}',
                style: AppText.subtitle3,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert_outlined),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            alignment: AlignmentDirectional.topStart, // Add this line
            child: Text(
              style: (post.image != null && post.image!.isNotEmpty)
                  ? AppText.subtitle2
                  : AppText.header2,
              post.message ?? '',
              textAlign: TextAlign.start,
            ),
          ),
          if (post.image != null && post.image!.isNotEmpty)
            SizedBox(
              height: 12,
            ),
          if (post.image != null && post.image!.isNotEmpty)
            Image.network(
              'https://cloud.appwrite.io/v1/storage/buckets/66a7ad9d001be085ac46/files/${post.image}/view?project=667d37b30023f69f7f74&mode=admin',
            ),
          SizedBox(
            height: 12,
          ),
          Divider(
            height: 1,
            thickness: 2,
            color: AppColors.primary,
          )
        ],
      ),
    );
  }
}
