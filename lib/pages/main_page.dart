import 'package:chatacter/components/new_post_model.dart';
import 'package:chatacter/pages/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chatacter/components/bottom_navigation_item.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/pages/home_page.dart';
import 'package:chatacter/pages/profile_page.dart';
import 'package:chatacter/styles/app_colors.dart';

enum BottomNavigationPages { home, favorite, add, chat, profile }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BottomNavigationPages selectedIndex = BottomNavigationPages.home;

  void _refreshPosts() {
    setState(() {
      // This will rebuild the HomePage and reload posts
    });
  }

  @override
  Widget build(BuildContext context) {
    // FocusScope.of(context).unfocus();
    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex.index],
      bottomNavigationBar: MyNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          if (value == BottomNavigationPages.add) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return NewPostModal();
                });
            return;
          }
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }

  final pages = [
    HomePage(),
    Center(
        child: Text(
      "Favorite",
      style: TextStyle(fontSize: 32),
    )),
    Center(
      child: Text(
        "Add",
        style: TextStyle(fontSize: 32),
      ),
    ),
    ChatsPage(),
    ProfilePage(),
  ];
}

class MyNavigationBar extends StatelessWidget {
  final BottomNavigationPages currentIndex;
  final ValueChanged<BottomNavigationPages> onTap;

  const MyNavigationBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 87,
      margin: EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            left: 0,
            top: 17,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () => onTap(BottomNavigationPages.home),
                      icon: AppIcons.homeIcon,
                      current: currentIndex,
                      pageName: BottomNavigationPages.home,
                    ),
                  ),
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () => onTap(BottomNavigationPages.favorite),
                      icon: AppIcons.favoriteIcon,
                      current: currentIndex,
                      pageName: BottomNavigationPages.favorite,
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () => onTap(BottomNavigationPages.chat),
                      icon: AppIcons.chatIcon,
                      current: currentIndex,
                      pageName: BottomNavigationPages.chat,
                    ),
                  ),
                  Expanded(
                    child: BottomNavigationItem(
                      onPressed: () => onTap(BottomNavigationPages.profile),
                      icon: AppIcons.profileIcon,
                      current: currentIndex,
                      pageName: BottomNavigationPages.profile,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(BottomNavigationPages.add),
              child: Container(
                height: 64,
                width: 64,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: SvgPicture.asset(AppIcons.addIcon),
              ),
            ),
          )
        ],
      ),
    );
  }
}
