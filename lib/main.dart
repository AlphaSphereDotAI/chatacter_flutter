import 'package:camera/camera.dart';
import 'package:chatacter/data/local_saved_data.dart';
import 'package:chatacter/config/appwrire.dart';
import 'package:chatacter/providers/chat_provider.dart';
import 'package:chatacter/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
List<CameraDescription>? cameras;

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("app resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app inactive");

        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app paused");

        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app detched");

        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app hidden");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());
  await LocalSavedData.init();

  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Use the navigatorKey
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Urbanist",
          scaffoldBackgroundColor: AppColors.background,
          brightness: Brightness.dark,
        ),
        initialRoute: AppRoutes.checkUserSession,
        routes: AppRoutes.pages,
      ),
    );
  }
}

class CheckUserSessions extends StatefulWidget {
  const CheckUserSessions({super.key});

  @override
  State<CheckUserSessions> createState() => _CheckUserSessionsState();
}

class _CheckUserSessionsState extends State<CheckUserSessions> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      // Load data from local storage
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      await userDataProvider.loadDataFromLocal();

      // Check sessions and then load data from the database
      bool sessionExists = await checkSessions();

      if (sessionExists) {
        // Load data from the database
        await userDataProvider.loadUserData(userDataProvider.getUserId);

        final userName = userDataProvider.getUserName;
        print("username: $userName");

        if (userName.isNotEmpty) {
          print('Entered Home, Username: $userName');
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
          }
        } else {
          print('Entered Add Details, Username: $userName');
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.editProfile, (route) => false,
                arguments: {"title": "add"});
          }
        }
      } else {
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
