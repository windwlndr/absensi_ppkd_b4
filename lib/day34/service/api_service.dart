import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:absensi_ppkd_b4/day34/models/batch_model.dart';
import 'package:absensi_ppkd_b4/day34/models/history_model.dart';
import 'package:absensi_ppkd_b4/day34/models/list_trainings.dart';
import 'package:absensi_ppkd_b4/day34/models/login_model.dart';
import 'package:absensi_ppkd_b4/day34/models/profile_model.dart';
import 'package:absensi_ppkd_b4/day34/models/register_model.dart';
import 'package:absensi_ppkd_b4/day34/models/user_model.dart';
import 'package:absensi_ppkd_b4/day34/preferences/preference_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  final String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // REGISTER
  Future<RegisterModel?> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },

        body: jsonEncode(data),
      );

      print("STATUS REGISTER: ${response.statusCode}");
      print("BODY REGISTER: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return registerModelFromJson(response.body);
      } else {
        // API error
        return null;
      }
    } catch (e) {
      print("REGISTER ERROR: $e");
      return null;
    }
  }

  // GET LIST TRAINING
  Future<List<TrainingModelData>> getTrainings() async {
    final url = Uri.parse('$baseUrl/trainings');
    final response = await http.get(url);

    print("TRAINING RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final model = listTrainingsModelFromJson(response.body);
      return model.data ?? [];
    }
    return [];
  }

  // GET LIST BATCH
  Future<List<BatchModelData>> getBatchList() async {
    final url = Uri.parse('$baseUrl/batches');
    final response = await http.get(url);

    print("BATCH RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final model = listBatchModelFromJson(response.body);
      return model.data ?? [];
    }
    return [];
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        // PARSE JSON MENGGUNAKAN MODEL LOGIN
        final loginModel = loginModelFromJson(response.body);

        final token = loginModel.data?.token;
        final user = loginModel.data?.user;

        if (token == null || user == null) {
          print("TOKEN ATAU USER TIDAK ADA");
          return false;
        }

        // SIMPAN KE SHARED PREFERENCES
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("token", token);
        await prefs.setInt("user_id", user.id ?? 0);
        await prefs.setString("name", user.name ?? "");
        await prefs.setString("email", user.email ?? "");
        await prefs.setBool("isLogin", true);

        print("LOGIN BERHASIL & DATA DISIMPAN");
        return true;
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  // ABSEN CHECK IN
  Future<bool> absenCheckIn({
    required String attendanceDate,
    required String checkIn,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final url = Uri.parse("$baseUrl/absen/check-in");
    final body = {
      "attendance_date": attendanceDate,
      "check_in": checkIn,
      "check_in_lat": lat,
      "check_in_lng": lng,
      "check_in_address": address,
      "status": "masuk",
    };

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("CHECK IN: ${res.statusCode}");
    print("CHECK IN BODY: ${res.body}");

    return res.statusCode == 200 || res.statusCode == 201;
  }

  // ABSEN CHECK OUT
  Future<bool> absenCheckOut({
    required String attendanceDate,
    required String checkOut,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final url = Uri.parse("$baseUrl/absen/check-out");
    final body = {
      "attendance_date": attendanceDate,
      "check_out": checkOut,
      "check_out_lat": lat,
      "check_out_lng": lng,
      "check_out_address": address,
      "check_out_location": "$lat, $lng",
    };

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("CHECK OUT: ${res.statusCode}");
    print("CHECK OUT BODY: ${res.body}");

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<List<RiwayatAbsenModel>> getRiwayatAbsen(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse("$baseUrl/absen/history");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)["data"];
      return list.map((e) => RiwayatAbsenModel.fromJson(e)).toList();
    }

    return [];
  }

  //Get Token
  // static Future<String?> _getToken() async {
  //   final pref = await SharedPreferences.getInstance();
  //   return pref.getString("token");
  // }

  //Get Profil
  Future<ProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse("$baseUrl/profile");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    log(response.body);
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      print(jsonBody);
      return ProfileModel.fromJson(jsonBody);
    } else {
      throw Exception("Gagal mengambil profil");
    }
  }

  // Future<UserModel> getProfile() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString("token");

  //   if (token == null) {
  //     throw Exception('Token tidak ditemukan. Silakan login kembali.');
  //   }

  //   final url = Uri.parse("$baseUrl/profile");

  //   final response = await http.get(
  //     url,
  //     headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
  //   );

  //   log('Get Profile Response: ${response.body}');
  //   log('Get Profile Status Code: ${response.statusCode}');

  //   final responseBody = json.decode(response.body);

  //   if (response.statusCode == 200) {
  //     return UserModel.fromJson(responseBody);
  //   } else if (response.statusCode == 401) {
  //     throw Exception(
  //       responseBody['message'] ?? 'Sesi berakhir. Silakan login kembali.',
  //     );
  //   } else {
  //     throw Exception(
  //       responseBody['message'] ?? 'Gagal mengambil data profil.',
  //     );
  //   }
  // }

  Future<bool> updateProfile({required String name}) async {
    final token = await SharedPrefHandler.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse("$baseUrl/profile");

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name}),
    );

    log('Update Profile Response: ${response.body}');
    log('Update Profile Status Code: ${response.statusCode}');

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 422) {
      // Gagal validasi, misal: nama kosong
      final errors = responseBody['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first[0];
      throw Exception(firstError);
    } else if (response.statusCode == 401) {
      throw Exception(
        responseBody['message'] ?? 'Sesi berakhir. Login kembali.',
      );
    } else {
      throw Exception(responseBody['message'] ?? 'Gagal memperbarui profil.');
    }
  }

  //Update Foto Profil
  Future<bool> updateProfilePhoto(File file) async {
    final token = await SharedPrefHandler.getToken();

    final url = Uri.parse("$baseUrl/profile/photo");

    var request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath("profile_photo", file.path),
    );

    final response = await request.send();
    return response.statusCode == 200;
  }
}
