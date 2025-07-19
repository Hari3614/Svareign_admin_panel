// lib/viewmodels/login_viewmodel.dart
import 'package:svareignadmin/providers/loginprovider/login_provider.dart';

class LoginViewModel {
  final LoginProvider provider;

  LoginViewModel(this.provider);

  Future<bool> authenticateUser() async {
    return await provider.login();
  }
}
