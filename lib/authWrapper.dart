import 'package:flutter/material.dart';
import 'package:vasvault/routes.dart';
import 'package:vasvault/services/api.dart';
import 'package:vasvault/utils/jwt_decoder.dart';
import 'package:vasvault/utils/session_meneger.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final session = SessionManager();
    final accessToken = await session.getAccessToken();
    final refreshToken = await session.getRefreshToken();

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      _goTo(MyRoute.login.name);
      return;
    }

    final expired = TokenHelper.isExpired(accessToken);
    if (expired) {
      try {
        final response = await _apiService.refreshToken();
        await session.saveSession(
          response.accessToken,
          response.refreshToken,
          await session.getId(),
        );
        _goTo(MyRoute.home.name);
      } catch (e) {
        _goTo(MyRoute.login.name);
      }
    } else {
      Duration remaining = TokenHelper.getRemainingTime(accessToken);
      debugPrint("Token masih aktif, sisa waktu: ${remaining.inMinutes} menit");
      _goTo(MyRoute.home.name);
    }
  }

  void _goTo(String routeName) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      
      body: Center(child: CircularProgressIndicator()),
    );
  }
}