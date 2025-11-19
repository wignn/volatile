import 'package:volatile/page/Login.dart';
import 'package:volatile/widgets/navigation_menu.dart';
import 'package:volatile/page/Profile.dart';

enum MyRoute {
  login('/login'),
  home('/home'),
  signup('/signup'),
  profile('/profile');

  final String name;
  const MyRoute(this.name);
}

final routes = {
  MyRoute.login.name: (context) => const LoginPage(),
  MyRoute.home.name: (context) => const NavigationMenu(),
  MyRoute.profile.name: (context) => const ProfilePage(),
};