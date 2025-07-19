import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:svareignadmin/core/colors/theme_data.dart';
import 'package:svareignadmin/providers/loginprovider/login_provider.dart';
import 'package:svareignadmin/utils/validators.dart';
import 'package:svareignadmin/viewmodel/loginViewModel/login_view_model.dart';
import 'package:svareignadmin/widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    final viewModel = LoginViewModel(provider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: isMobile ? double.infinity : 400,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset('assets/animations/login.json', height: 150),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Email',
                        icon: Icons.email,
                        onChanged: provider.setEmail,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        icon: Icons.lock,
                        onChanged: provider.setPassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      provider.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              if (!Validators.isValidEmail(provider.email) ||
                                  !Validators.isValidPassword(
                                    provider.password,
                                  )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Invalid email or password format.",
                                    ),
                                  ),
                                );
                                return;
                              }
                              bool isAuthenticated =
                                  await viewModel.authenticateUser();
                              if (isAuthenticated) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login Successful!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid credentials"),
                                  ),
                                );
                              }
                            },
                            child: const Text("Login"),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
