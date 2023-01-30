import 'package:chat_task/providers/auth_provider.dart';
import 'package:chat_task/ui/widgets/custom_button.dart';
import 'package:chat_task/ui/widgets/error_pop_up.dart';
import 'package:chat_task/ui/widgets/loading_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController controller = TextEditingController();
  int pinLength = 6;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initOTP();
  }

  Future<void> _initOTP() async {
    final provider = context.read<AuthProvider>();
    try {
      verificationCompleted(AuthCredential phoneAuthCredential) async {
        debugPrint(
            '------------ Verification Completed ($phoneAuthCredential) ------------');
        _autoVerify(phoneAuthCredential);
      }

      verificationFailed(authException) async {
        debugPrint(
            '------------ Verification Failed (${authException.message}) ------------');

        await showDialog(
          context: context,
          builder: (context) => ErrorPopUp(message: '${authException.message}'),
        );
      }

      codeSent(String verificationId, [int? forceResendingToken]) async {
        debugPrint('------------ Code Sent ($verificationId) ------------');
        provider.verificationId = verificationId;
      }

      codeAutoRetrievalTimeout(String verificationId) {
        debugPrint(
            '------------ Code Auto Retrieval Timeout ($verificationId) ------------');
        provider.verificationId = verificationId;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '${provider.user?.countryCode} ${provider.user?.phone}',
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e, s) {
      debugPrint('$s');

      showDialog(
          context: context, builder: (_) => ErrorPopUp(message: e.toString()));
    }
  }

  Future<void> _resendOTP() async {
    final provider = context.read<AuthProvider>();
    try {
      verificationCompleted(AuthCredential phoneAuthCredential) async {
        debugPrint(
            '------------ Verification Completed ($phoneAuthCredential) ------------');
        _autoVerify(phoneAuthCredential);
      }

      verificationFailed(authException) async {
        debugPrint(
            '------------ Verification Failed (${authException.message}) ------------');

        await showDialog(
          context: context,
          builder: (_) => const ErrorPopUp(
              message: 'Something Went Wrong! please try again.'),
        );
      }

      codeSent(String verificationId, [int? forceResendingToken]) async {
        debugPrint('------------ Code Sent ($verificationId) ------------');
        provider.verificationId = verificationId;
      }

      codeAutoRetrievalTimeout(String verificationId) {
        debugPrint(
            '------------ Code Auto Retrieval Timeout ($verificationId) ------------');
        provider.verificationId = verificationId;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '${provider.user?.countryCode} ${provider.user?.phone}',
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Code Sent'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ));
    } on FirebaseAuthException catch (e, s) {
      debugPrint('$s');

      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (_) => ErrorPopUp(message: '${e.message}'));
    } catch (e, s) {
      debugPrint('$s');

      showDialog(
          context: context, builder: (_) => ErrorPopUp(message: e.toString()));
    }
  }

  Future<void> _autoVerify(AuthCredential authCredential) async {
    LoadingScreen.show(context);
    final provider = context.read<AuthProvider>();

    await provider.verifyOTP();

    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  Future<void> _verify() async {
    try {
      LoadingScreen.show(context);

      final provider = context.read<AuthProvider>();

      await provider.verifyOTP();
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e, s) {
      debugPrint('$s');

      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (_) => ErrorPopUp(message: "${e.message}"));
    } on PlatformException catch (e, s) {
      debugPrint('$s');

      Navigator.pop(context);

      showDialog(context: context, builder: (_) => ErrorPopUp(message: e.code));
    } catch (e, s) {
      debugPrint('$s');

      Navigator.pop(context);

      showDialog(
          context: context, builder: (_) => ErrorPopUp(message: e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text(
                'Verification Code',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Check ${provider.user?.countryCode} ${provider.user?.phone} For The Code',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PinCodeTextField(
                    autofocus: true,
                    controller: controller,
                    highlight: true,
                    highlightColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    defaultBorderColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    hasTextBorderColor: Theme.of(context).primaryColor,
                    maxLength: 6, //pinLength,
                    hasError: hasError,
                    pinBoxColor: Theme.of(context).scaffoldBackgroundColor,
                    pinBoxRadius: 8,
                    pinBoxBorderWidth: 1,
                    onTextChanged: (text) {
                      setState(() {
                        hasError = false;
                      });
                      provider.smsCode = text;
                    },
                    onDone: (text) {
                      _verify();
                    },
                    pinBoxWidth: 50,
                    pinBoxHeight: 50,
                    wrapAlignment: WrapAlignment.spaceBetween,
                    pinTextStyle: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(fontSize: 28, fontWeight: FontWeight.w400),
                    pinTextAnimatedSwitcherTransition:
                        ProvidedPinBoxTextAnimation.scalingTransition,
                    pinTextAnimatedSwitcherDuration:
                        const Duration(milliseconds: 300),
                    highlightAnimationBeginColor: Colors.black,
                    highlightAnimationEndColor: Colors.white12,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              CustomButton(
                onTap: _verify,
                title: 'Submit',
              ),
              const Spacer(),
              InkWell(
                onTap: _resendOTP,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Resend OTP',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ],
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
