import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/ui/widgets/custom_button.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/input_form_field.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flrx_validator/flrx_validator.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String? _email;

  _submit() async {
    if (!_formKey.currentState!.validate()) {
      if (!_autoValidate) setState(() => _autoValidate = true);
      return;
    }
    _formKey.currentState?.save();
    try {
      LoadingScreen.show(context);
      await context.read<AuthProvider>().resetPassword(_email!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Check your mail box to reset password. (in junk if not found)'),
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
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
                'Reset Password',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Please enter your email to send reset mail.',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
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
              CustomButton(
                onTap: _submit,
                title: 'Reset',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
