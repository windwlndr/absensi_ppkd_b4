import 'dart:io';
import 'package:absensi_ppkd_b4/day34/models/profile_model.dart';
import 'package:absensi_ppkd_b4/day34/preferences/preference_handler.dart';
import 'package:absensi_ppkd_b4/day34/service/api_service.dart';
import 'package:absensi_ppkd_b4/day34/views/login_screen.dart';
import 'package:absensi_ppkd_b4/day34/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileModel> _profileFuture;

  final authApi = AuthAPI();
  @override
  void initState() {
    super.initState();
    _profileFuture = authApi.getProfile();
  }

  Future<void> _editName(ProfileData user) async {
    final controller = TextEditingController(text: user.name);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nama Baru",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Batal",
                style: TextStyle(color: Color(0xff176B87)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Simpan",
                style: TextStyle(color: Color(0xff176B87)),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newName = controller.text.trim();

      if (newName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama tidak boleh kosong")),
        );
        return;
      }

      try {
        await authApi.updateProfile(name: newName);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', newName);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui")),
        );

        setState(() {
          _profileFuture = authApi.getProfile();
        });

        //Navigator.pop(context, newName);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal update profil: $e")));
      }
    }
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      final file = File(result.path);

      final success = await authApi.updateProfilePhoto(file);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Foto profil diperbarui")));

        setState(() {
          _profileFuture = authApi.getProfile();
        });
      }
    }
  }

  //LOGOUT
  Future<void> _handleLogout() async {
    await SharedPrefHandler.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false, // Hapus semua riwayat navigasi
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data?.data;
          final data = snapshot.data;

          print(users);

          if (users == null) {
            return const Center(child: Text("Tidak ada data profil"));
          }

          return _buildProfileUI(users);
        },
      ),
    );
  }

  Widget _buildProfileUI(ProfileData user) {
    print("user");
    print(user.name);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // FOTO PROFIL
          GestureDetector(
            onTap: _changePhoto,
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: user.profilePhoto != null
                  ? NetworkImage(
                      "https://appabsensi.mobileprojp.com/public/${user.profilePhoto}",
                    )
                  : null,
              child: user.profilePhoto == null
                  ? Icon(Icons.person, size: 60, color: Color(0xff176B87))
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // NAMA + EDIT BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name ?? "",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff176B87),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _editName(user),
                icon: Icon(Icons.edit, color: Color(0xff176B87)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // EMAIL
          Text(
            user.email ?? "",
            style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700),
          ),

          const SizedBox(height: 20),

          // INFO DETAIL
          _infoCard(
            title: "Program Pelatihan",
            value: user.training?.title ?? "-",
            icon: Icons.school,
          ),

          _infoCard(
            title: "Batch",
            value: user.batch?.batchKe ?? "-",
            icon: Icons.calendar_month,
          ),

          _infoCard(
            title: "Jenis Kelamin",
            value: (user.jenisKelamin == "L")
                ? "Laki-laki"
                : (user.jenisKelamin == "P")
                ? "Perempuan"
                : "-",
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFF176B87),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 28),
          CopyrightWidget(
            companyName: 'Created by Windu Wulandari',
            startYear: 2025,
            textStyle: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xff176B87)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
