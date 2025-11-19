// To parse this JSON data, do
//
//     final izinModel = izinModelFromJson(jsonString);

import 'dart:convert';

IzinModel izinModelFromJson(String str) => IzinModel.fromJson(json.decode(str));

String izinModelToJson(IzinModel data) => json.encode(data.toJson());

class IzinModel {
  String message;
  IzinData data;

  IzinModel({required this.message, required this.data});

  factory IzinModel.fromJson(Map<String, dynamic> json) => IzinModel(
    message: json["message"],
    data: IzinData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class IzinData {
  int id;
  DateTime attendanceDate;
  dynamic checkInTime;
  dynamic checkInLat;
  dynamic checkInLng;
  dynamic checkInLocation;
  dynamic checkInAddress;
  String status;
  String alasanIzin;

  IzinData({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInLocation,
    required this.checkInAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory IzinData.fromJson(Map<String, dynamic> json) => IzinData(
    id: json["id"],
    attendanceDate: DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"],
    checkInLng: json["check_in_lng"],
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
