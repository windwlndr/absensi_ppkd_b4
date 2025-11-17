import 'dart:convert';
import 'package:absensi_ppkd_b4/day34/models/batch_model.dart';
import 'package:absensi_ppkd_b4/day34/models/list_trainings.dart';
import 'package:absensi_ppkd_b4/day34/service/api_service.dart';
import 'package:absensi_ppkd_b4/day34/views/dashboard_screen.dart';
import 'package:absensi_ppkd_b4/day34/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final auth = AuthAPI();

  String? selectedGender;
  int? selectedTrainingId;
  int? selectedBatchId;
  String? base64Photo;

  final TextEditingController namaC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();

  bool isLoading = false;
  List<TrainingModelData> trainings = [];
  List<BatchModelData> batches = [];

  @override
  void initState() {
    super.initState();
    loadTrainingData();
    loadBatchData();
  }

  Future<void> loadTrainingData() async {
    final list = await auth.getTrainings();
    setState(() => trainings = list);
  }

  Future<void> loadBatchData() async {
    final list = await auth.getBatchList();
    setState(() => batches = list);
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      final bytes = await img.readAsBytes();
      base64Photo = "data:image/png;base64,${base64Encode(bytes)}";
      setState(() {});
    }
  }

  Future<void> handleRegister() async {
    if (selectedTrainingId == null || selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih training dan batch!")),
      );
      return;
    }

    if (base64Photo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload foto profil!")));
      return;
    }

    setState(() => isLoading = true);

    final data = {
      "name": namaC.text,
      "email": emailC.text,
      "password": passwordC.text,
      "jenis_kelamin": selectedGender,
      "profile_photo": base64Photo ?? "",
      "batch_id": selectedBatchId,
      "training_id": selectedTrainingId,
    };

    print("DATA YG DIKIRIM: $data");

    final result = await auth.register(data);

    setState(() => isLoading = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil, silakan login")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi gagal, coba lagi")),
      );
    }
  }

  void handleLoginClick() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF312E81)],
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
                  // HEADER
                  Column(
                    children: const [
                      SizedBox(height: 10),
                      Text(
                        "Aplikasi Absensi",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Daftar untuk memulai",
                        style: TextStyle(color: Color(0xFFE0E7FF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CARD REGISTER
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
                          // FOTO PROFIL
                          GestureDetector(
                            onTap: pickPhoto,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: base64Photo != null
                                      ? MemoryImage(
                                          base64Decode(
                                            base64Photo!.split(",").last,
                                          ),
                                        )
                                      : null,
                                  child: base64Photo == null
                                      ? const Icon(
                                          Icons.camera_alt,
                                          size: 35,
                                          color: Colors.black54,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  base64Photo == null
                                      ? "Upload Foto Profil"
                                      : "Foto Dipilih ✓",
                                  style: TextStyle(
                                    color: base64Photo == null
                                        ? Colors.black54
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // NAMA
                          buildInputField(
                            label: "Nama Lengkap",
                            icon: Icons.people_alt_outlined,
                            controller: namaC,
                            hint: "Masukkan nama lengkap",
                          ),
                          const SizedBox(height: 18),

                          // EMAIL
                          buildInputField(
                            label: "Email",
                            icon: Icons.email_outlined,
                            controller: emailC,
                            hint: "nama@email.com",
                          ),
                          const SizedBox(height: 18),

                          // PASSWORD
                          buildInputField(
                            label: "Password",
                            icon: Icons.lock_outline,
                            controller: passwordC,
                            hint: "Masukkan password",
                            obscure: true,
                          ),
                          const SizedBox(height: 18),

                          // GENDER
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Jenis Kelamin",
                                style: TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedGender,
                                  hint: const Text("Pilih (L / P)"),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "L",
                                      child: Text("Laki-laki"),
                                    ),
                                    DropdownMenuItem(
                                      value: "P",
                                      child: Text("Perempuan"),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => selectedGender = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // SELECT TRAINING
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pilih Pelatihan",
                                style: TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton<int>(
                                  value: selectedTrainingId,
                                  hint: const Text("Pilih pelatihan"),
                                  isExpanded: true,
                                  items: trainings.map((t) {
                                    return DropdownMenuItem<int>(
                                      value: t.id,
                                      child: Text(t.title ?? ""),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => selectedTrainingId = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // SELECT BATCH
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pilih Batch",
                                style: TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButton<int>(
                                  value: selectedBatchId,
                                  hint: const Text("Pilih batch"),
                                  isExpanded: true,
                                  items: batches.map((b) {
                                    return DropdownMenuItem<int>(
                                      value: b.id,
                                      child: Text("Batch ${b.batchKe}"),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => selectedBatchId = value);
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // BUTTON REGISTER
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading ? null : handleRegister,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Daftar Sekarang",
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
                                "Sudah punya akun? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: handleLoginClick,
                                child: const Text(
                                  "Login di sini",
                                  style: TextStyle(
                                    color: Color(0xFF4F46E5),
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

                  const Text(
                    "Dengan mendaftar, Anda menyetujui syarat & ketentuan kami",
                    style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12),
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
