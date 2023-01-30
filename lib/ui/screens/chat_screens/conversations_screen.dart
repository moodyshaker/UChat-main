import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/providers/chat_provider.dart';
import 'package:chat_task/providers/chat_user_provider.dart';
import 'package:chat_task/providers/chats_provider.dart';
import 'package:chat_task/ui/screens/auth_screens/login_screen.dart';
import 'package:chat_task/ui/screens/chat_screens/users_screen.dart';
import 'package:chat_task/ui/widgets/chat_card.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/input_form_field.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:chat_task/ui/widgets/status_card.dart';
import 'package:chat_task/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  _getChats() async {
    try {
      await context.read<ChatsProvider>().getChats();
    } on FirebaseException catch (e) {
      showDialog(
          context: context,
          builder: (_) => ErrorPopUp(message: '${e.message}'));
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => const ErrorPopUp(
            message: 'Something Went Wrong! please try again.'),
      );
    }
  }

  late ChatsProvider _chatsProvider;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<AuthProvider>().updateStatus(true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getChats();
      _chatsProvider = Provider.of<ChatsProvider>(context, listen: false);
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _chatsProvider.initialFCM(context);
      _chatsProvider.initialOpenedAppFCM(context);
      _authProvider.updateToken(FirebaseNotifications.fcm!);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await context.read<AuthProvider>().updateStatus(true);
    } else {
      await context.read<AuthProvider>().updateStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chats = context.watch<ChatsProvider>().chats;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversations',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const UsersScreen(),
                ),
              );
              await _getChats();
            },
            icon: SvgPicture.asset('assets/svg/new_chat.svg'),
          ),
          IconButton(
            onPressed: () async {
              await _getChats();
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chats == null
                ? const LoadingWidget()
                : chats.isEmpty
                    ? Center(
                        child: Text(
                          'There is no chats yet.',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      )
                    : ListView(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: const [
                                StatusCard(
                                  title: 'Your Story',
                                ),
                                StatusCard(
                                  title: 'Victoria Atoma',
                                  imagePath: 'assets/images/Frame 3293.png',
                                ),
                                StatusCard(
                                  title: 'Demola Andy',
                                  imagePath: 'assets/images/Frame 3293-1.png',
                                ),
                                StatusCard(
                                  title: 'Tobi Ozenama',
                                  imagePath: 'assets/images/Frame 3293-2.png',
                                ),
                                StatusCard(
                                  title: 'Busola Ajoma',
                                  imagePath: 'assets/images/Frame 3293-3.png',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Divider(
                            height: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            child: Column(
                              children: [
                                InputFormField(
                                  hintText: 'Search',
                                  prefixIcon:
                                      SvgPicture.asset('assets/svg/search.svg'),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                ...chats.map(
                                  (chat) {
                                    final currentUser =
                                        context.read<AuthProvider>().user;
                                    final otherUserId = chat.userIDS
                                        ?.firstWhere((userId) =>
                                            userId != currentUser?.id);
                                    return ChangeNotifierProvider<ChatProvider>(
                                      create: (_) => ChatProvider(chat),
                                      child: ChangeNotifierProvider<
                                          ChatUserProvider>(
                                        create: (_) => ChatUserProvider(
                                            UserModel(id: otherUserId)),
                                        child: const ChatCard(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset('assets/svg/user.svg'),
                Column(
                  children: [
                    Text(
                      'Conversations',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset('assets/svg/more_horizontal.svg'),
                    const SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false);
                        context.read<AuthProvider>().logout();
                      },
                      child: Icon(
                        Icons.logout,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
