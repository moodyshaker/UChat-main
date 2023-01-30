import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_task/providers/chat_provider.dart';
import 'package:chat_task/providers/chat_user_provider.dart';
import 'package:chat_task/providers/chats_provider.dart';
import 'package:chat_task/ui/screens/chat_screens/personal_conversation_screen.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatCard extends StatefulWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  _getOtherUserData() async {
    try {
      await context.read<ChatUserProvider>().getUserById();
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getOtherUserData();
    });
  }

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
            child: ChangeNotifierProvider<ChatProvider>.value(
              value: context.read<ChatProvider>(),
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
    final chat = context.watch<ChatProvider>().chat;
    final otherUser = context.watch<ChatUserProvider>().user;
    return InkWell(
      onTap: _chat,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: otherUser.imageUrl ?? '',
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
                if (otherUser.online ?? false)
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2CC069),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherUser.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        timeago.format(chat.updatedAt ?? DateTime.now(),
                            locale: 'en'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.messages?.isEmpty ?? true
                              ? 'Start new chat'
                              : chat.messages?.last.type == null
                                  ? 'Start new chat'
                                  : chat.messages?.last.senderID == otherUser.id
                                      ? chat.messages?.last.type == 0
                                          ? chat.messages?.last.message ??
                                              'Start new chat'
                                          : 'Attachment'
                                      : 'You : ${chat.messages?.last.type == 0 ? chat.messages?.last.message ?? 'Start new chat' : 'Attachment'}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (chat.messages?.isNotEmpty ?? false) ...{
                        if (chat.messages?.last.senderID == otherUser.id) ...{
                          const SizedBox(
                            width: 2,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '1',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                            ),
                          ),
                        },
                      },
                      if (chat.messages?.isNotEmpty ?? false) ...{
                        if (chat.messages?.last.senderID != otherUser.id) ...{
                          const SizedBox(
                            width: 2,
                          ),
                          SvgPicture.asset('assets/svg/check.svg'),
                        },
                      },
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
