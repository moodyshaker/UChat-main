import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/providers/chat_user_provider.dart';
import 'package:chat_task/providers/chats_provider.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/input_form_field.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:chat_task/ui/widgets/user_card.dart';
import 'package:chat_task/utils/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  _getUsers() async {
    try {
      await context.read<ChatsProvider>().getUsers();
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



  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<ChatsProvider>().users;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        // leading: IconButton(
        //   icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
        //       color: Colors.black),
        //   onPressed: () => Navigator.of(context),
        // ),
      ),
      body: users == null
          ? const LoadingWidget()
          : users.isEmpty
              ? Center(
                  child: Text(
                    'No users found.',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      InputFormField(
                        hintText: 'Search',
                        prefixIcon: SvgPicture.asset('assets/svg/search.svg'),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) =>
                              ChangeNotifierProvider<ChatUserProvider>(
                            create: (_) => ChatUserProvider(users[index]),
                            child: const UserCard(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
