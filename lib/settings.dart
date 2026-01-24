import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cat_notebook/cubit/theme_cubit.dart';
import 'package:cat_notebook/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: context.watch<ThemeCubit>().state == ThemeMode.dark
                ? AssetImage('images/settings-bg-dark.png')
                : AssetImage('images/settings-bg-light.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.07),
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 66,
                      fontFamily: 'FREESCPT',
                      color: Color(0xFF009445),
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'User Name',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF009445),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                    child: CircleAvatar(
                      radius: 95,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: NetworkImage(user!.photoURL!),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.08),

                  Container(
                    width: screenWidth * 0.9,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009445),
                        ),
                      ),
                      activeThumbColor: Color(0xFF00632E),
                      value:
                          context.watch<ThemeCubit>().state == ThemeMode.dark,
                      onChanged: (val) {
                        setState(() {
                          context.read<ThemeCubit>().changeTheme(val);
                        });
                      },
                    ),
                  ),
                ],
              ),

              // ************************ Bottom Section ************************ //
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Image.asset(
                        'images/back-to-home-light.png',
                        width: 50,
                        height: 50,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    InkWell(
                      child: Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Color(0xFF009445),
                              size: 30,
                            ),
                            Text(
                              ' Log Out',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF009445),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        GoogleSignIn googleSignIn = GoogleSignIn();
                        googleSignIn.signOut();
                        GoogleSignIn().disconnect();

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.scale,
                          title: 'Log Out',
                          desc: 'Are you sure to log out?',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            GoogleSignIn googleSignIn = GoogleSignIn();
                            googleSignIn.disconnect();
                            await FirebaseAuth.instance.signOut();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ).show();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
