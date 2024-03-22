import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../utils/helper.dart';
import '../service/firebase_service.dart';

enum AuthMode { login, register, phone }


class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxString error = ''.obs;
  String verificationId = '';
  Rx<AuthMode> mode = Rx<AuthMode>(AuthMode.login);

  RxBool isLoading = false.obs;

  void setIsLoading() => isLoading.value = !isLoading.value;

  Future resetPassword() async {
    String? email;
    await showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await auth.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(Get.context!).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(Get.context!).show('Error resetting');
      }
    }
  }

  Future<void> handleMultiFactorException(
      Future<void> Function() authFunction,
      ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      error.value = '${e.message}';
      final firstTotpHint = e.resolver.hints
          .firstWhereOrNull((element) => element is TotpMultiFactorInfo);
      if (firstTotpHint != null) {
        final code = await getSmsCodeFromUser(Get.context!);
        final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
          firstTotpHint.uid,
          code!,
        );
        await e.resolver.resolveSignIn(assertion);
        return;
      }

      final firstPhoneHint = e.resolver.hints
          .firstWhereOrNull((element) => element is PhoneMultiFactorInfo);

      if (firstPhoneHint is! PhoneMultiFactorInfo) {
        return;
      }
      await auth.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstPhoneHint,
        verificationCompleted: (_) {},
        verificationFailed: print,
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await getSmsCodeFromUser(Get.context!);
          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await e.resolver.resolveSignIn(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
              FirebaseService.registerUser();
            } on FirebaseAuthException catch (e) {
              print(e.message);
            }
          }
        },
        codeAutoRetrievalTimeout: print,
      );
    } on FirebaseAuthException catch (e) {
   error.value = '${e.message}';
    } catch (e) {
  error.value = '$e';
    }
   setIsLoading();
  }

  Future<void> emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      if (mode.value == AuthMode.login) {
        await auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        ).then((value) {
          FirebaseService.registerUser(email: emailController.text);
        });
      } else if (mode.value == AuthMode.register) {
        await auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        FirebaseService.registerUser(email: emailController.text);
      } else {
        await _phoneAuth();
      }
    }
  }

  Future<void> _phoneAuth() async {
    if (mode.value != AuthMode.phone) {
      mode.value = AuthMode.phone;
    } else {
      if (kIsWeb) {
        final confirmationResult =
        await auth.signInWithPhoneNumber(phoneController.text);
        final smsCode = await getSmsCodeFromUser(Get.context!);
        if (smsCode != null) {
          await confirmationResult.confirm(smsCode);
        }
      } else {
        await auth.verifyPhoneNumber(
          phoneNumber: phoneController.text,
          verificationCompleted: (_) {},
          verificationFailed: (e) {
            error.value = '${e.message}';
          },
          codeSent: (String verificationId, int? resendToken) async {
            final smsCode = await getSmsCodeFromUser(Get.context!);
            if (smsCode != null) {
              // Create a PhoneAuthCredential with the code
              final credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              );

              try {
                // Sign the user in (or link) with the credential
               await auth.signInWithCredential(credential);
                FirebaseService.registerUser();
              } on FirebaseAuthException catch (e) {
                error.value = e.message ?? '';
              }
            }
          },
          codeAutoRetrievalTimeout: (e) {
            error.value = e;
          },
        );
      }
    }
  }

  Future<String?> getSmsCodeFromUser(BuildContext context) async {
    String? smsCode;

    // Update the UI - wait for the user to enter the SMS code
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('SMS code:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sign in'),
            ),
            OutlinedButton(
              onPressed: () {
                smsCode = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
          content: Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                smsCode = value;
              },
              textAlign: TextAlign.center,
              autofocus: true,
            ),
          ),
        );
      },
    );

    print("sms code");

    return smsCode;
  }
}