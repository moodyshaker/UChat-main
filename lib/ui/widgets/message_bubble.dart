import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_task/models/message_model.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../providers/chat_provider.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({Key? key, this.isSender = false, required this.message})
      : super(key: key);
  final bool isSender;
  final MessageModel message;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    // final message = context.watch<MessageProvider>().message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (widget.isSender) ...{
              SvgPicture.asset('assets/svg/more.svg'),
              const SizedBox(
                width: 16,
              ),
            },
            Expanded(
              child: widget.message.type != 0
                  ? widget.message.type == 1
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.fileUrl ?? '',
                            height: MediaQuery.of(context).size.width / 2,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) =>
                                const LoadingWidget(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error_outline),
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  right: widget.isSender ? 20 : 6,
                                  left: widget.isSender ? 6 : 20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.message.filePath?.split('/').last ??
                                        '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            ChatBubble(
                              clipper: ChatBubbleClipper2(
                                type: widget.isSender
                                    ? BubbleType.sendBubble
                                    : BubbleType.receiverBubble,
                              ),
                              backGroundColor: widget.isSender
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : Theme.of(context).primaryColor,
                              elevation: widget.isSender ? null : 0,
                              alignment: widget.isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Download',
                                    style: widget.isSender
                                        ? Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500)
                                        : Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                  ),
                                  SvgPicture.asset(
                                    'assets/svg/download.svg',
                                    color: widget.isSender
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                  : ChatBubble(
                      clipper: ChatBubbleClipper2(
                        type: widget.isSender
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble,
                      ),
                      backGroundColor: widget.isSender
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Theme.of(context).primaryColor,
                      elevation: widget.isSender ? null : 0,
                      alignment: widget.isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        widget.message.message ?? '',
                        style: widget.isSender
                            ? Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w500)
                            : Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
            ),
            if (!widget.isSender) ...{
              const SizedBox(
                width: 16,
              ),
              SvgPicture.asset('assets/svg/more.svg'),
            },
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                timeago.format(widget.message.updatedAt ?? DateTime.now(),
                    locale: 'en'),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
