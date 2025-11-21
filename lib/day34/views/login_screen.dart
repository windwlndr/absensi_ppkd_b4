import 'package:absensi_ppkd_b4/day34/views/register_screen.dart';
import 'package:absensi_ppkd_b4/day34/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';
import 'package:absensi_ppkd_b4/day34/service/api_service.dart';
import 'package:absensi_ppkd_b4/day34/views/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = AuthAPI();

  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  bool isLoading = false;

  Future<void> handleLogin() async {
    setState(() => isLoading = true);

    final success = await auth.login(emailC.text.trim(), passwordC.text.trim());

    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPageDay34()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atau password salah")),
      );
    }
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF176B87), Color(0xFF86B6F6), Color(0xFFB4D4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 420,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage(
                      "assets/images/Absen_Si_Logo.png",
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Absen Si",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Gunakan email dan password",
                    style: TextStyle(color: Color(0xFFE0E7FF)),
                  ),

                  const SizedBox(height: 24),

                  // CARD LOGIN
                  Card(
                    elevation: 14,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      child: Column(
                        children: [
                          // EMAIL
                          buildInputField(
                            label: "Email",
                            icon: Icons.email_outlined,
                            controller: emailC,
                            hint: "masukkan email",
                          ),
                          const SizedBox(height: 18),

                          // PASSWORD
                          buildInputField(
                            label: "Password",
                            icon: Icons.lock_outline,
                            controller: passwordC,
                            hint: "masukkan password",
                            obscure: true,
                          ),
                          const SizedBox(height: 28),

                          // LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF176B87),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading ? null : handleLogin,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Masuk Sekarang",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum punya akun? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: goToRegister,
                                child: const Text(
                                  "Daftar di sini",
                                  style: TextStyle(
                                    color: Color(0xFF176B87),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  CopyrightWidget(
                    companyName: 'Created by Windu Wulandari',
                    startYear: 2025,
                    textStyle: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // REUSABLE INPUT FIELD
  Widget buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87)),
        const SizedBox(height: 6),
        Stack(
          children: [
            TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 48,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 16,
              child: Icon(icon, size: 20, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }
}
