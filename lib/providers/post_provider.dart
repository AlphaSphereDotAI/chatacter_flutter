import 'package:appwrite/appwrite.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/models/post.dart';

class PostProvider extends ChangeNotifier {
  List<Post> postsList = [];
  int _currentPage = 1;
  bool _hasMorePosts = true;
  final int _postsPerPage = 200;

  List<Post> get posts => postsList;

  // Load posts with pagination
  Future<void> loadPosts({int page = 1}) async {
    if (!_hasMorePosts && page != 1) return; // No more posts to load

    try {
      final result = await getAllPosts(page: page, limit: _postsPerPage);
      if (result != null) {
        List<Post> newPosts =
            await Future.wait(result.documents.map((doc) async {
          final data = doc.data;
          final userId = data['owner_id'] as String;
          final user =
              await getUserData(userId: userId); // Fetch UserData by userId

          // Handle the time_stamp field conversion
          DateTime? timeStamp;
          if (data['time_stamp'] != null) {
            timeStamp = DateTime.parse(data['time_stamp'] as String);
          }

          return Post(
            id: data['id'],
            message: data['message'],
            owner: user,
            timeStamp: timeStamp, // Assign parsed DateTime
            image: data['image'] ?? '', // Handle null image gracefully
          );
        }).toList());

        if (newPosts.isEmpty) {
          _hasMorePosts = false; // No more posts to load
        } else {
          if (page == 1) {
            postsList = newPosts; // Replace postsList if loading the first page
          } else {
            postsList.addAll(newPosts); // Append new posts
          }
          _currentPage = page; // Update the current page
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading posts: $e');
      // Optionally notify listeners of an error or display a message
    }
  }

  // Method to load more posts (used for infinite scrolling)
  Future<void> loadMorePosts() async {
    if (_hasMorePosts) {
      _currentPage++;
      await loadPosts(page: _currentPage);
    }
  }

  // Create a new post
  Future<void> createNewPost({
    required String message,
    required String ownerId,
    required DateTime timeStamp,
    required String image,
  }) async {
    final success = await createPost(
      message: message,
      ownerId: ownerId,
      image: image,
    );
    if (success) {
      // Optionally fetch and assign the owner or set to null if not available
      postsList.insert(
        0,
        Post(
          id: ID.unique(), // Use a generated ID instead of 'temp_id'
          message: message,
          owner: null, // Optionally fetch and assign the owner
          timeStamp: timeStamp,
          image: image,
        ),
      );
      notifyListeners();
    } else {
      // Optionally handle creation failure
    }
  }
}
