import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:svareignadmin/providers/loginprovider/login_provider.dart';
import 'package:svareignadmin/utils/validators.dart';
import 'package:svareignadmin/viewmodel/loginViewModel/login_view_model.dart';
import 'package:svareignadmin/views/homescreen/homescreen.dart';
import 'package:svareignadmin/widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    final viewModel = LoginViewModel(provider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sky.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Transparent Center Container
          Center(
            child: Container(
              width: 800,
              height: 500,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Left Panel
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          size: 70,
                          color: Colors.pink,
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "SVAREIGN",
                                style: TextStyle(
                                  color: Color(0xFF00E69F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                              TextSpan(
                                text: " PANEL",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Stay in Charge, Stay Ahead.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 42, 42, 42),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: const Color.fromARGB(
                      255,
                      52,
                      52,
                      52,
                    ).withOpacity(0.3),
                  ),

                  // Right Panel
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ADMIN PANEL",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Control login",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(179, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            label: 'Admin ID',
                            icon: Icons.person,
                            onChanged: provider.setEmail,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Password',
                            icon: Icons.lock,
                            onChanged: provider.setPassword,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 20),

                          provider.isLoading
                              ? Center(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Lottie.asset(
                                    'assets/animations/Loadingad.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                              : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();

                                    if (!Validators.isValidEmail(
                                      provider.email,
                                    )) {
                                      showMessage(
                                        context,
                                        "Enter valid email.",
                                      );
                                      return;
                                    }

                                    if (!Validators.isValidPassword(
                                      provider.password,
                                    )) {
                                      showMessage(
                                        context,
                                        "Password must be at least 6 characters.",
                                      );
                                      return;
                                    }

                                    bool isAuthenticated =
                                        await viewModel.authenticateUser();

                                    if (isAuthenticated) {
                                      showMessage(context, "Login Successful!");
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const Homescreen(),
                                        ),
                                      );
                                    } else {
                                      showMessage(
                                        context,
                                        "Invalid credentials",
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00E69F),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "LOG IN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
