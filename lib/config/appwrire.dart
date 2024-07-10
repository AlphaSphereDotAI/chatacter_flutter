import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chatacter/main.dart';
import 'package:chatacter/models/chat.dart';
import 'package:chatacter/models/message.dart';
import 'package:chatacter/models/user_data.dart';
import 'package:chatacter/providers/chat_provider.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('667d37b30023f69f7f74')
    .setSelfSigned(status: true);

const String databaseId = '66803ce100323250c22e';
const String userCollectionId = '66803d2a002bb74a6bc7';
const String chatCollectionId = '6685c80c000ab935ee25';
const String imagesBucketId = '6683247c00056fdd9ceb';

Account account = Account(client);
final Databases databases = Databases(client);
final Storage storage = Storage(client);
final Realtime realtime = Realtime(client);

RealtimeSubscription? subscription;

//Subscribe to realtime changes
subscribeToRealtime({required String userId}) {
  subscription = realtime.subscribe([
    'databases.$databaseId.collections.$chatCollectionId.documents',
    'databases.$databaseId.collections.$userCollectionId.documents'
  ]);

  print('Subscribing to realtime');

  subscription!.stream.listen((data) {
    print("Some event happened");

    final firstItem = data.events[0].split('.');
    final eventType = firstItem[firstItem.length - 1];

    print('EventType is $eventType');

    // Use a method to handle the event that checks for mounted state
    _handleRealtimeEvent(eventType, userId);
  });
}

void _handleRealtimeEvent(String eventType, String userId) {
  final context = navigatorKey.currentState?.context;
  if (context != null) {
    // Now it's safer to use the context
    if (['create', 'update', 'delete'].contains(eventType)) {
      Provider.of<ChatProvider>(context, listen: false).loadChats(userId);
    }
  }
}

//save a phone number (while creating a new account)
Future<bool> savePhoneToDatabase(
    {required String phoneNumber, required String userId}) async {
  try {
    final response = await databases.createDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
        data: {
          'id': userId,
          'phone_number': phoneNumber,
        });

    print(response);
    return true;
  } on AppwriteException catch (e) {
    print("Can't save to user database: $e");
    return false;
  }
}

// Check if phone number is exist in the database
Future<String> checkPhoneNumber({required String phoneNumbre}) async {
  try {
    final DocumentList matchUser = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: userCollectionId,
        queries: [Query.equal('phone_number', phoneNumbre)]);

    if (matchUser.total > 0) {
      final Document user = matchUser.documents[0];

      if (user.data['phone_number'] != null &&
          user.data['phone_number'] != '') {
        return user.data['id'];
      } else {
        print('User is not exist in the database');
        return 'user_not_exists';
      }
    } else {
      print('User is not exist in the database');
      return 'user_not_exists';
    }
  } on AppwriteException catch (e) {
    print('Error when reading database: $e');
    return 'user_not_exists';
  }
}

// create phone session, send OTP
Future<String> createPhoneNumberSession({required String phone}) async {
  try {
    final userId = await checkPhoneNumber(phoneNumbre: phone);

    if (userId == 'user_not_exists') {
      // Create a new account
      final Token data =
          await account.createPhoneToken(userId: ID.unique(), phone: phone);

      // Save user to collection
      savePhoneToDatabase(phoneNumber: phone, userId: data.userId);
      return data.userId;
    }
    // if user exists in the database
    else {
      // create phone token for existing user
      print('Sending OTP Pin to $phone');
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phone);
      return data.userId;
    }
  } catch (e) {
    print('Error on creating phone session: $e');
    return 'Login Error';
  }
}

// login with otp
Future<bool> loginWithOtp({required String otp, required String userId}) async {
  try {
    final Session session =
        await account.updatePhoneSession(userId: userId, secret: otp);
    print(session.userId);
    return true;
  } catch (e) {
    print("error on login with otp :$e");
    return false;
  }
}

// Check if the session exist
Future<bool> checkSessions() async {
  try {
    final Session session = await account.getSession(sessionId: 'current');
    print('Session exists: ${session.$id}');
    return true;
  } catch (e) {
    // Specifically handle unauthorized access
    if (e is AppwriteException && e.code == 401) {
      print('Unauthorized access, missing required scope: $e');
      // Consider re-authenticating the user or requesting the necessary scope
    } else {
      print('Error checking session: $e');
    }
    return false;
  }
}

// Logout and delete session
Future logoutUser() async {
  await account.deleteSession(sessionId: 'current');
}

// Load user data
Future<UserData?> getUserDetails({required String userId}) async {
  try {
    final response = await databases.getDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId);
    print('Getting User Data...');
    print(response.data);

    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(response.data['name'] ?? '');
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserLastName(response.data['last_name'] ?? '');
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserLocation(response.data['location'] ?? '');
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserProfilePicture(response.data['profile_picture'] ?? '');

    return UserData.toMap(response.data);
  } catch (e) {
    print('Error in getting user data: $e');
    return null;
  }
}

// To update user data
Future<bool> updateUserDetails(String picture, String location,
    {required String id,
    required String name,
    required String lastName,
    required String birthday,
    required String gender}) async {
  try {
    final data = await databases.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: id,
        data: {
          'name': name,
          'profile_picture': picture,
          'location': location,
          'last_name': lastName,
          'birthday': birthday,
          'gender': gender
        });

    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(name);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserLastName(lastName);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserProfilePicture(picture);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserLocation(location);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserBirthday(birthday);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserGender(gender);

    print(data);
    return true;
  } on AppwriteException catch (e) {
    print('Can\'t save data to database: $e');
    return false;
  }
}

// Upload and save image to storage bucked
Future<String?> saveImageToBucket({required InputFile image}) async {
  try {
    final response = await storage.createFile(
        bucketId: imagesBucketId, fileId: ID.unique(), file: image);
    print('Response after saving to bucked: $response');
    return response.$id;
  } catch (e) {
    print('Error when saving an image to bucket: $e');
    return null;
  }
}

// updating an image in the bucket (deleting and creating a new one)
Future<String?> updateImageOnBucket(
    {required String oldImageId, required InputFile image}) async {
  try {
    //To delete the old image
    deleteImageFromBucket(oldImage: oldImageId);

    //To create a new image
    final newImage = saveImageToBucket(image: image);

    return newImage;
  } catch (e) {
    print('Cann\'t update / delete image: $e');
    return null;
  }
}

//To delete an image from the bucket
Future<bool> deleteImageFromBucket({required String oldImage}) async {
  try {
    await storage.deleteFile(bucketId: imagesBucketId, fileId: oldImage);
    return true;
  } catch (e) {
    print('Can\'t delete image: $e');
    return false;
  }
}

//To search about doduments in the database
Future<DocumentList?> searchUsers(
    {required String searchItem, required String userId}) async {
  try {
    final DocumentList users = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: userCollectionId,
        queries: [
          Query.search('phone_number', searchItem),
          Query.notEqual('id', userId),
        ]);
    print('Matched Users: ${users.total}');
    return users;
  } catch (e) {
    print('Error on searching users: $e');
    return null;
  }
}

//Create a new chat and save it to database
Future createNewChat(
    {required String message,
    required String senderId,
    required String receiverId,
    required bool isImage}) async {
  try {
    print('Here SenderId = $senderId, receiverId = $receiverId');
    final msg = await databases.createDocument(
      databaseId: databaseId,
      collectionId: chatCollectionId,
      documentId: ID.unique(),
      data: {
        'message': message,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'timestamp': DateTime.now().toIso8601String(),
        'is_seen_by_receiver': false,
        'is_image': isImage,
        'user': [senderId, receiverId],
      },
    );
    print('Message Sent!');
    return true;
  } catch (e) {
    print('Failed to send message: $e');
    return false;
  }
}

//To list all chats of a current user
Future<Map<String, List<Chat>>?> currentUserChats(String userId) async {
  try {
    var results = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: chatCollectionId,
        queries: [
          Query.or([
            Query.equal('sender_id', userId),
            Query.equal('receiver_id', userId)
          ]),
          Query.orderDesc('timestamp'),
          Query.limit(2000),
        ]);

    final DocumentList chatDocuments = results;

    print(
        'Chat Documnents: ${chatDocuments.total}, documents: ${chatDocuments.documents.length}');

    Map<String, List<Chat>> chats = {};

    if (chatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < chatDocuments.documents.length; i++) {
        var document = chatDocuments.documents[i];
        String sender = document.data['sender_id'];
        String receiver = document.data['receiver_id'];

        Message message = Message.fromMap(document.data);

        List<UserData> users = [];

        for (var user in document.data['user']) {
          users.add(UserData.toMap(user));
        }
        String key = (sender == userId) ? receiver : sender;

        if (chats[key] == null) {
          chats[key] = [];
        }
        chats[key]!.add(Chat(message: message, users: users));
      }
    }
    return chats;
  } catch (e) {
    print('Error on reading user chats: $e');
    return null;
  }
}

// edit our chat message and update to database
Future editChat({
  required String chatId,
  required String message,
}) async {
  try {
    await databases.updateDocument(
        databaseId: databaseId,
        collectionId: chatCollectionId,
        documentId: chatId,
        data: {"message": message});
    print("message updated");
  } catch (e) {
    print("error on editing message :$e");
  }
}

//to delete a message from the database
Future deleteCurrentUserChat({required String chatId}) async {
  try {
    await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: chatCollectionId,
        documentId: chatId);
  } catch (e) {
    print('Error on deleting a message: $e');
  }
}

// to update isSeen message status
Future updateIsSeen({required List<String> chatsIds}) async {
  try {
    for (var chatid in chatsIds) {
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: chatCollectionId,
          documentId: chatid,
          data: {"is_seen_by_receiver": true});
      print("update is seen");
    }
  } catch (e) {
    print("error in update isseen :$e");
  }
}

// to update the online status
Future updateOnlineStatus(
    {required bool status, required String userId}) async {
  try {
    await databases.updateDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: userId,
        data: {"is_online": status});
    print("Updated user online status $status ");
  } catch (e) {
    print("Unable to update online status : $e");
  }
}
