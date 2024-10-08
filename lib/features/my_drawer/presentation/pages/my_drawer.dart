import 'package:chat_app/core/service/navigation/routes/routes.dart';
import 'package:chat_app/core/theme/theme.dart';
import 'package:chat_app/core/theme/theme_provider.dart';
import 'package:chat_app/core/utils/user_data.dart';
import 'package:chat_app/core/widgets/profile_picture_holder.dart';
import 'package:chat_app/features/my_drawer/presentation/riverpod/my_drawer_controller.dart';
import 'package:chat_app/features/my_drawer/presentation/riverpod/update_image_controller.dart';
import 'package:chat_app/features/my_drawer/presentation/riverpod/update_status_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyDrawerState();
}

class _MyDrawerState extends ConsumerState<MyDrawer> {
  User? user;
  String? imageUrl;
  bool isActive = true, lightMode = true;
  bool isProfileLoading = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? photoLink =
      'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg';
  SharedPreferences? prefs;
  @override
  void initState() {
    super.initState();
    Future(() async {
      ref.read(myDrawerControllerProvider.notifier).myDrawer();
      prefs = await SharedPreferences.getInstance();
    });
  }

  @override
  Widget build(BuildContext context) {
    lightMode =
        (ref.watch(themeProviderProvider).value == ThemeClass.lightTheme);
    ref.listen(myDrawerControllerProvider, (_, next) {
      if (next.value?.$1 != null && next.value?.$2 == null) {
        setState(() {
          isProfileLoading = false;
          photoLink = (next.value?.$1?.userData.photoUrl)!;
          isActive = (next.value?.$1?.userData.isActive)!;
        });
      } else {
        print(next.value?.$2);
      }
    });

    ref.listen(updateImageControllerProvider, (_, next) {
      if (next.value?.$1 != null) {
        setState(() {
          photoLink = next.value?.$1!.userData.photoUrl;
        });
      } else {
        print(next.value?.$2);
      }
    });

    ref.listen(updateStatusControllerProvider, (_, next) {
      if (next.value?.$1 != null) {
        setState(() {
          isActive = (next.value?.$1!.userData.isActive)!;
        });
      } else {
        print(next.value?.$2);
      }
    });

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Stack(
              children: [
                ProfilePictureHolder(
                  rad: 100,
                  userData: UserData().toMap(
                    isActive: isActive,
                    photoUrl: photoLink,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        onProfileTapped();
                      },
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              '${auth.currentUser?.displayName}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              '${auth.currentUser?.email}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: 'Light mode ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    inactiveTrackColor: Theme.of(context).colorScheme.secondary,
                    value: lightMode,
                    onChanged: (isOn) {
                      if (lightMode) {
                        ref.read(themeProviderProvider.notifier).state =
                            AsyncValue.data(ThemeClass.darkTheme);
                      } else {
                        ref.read(themeProviderProvider.notifier).state =
                            AsyncValue.data(ThemeClass.lightTheme);
                      }
                      lightMode = isOn;
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: 'Active status ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    inactiveTrackColor: Theme.of(context).colorScheme.secondary,
                    value: isActive,
                    onChanged: (isOn) {
                      setState(() {
                        isActive = isOn;
                      });
                      ref
                          .read(updateStatusControllerProvider.notifier)
                          .updateStatus(status: isActive);
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surface,
                ),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  prefs?.setBool('enableCheckBox', false);
                  context.pushReplacement(MyRoutes.login);
                } on FirebaseAuthException catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error!'),
                        content: Text(e.toString()),
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
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void onProfileTapped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('Image not selected');
      return null;
    }
    ref.read(updateImageControllerProvider.notifier).updateImage(
          image: image,
        );
  }
}
