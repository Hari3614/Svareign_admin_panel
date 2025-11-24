import 'package:svareignadmin/providers/login_provider/login_provider.dart';

class LoginViewModel {
  final LoginProvider provider;

  LoginViewModel(this.provider);

  Future<bool> authenticateUser() async {
    return await provider.login();
  }
}
