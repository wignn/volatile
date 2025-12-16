import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vasvault/authWrapper.dart';
import 'package:vasvault/bloc/login_bloc.dart';
import 'package:vasvault/bloc/profile_bloc.dart'; // ADD THIS
import 'package:vasvault/bloc/register_bloc.dart';
import 'package:vasvault/bloc/vault_bloc.dart';
import 'package:vasvault/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => VaultBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "volatile",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        initialRoute: "/",
        routes: {"/": (context) => const AuthWrapper(), ...routes},
      ),
    );
  }
}