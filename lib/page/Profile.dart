// filepath: c:\Users\tigfi\Desktop\volatile\lib\page\Profile.dart
import 'package:flutter/material.dart';
import 'package:volatile/utils/session_meneger.dart';
import 'package:volatile/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionManager = SessionManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          key: const Key('LogoutButton'),
          onPressed: () async {
            await sessionManager.removeAccessToken();
            // Navigate to login and clear navigation stack
            Navigator.pushNamedAndRemoveUntil(
              context,
              MyRoute.login.name,
              (route) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

