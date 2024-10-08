import 'package:chat_app/core/gen/assets.gen.dart';
import 'package:chat_app/core/service/navigation/routes/routes.dart';
import 'package:chat_app/core/utils/google_sign_in.dart';
import 'package:chat_app/core/validator/email_validator.dart';
import 'package:chat_app/core/validator/password_validation.dart';
import 'package:chat_app/core/widgets/custom_password_field.dart';
import 'package:chat_app/core/widgets/custom_text_field.dart';
import 'package:chat_app/features/sign_up/presentation/riverpod/sign_up_controller.dart';
import 'package:chat_app/core/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUpPage> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController emailCtr = TextEditingController();
  TextEditingController passCtr = TextEditingController();
  TextEditingController confirmPassCtr = TextEditingController();
  String? emailFieldError, conPassdFieldError, passdFieldError;

  ({
    bool isNameEnable,
    bool isEmailEnable,
    bool isPassEnable,
    bool isConfirmPass,
  }) buttonNotifier = (
    isNameEnable: false,
    isEmailEnable: false,
    isPassEnable: false,
    isConfirmPass: false,
  );

  @override
  void initState() {
    super.initState();
    nameCtr.addListener(() {
      _enableButtonState();
    });
    emailCtr.addListener(() {
      _enableButtonState();
    });
    passCtr.addListener(() {
      _enableButtonState();
    });
    confirmPassCtr.addListener(() {
      _enableButtonState();
    });
  }

  void _enableButtonState() {
    setState(() {
      buttonNotifier = (
        isNameEnable: nameCtr.text.isNotEmpty,
        isEmailEnable: emailCtr.text.isNotEmpty,
        isPassEnable: passCtr.text.isNotEmpty,
        isConfirmPass: confirmPassCtr.text.isNotEmpty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpControllerProvider);
    ref.listen(signUpControllerProvider, (_, next) {
      if (next.value?.$1 == null && next.value?.$2 == null) {
        const CircularProgressIndicator();
      } else if (next.value?.$1 != null && next.value?.$2 == null) {
        context.push(MyRoutes.login);
      } else if (next.value?.$1 == null && next.value?.$2 != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error!'),
              content: Text('${next.value?.$2}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Create an account',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 15),
                      const Text('Connect with your friend today!'),
                    ],
                  ),
                ),
                const SizedBox(height: 90),
                CustomTextField(
                  controller: nameCtr,
                  image: Assets.images.user.provider(),
                  text: 'User name',
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: emailCtr,
                  image: Assets.images.mail.provider(),
                  text: 'email',
                  fieldError: emailFieldError,
                ),
                const SizedBox(height: 15),
                CustomPassField(
                  controller: passCtr,
                  prefixIcon: Assets.images.padlock.provider(),
                  hintText: 'password',
                  fieldError: passdFieldError,
                ),
                const SizedBox(height: 15),
                CustomPassField(
                  controller: confirmPassCtr,
                  prefixIcon: Assets.images.padlock.provider(),
                  hintText: 'Confirm password',
                  fieldError: conPassdFieldError,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: (buttonNotifier.isNameEnable &
                          buttonNotifier.isEmailEnable &
                          buttonNotifier.isPassEnable &
                          buttonNotifier.isConfirmPass)
                      ? ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.primary,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.surface,
                          ),
                        )
                      : null,
                  onPressed: (buttonNotifier.isNameEnable &
                          buttonNotifier.isEmailEnable &
                          buttonNotifier.isPassEnable &
                          buttonNotifier.isConfirmPass)
                      ? () {
                          final emailValidator = EmailValidation();
                          final passValidator = PasswordValidation();
                          bool isEmailValid =
                              emailValidator.validateEmail(emailCtr.text);
                          bool isPassValid =
                              passValidator.validatePassword(passCtr.text);
                          bool doPassesMatch =
                              passCtr.text == confirmPassCtr.text;

                          setState(() {
                            emailFieldError =
                                (isEmailValid) ? null : 'Invalid email';
                            passdFieldError = (isPassValid)
                                ? null
                                : 'Password length must be greater than 5';
                            conPassdFieldError = (doPassesMatch)
                                ? null
                                : 'passwaords must be same';
                          });

                          if (isEmailValid && isPassValid && doPassesMatch) {
                            ref.read(signUpControllerProvider.notifier).signUp(
                                  UserData(
                                    name: nameCtr.text,
                                    email: emailCtr.text,
                                    password: passCtr.text,
                                  ),
                                );
                          }
                        }
                      : null,
                  child: (state.isLoading)
                      ? CircularProgressIndicator(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.go(MyRoutes.login);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 1,
                      width: 135,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const Text(
                      'OR',
                      style: TextStyle(color: Color(0xFF797C7B)),
                    ),
                    Container(
                      height: 1,
                      width: 135,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: const ButtonStyle(
                    elevation: WidgetStatePropertyAll(0),
                  ),
                  onPressed: () async {
                    final userCredential =
                        await MyGoogleSignIn().signInWithGoogle();
                    if (userCredential != null) {
                      final user = userCredential.user;
                      ref
                          .read(signUpControllerProvider.notifier)
                          .saveGoogleUser(user: user);
                      context.go(MyRoutes.homePage);
                    } else {
                      print('Sign-in failed.');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.images.googleLogo.image(
                        height: 25,
                        width: 25,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'Sign in with google',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
