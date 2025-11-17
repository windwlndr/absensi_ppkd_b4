import 'dart:convert';
import 'package:absensi_ppkd_b4/day34/models/batch_model.dart';
import 'package:absensi_ppkd_b4/day34/models/list_trainings.dart';
import 'package:absensi_ppkd_b4/day34/models/register_model.dart';
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

  // LOGIN
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
        final decoded = jsonDecode(response.body);

        final token = decoded["data"]?["token"] ?? decoded["token"];

        if (token == null) {
          print("TOKEN NOT FOUND");
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return true;
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }
}
