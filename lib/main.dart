import 'package:chat_task/firebase_options.dart';
import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/providers/chats_provider.dart';
import 'package:chat_task/ui/screens/auth_screens/login_screen.dart';
import 'package:chat_task/ui/screens/chat_screens/conversations_screen.dart';
import 'package:chat_task/ui/screens/splash_screen.dart';
import 'package:chat_task/utils/auth_client.dart';
import 'package:chat_task/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print("message title: ${message.notification!.title}");
    print("message body: ${message.notification!.body}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _getHomeWidget(AuthProvider auth) {
    return FutureBuilder<bool>(
      future: auth.autoLogin(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        return (snapshot.data ?? false)
            ? const ConversationsScreen()
            : const LoginScreen();
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ChatsProvider>(
          create: (_) => ChatsProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (BuildContext context, AuthProvider auth, Widget? child) =>
            MaterialApp(
          title: 'UChat',
          navigatorKey: navigatorKey,
          theme: UChatTheme.getLightTheme(),
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: _getHomeWidget(auth),
        ),
      ),
    );
  }
}
