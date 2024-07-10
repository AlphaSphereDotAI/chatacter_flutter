import 'package:appwrite/models.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
  }

  //handle search
  void _handleSearch() {
    searchUsers(
            searchItem: _searchController.text,
            userId:
                Provider.of<UserDataProvider>(context, listen: false).getUserId)
        .then((value) {
      if (value != null) {
        setState(() {
          searchedUsers = value;
        });
      } else {
        setState(() {
          searchedUsers = DocumentList(total: 0, documents: []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(
            AppStrings.addFriends,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Container(
                decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(6)),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) => _handleSearch,
                        controller: _searchController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: AppStrings.enterPhoneNumber),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _handleSearch();
                        },
                        icon: Icon(Icons.search)),
                  ],
                ),
              )),
        ),
        body: searchedUsers.total == -1
            ? Center(
                child: Text(AppStrings.searchForFriends),
              )
            : searchedUsers.total == 0
                ? Center(
                    child: Text(AppStrings.noResultsFound),
                  )
                : ListView.builder(
                    itemCount: searchedUsers.documents.length,
                    itemBuilder: (context, index) {
                      print('Index Here: $index');
                      return ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.chat,
                                arguments: UserData.toMap(
                                    searchedUsers.documents[index].data));
                          },
                          leading: CircleAvatar(
                              backgroundImage: searchedUsers.documents[index]
                                              .data['profile_picture'] !=
                                          null &&
                                      searchedUsers.documents[index]
                                              .data['profile_picture'] !=
                                          ''
                                  ? NetworkImage(
                                      'https://cloud.appwrite.io/v1/storage/buckets/6683247c00056fdd9ceb/files/${searchedUsers.documents[index].data['profile_picture']}/view?project=667d37b30023f69f7f74&mode=admin')
                                  : Image.asset(AppIcons.userIcon).image),
                          title: Text(searchedUsers
                                  .documents[index].data['name'] +
                              ' ' +
                              searchedUsers.documents[index].data['last_name']),
                          subtitle: Text(searchedUsers
                              .documents[index].data['phone_number']));
                    }));
  }
}
