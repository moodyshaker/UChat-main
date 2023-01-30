import 'dart:io';

import 'package:chat_task/models/user_model.dart';
import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/ui/screens/auth_screens/otp_screen.dart';
import 'package:chat_task/ui/screens/chat_screens/conversations_screen.dart';
import 'package:chat_task/ui/widgets/custom_button.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/input_form_field.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:chat_task/ui/widgets/take_photo_pop_up.dart';
import 'package:chat_task/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flrx_validator/flrx_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/strings.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _image;
  bool _autoValidate = false;
  String? _name;
  String? _phone;
  String? _email;
  bool _obscure = true;
  bool _confirmationObscure = true;
  String? _imageUrl;
  String? _imagePath;
  String? _pass;
  late CountryCode _countryCode;

  String get _imagesFolderPath => 'profile_images'
      "/${path.basename(_image!.path)}";

  Future<void> _uploadImage() async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child(_imagesFolderPath);
      await ref.putFile(_image!);
      await ref.getDownloadURL().then((fileURL) {
        _imageUrl = fileURL;
        _imagePath = _imagesFolderPath;
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

  _submit() async {
    if (!_formKey.currentState!.validate()) {
      if (!_autoValidate) setState(() => _autoValidate = true);
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select image first.'),
        ),
      );
      return;
    }

    _formKey.currentState?.save();
    try {
      context.read<AuthProvider>().user = UserModel(
        countryCode: _countryCode.dialCode,
        email: _email,
        name: _name,
        phone: _phone,
      );
      final bool? verified = await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const OTPScreen(),
        ),
      );
      if (!(verified ?? false)) return;
      if (!mounted) return;
      LoadingScreen.show(context);
      await _uploadImage();
      if (!mounted) return;
      context.read<AuthProvider>().user = UserModel(
        countryCode: _countryCode.dialCode,
        email: _email,
        name: _name,
        phone: _phone,
        imagePath: _imagePath,
        imageUrl: _imageUrl,
        token: FirebaseNotifications.fcm,
      );
      if (!mounted) return;
      await context.read<AuthProvider>().registration(_pass!);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => const ConversationsScreen(),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      context.read<AuthProvider>().user = null;
      showDialog(
          context: context,
          builder: (_) => ErrorPopUp(message: '${e.message}'));
    } catch (e) {
      Navigator.pop(context);
      context.read<AuthProvider>().user = null;
      showDialog(
        context: context,
        builder: (_) => const ErrorPopUp(
            message: 'Something Went Wrong! please try again.'),
      );
    }
  }

  Future<void> _chooseImage({bool camera = false}) async {
    final pickedFile = await ImagePicker().pickImage(
      imageQuality: 10,
      source: camera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  _removeImage() {
    _image = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _countryCode =
        const CountryCode(code: 'EG', dialCode: '+20', name: 'Egypt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Create Account',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Please fill the input below here.',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_image == null) ...{
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => TakePhotoPopUp(
                          pickImageOnPressed: _chooseImage,
                          takeImageOnPressed: () => _chooseImage(camera: true),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 80,
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/svg/camera.svg',
                            color: Theme.of(context).primaryColor,
                            height: 30,
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                  } else ...{
                    InkWell(
                      onTap: _removeImage,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.topRight,
                        child: CloseButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: _removeImage,
                        ),
                      ),
                    ),
                  },
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              InputFormField(
                above: true,
                labelText: 'Full Name',
                onSaved: (name) => _name = name,
                validator: Validator(
                  rules: [
                    RequiredRule(validationMessage: 'Please enter a name.'),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Phone',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge!
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width) * 100 / 375,
                    child: InputFormField(
                      readOnly: true,
                      validator: (_) => isBlank(_phone) ? '' : null,
                      hasConstraints: false,
                      prefixIcon: InkWell(
                        onTap: () async {
                          const countryPicker = FlCountryCodePicker();
                          _countryCode = (await countryPicker.showPicker(
                              context: context, initialSelectedLocale: 'EG'))!;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              _countryCode.dialCode,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            _countryCode.flagImage,
                            const SizedBox(
                              width: 4,
                            ),
                            SvgPicture.asset(
                              'assets/svg/arrow_down.svg',
                              height: 16,
                              width: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: InputFormField(
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      onChanged: (phone) {
                        _phone = phone;
                        setState(() {});
                      },
                      onSaved: (phone) => _phone = phone,
                      validator: Validator(
                        rules: [
                          RequiredRule(
                              validationMessage:
                                  'Please enter a phone number.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              InputFormField(
                above: true,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _email = email,
                validator: Validator(
                  rules: <Rule>[
                    RequiredRule(validationMessage: 'Please enter an email.'),
                    EmailRule(validationMessage: 'Please enter a valid email.'),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InputFormField(
                above: true,
                labelText: 'Password',
                obscure: _obscure,
                suffixIcon: InkWell(
                  onTap: () {
                    _obscure = !_obscure;
                    setState(() {});
                  },
                  child: SvgPicture.asset(_obscure
                      ? 'assets/svg/eye-close.svg'
                      : 'assets/svg/eye-open.svg'),
                ),
                onSaved: (pass) => _pass = pass,
                onChanged: (pass) {
                  _pass = pass;
                  setState(() {});
                },
                validator: Validator(
                  rules: [
                    RequiredRule(validationMessage: 'Please enter a password.'),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InputFormField(
                above: true,
                labelText: 'Confirm Password',
                obscure: _confirmationObscure,
                suffixIcon: InkWell(
                  onTap: () {
                    _confirmationObscure = !_confirmationObscure;
                    setState(() {});
                  },
                  child: SvgPicture.asset(_confirmationObscure
                      ? 'assets/svg/eye-close.svg'
                      : 'assets/svg/eye-open.svg'),
                ),
                validator: (pass) => RegExp('^$_pass\$').hasMatch(pass ?? '')
                    ? null
                    : 'Password is not match.',
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                onTap: _submit,
                title: 'SIGN UP',
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: 'Sign in',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
