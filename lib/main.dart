import 'package:cat_notebook/cubit/note_cubit.dart';
import 'package:cat_notebook/cubit/theme_cubit.dart';
import 'package:cat_notebook/home.dart';
import 'package:cat_notebook/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NoteCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cat Notebook',
            theme: ThemeData(
              fontFamily: 'RB Regular',
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              fontFamily: 'RB Regular',
              brightness: Brightness.dark,
            ),
            themeMode: themeMode,
            home: FirebaseAuth.instance.currentUser == null
                ? const LoginPage()
                : const HomePage(),
          );
        },
      ),
    );
  }
}
