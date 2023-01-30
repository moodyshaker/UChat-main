import 'dart:io';

import 'package:chat_task/models/message_model.dart';
import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/providers/chat_provider.dart';
import 'package:chat_task/providers/chat_user_provider.dart';
import 'package:chat_task/ui/widgets/animated_pop_up.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/input_form_field.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:chat_task/ui/widgets/message_bubble.dart';
import 'package:chat_task/utils/vars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/strings.dart';

class PersonalConversationScreen extends StatefulWidget {
  const PersonalConversationScreen({Key? key}) : super(key: key);

  @override
  State<PersonalConversationScreen> createState() =>
      _PersonalConversationScreenState();
}

class _PersonalConversationScreenState
    extends State<PersonalConversationScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _listScrollController = ScrollController();
  String? _uploadedFileURL;
  final TextEditingController _message = TextEditingController();
  int? _type = 0;
  File? _image;
  File? _file;

  Future<void> _chooseImage({bool camera = false}) async {
    final pickedFile = await ImagePicker().pickImage(
      imageQuality: 10,
      source: camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (!mounted) return;
    LoadingScreen.show(context);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _type = 1;
      setState(() {});
      await uploadFile(isImage: true);
      await _sendData();
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> _pickFile() async {
    final FilePickerResult? pFile =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (!mounted) return;
    LoadingScreen.show(context);
    if (pFile != null) {
      if (mounted) {
        _file = File(pFile.files.single.path ?? '');
        _type = 2;
        setState(() {});
        await uploadFile();
        await _sendData();
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> uploadFile({bool isImage = false}) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(isImage ? _imagesFolderPath : _filesFolderPath);
      await ref.putFile(isImage ? _image! : _file!);
      await ref.getDownloadURL().then((fileURL) {
        _uploadedFileURL = fileURL;
        if (mounted) setState(() {});
      });
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

  String get _imagesFolderPath => "chat_images"
      "/${path.basename(_image!.path)}";

  String get _filesFolderPath => "chat_files"
      "/${path.basename(_file!.path)}";

  Future<void> _sendData() async {
    try {
      final otherUser = context.read<ChatUserProvider>().user;
      final otherUserToken = otherUser.token!;
      final user = context.read<AuthProvider>().user;
      final message = _message.text;
      _message.clear();
      setState(() {});
      await context.read<ChatProvider>().sendMessage(
          MessageModel(
            message: message,
            filePath: _type == 1
                ? _imagesFolderPath
                : _type == 2
                    ? _filesFolderPath
                    : null,
            fileUrl: _uploadedFileURL,
            senderID: user!.id,
            type: _type,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          otherUser);
      _listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      await context.read<ChatProvider>().sendNotification(
          toToken: otherUserToken,
          title: user.name!,
          body: _type == 1
              ? 'Image'
              : _type == 2
                  ? 'File'
                  : message);
      _uploadedFileURL = null;
      _type = 0;
      setState(() {});
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
  void dispose() {
    super.dispose();
    _message.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = context.watch<ChatUserProvider>().user;
    final user = context.watch<AuthProvider>().user;
    final chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          otherUser.name ?? '',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg/search.svg',
              color: Theme.of(context).shadowColor,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/svg/menu.svg'),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            thickness: 2,
            height: 1,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getMessages(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                        'Something Went Wrong! please try again.');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  return ListView.builder(
                    controller: _listScrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 24),
                    reverse: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? data = snapshot.data?.docs[index]
                          .data() as Map<String, dynamic>?;
                      return MessageBubble(
                          isSender: data![MessageVars.senderID] == user!.id,
                          message: MessageModel.fromMap(data));
                    },
                  );
                }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AnimatedPopUp(
                      onSelectCamera: () => _chooseImage(camera: true),
                      onSelectGallery: _chooseImage,
                      onSelectAttach: _pickFile,
                    ),
                  ),
                  icon: Icon(
                    Icons.add,
                    size: 30,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                Expanded(
                  child: InputFormField(
                    hintText: 'Enter your message',
                    controller: _message,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (isBlank(_message.text)) return;
                    _sendData();
                  },
                  icon: SvgPicture.asset(
                    'assets/svg/send.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
