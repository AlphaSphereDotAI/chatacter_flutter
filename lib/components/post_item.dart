import 'package:flutter/material.dart';
import 'package:chatacter/styles/app_text.dart';

class PostItem extends StatelessWidget {
  final String user;

  const PostItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                "assets/temp/profilePic.jpeg",
                width: 40,
                height: 40,
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                user,
                style: AppText.subtitle3,
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Image.asset("assets/temp/post.jpg"),
          SizedBox(
            height: 12,
          ),
          Text(
              "The sun is a daily reminder that we too can rise from the darkness, that we too can shine our own light 🌞💖"),
        ],
      ),
    );
  }
}
