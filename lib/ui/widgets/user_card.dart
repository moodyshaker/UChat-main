import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_task/models/chat_model.dart';
import 'package:chat_task/providers/chat_provider.dart';
import 'package:chat_task/providers/chat_user_provider.dart';
import 'package:chat_task/providers/chats_provider.dart';
import 'package:chat_task/ui/screens/chat_screens/personal_conversation_screen.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  const UserCard({Key? key}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  _chat() async {
    try {
      LoadingScreen.show(context);
      final userChatProvider = context.read<ChatUserProvider>();
      final user = userChatProvider.user;
      await context.read<ChatsProvider>().getChatOrCreate(user);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => ChangeNotifierProvider<ChatUserProvider>.value(
            value: userChatProvider,
            child: ChangeNotifierProvider<ChatProvider>(
              create: (_) => ChatProvider(
                  context.read<ChatsProvider>().chat ?? ChatModel()),
              child: const PersonalConversationScreen(),
            ),
          ),
        ),
      );
    } on FirebaseException catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (_) => ErrorPopUp(message: '${e.message}'));
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => const ErrorPopUp(
            message: 'Something Went Wrong! please try again.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ChatUserProvider>().user;
    return InkWell(
      onTap: _chat,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: user.imageUrl ?? '',
                height: 48,
                width: 48,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => const LoadingWidget(),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error_outline),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              user.name ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
