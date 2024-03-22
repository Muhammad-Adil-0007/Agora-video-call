import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].

extension on AuthMode {
  String get label => this == AuthMode.login
      ? 'Sign in'
      : this == AuthMode.phone
      ? 'Sign in'
      : 'Register';
}

class AuthGate extends StatelessWidget {
  final controller = Get.put(AuthController());
  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Obx(() =>  Form(
                    key: controller.formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: controller.error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              content: SelectableText(controller.error.value),
                              actions: [
                                TextButton(
                                  onPressed: () => controller.error.value = '',
                                  child: const Text(
                                    'dismiss',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                              contentTextStyle:
                                  const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (controller.mode.value != AuthMode.phone)
                            Column(
                              children: [
                                TextFormField(
                                  controller: controller.emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required',
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: controller.passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Password',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required',
                                ),
                              ],
                            ),
                          if (controller.mode.value == AuthMode.phone)
                            TextFormField(
                              controller: controller.phoneController,
                              decoration: const InputDecoration(
                                hintText: '+12345678910',
                                labelText: 'Phone number',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.handleMultiFactorException(
                                controller.emailAndPassword,
                                      ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(controller.mode.value.label),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (controller.mode.value != AuthMode.phone) {
                                          controller.mode.value = AuthMode.phone;
                                      } else {
                                          controller.mode.value = AuthMode.login;
                                      }
                                    },
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(
                                      controller.mode.value != AuthMode.phone
                                          ? 'Sign in with Phone Number'
                                          : 'Sign in with Email and Password',
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (controller.mode.value != AuthMode.phone)
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  TextSpan(
                                    text: controller.mode.value == AuthMode.login
                                        ? "Don't have an account? "
                                        : 'You have an account? ',
                                  ),
                                  TextSpan(
                                    text: controller.mode.value == AuthMode.login
                                        ? 'Register now'
                                        : 'Click to login',
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                          controller.mode.value = controller.mode.value == AuthMode.login
                                              ? AuthMode.register
                                              : AuthMode.login;
                                      },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      )
    );
  }
}
