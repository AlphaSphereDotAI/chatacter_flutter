import 'package:chatacter/config/appwrire.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/models/post.dart';

class PostProvider extends ChangeNotifier {
  List<Post> postsList = [];
  List<Post> favoritePostsList = [];

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
          // print(' All posts loaded: ${postsList.length}');
        }
      }
    } catch (e) {
      print('Error loading posts: $e');
      // Optionally notify listeners of an error or display a message
    }
  }

  // Load posts with pagination
  Future<void> loadFavoritePosts({required String userId}) async {
    try {
      final result = await getFavoritePosts(userId: userId);
      if (result != null) {
        // Convert the result to a list of dynamic objects
        final List<dynamic> dataList = result as List<dynamic>;

        // Fetch user data only once
        final user = await getUserData(userId: userId);

        // Process each record asynchronously
        final newPosts =
            await Future.wait(dataList.map<Future<Post>>((data) async {
          final timeStamp = data['time_stamp'] != null
              ? DateTime.parse(data['time_stamp'] as String)
              : null;

          return Post(
            id: data['id'],
            message: data['message'],
            owner: user,
            timeStamp: timeStamp,
            image: data['image'] ?? '', // Handle null image gracefully
          );
        }));

        if (newPosts.isEmpty) {
          _hasMorePosts = false; // No more posts to load
        } else {
          favoritePostsList = newPosts; // Replace postsList with newPosts
          notifyListeners();
          // print('Favorite posts loaded: ${favoritePostsList.length}');
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
    print('Creating post with message: $message');
    final success = await createPost(
      message: message,
      ownerId: ownerId,
      image: image,
    );
    print('Create post success: $success');
    if (success) {
      loadPosts(page: _currentPage);
      notifyListeners();
      print('Post created and added to the list');
    } else {
      print('Failed to create post');
    }
  }

  Future<void> deletePost({
    required String postId,
  }) async {
    final success = await deletePostFromDatabase(postId: postId);
    if (success) {
      // Remove the post from the postsList
      postsList.removeWhere((post) => post.id == postId);

      // Notify listeners to rebuild the UI
      notifyListeners();
      print('Post deleted and removed from the list');
    } else {
      print('Failed to delete post');
    }
  }

  // Remove post from favorites
  Future<void> removePostFromFavorites({
    required String userId,
    required String postId,
  }) async {
    final success = await removePostFromFavoritesDatabase(
      userId: userId,
      postId: postId,
    );

    if (success) {
      // Remove the post from the favoritePostsList
      favoritePostsList.removeWhere((post) => post.id == postId);

      // Notify listeners to rebuild the UI
      notifyListeners();
      print('Post removed from favorites and updated the list');
    } else {
      print('Failed to remove post from favorites');
    }
  }

  Future<void> editPost({
    required String postId,
    required String message,
    required String? image,
  }) async {
    print('Post ID: ${postId}');
    print('Message: ${message}');
    print('Image: ${image}');

    final success = await editPostInDatabase(
      postId: postId,
      message: message,
      image: image,
    );
    if (success) {
      loadPosts(page: _currentPage);
      notifyListeners();
    }
  }
}
