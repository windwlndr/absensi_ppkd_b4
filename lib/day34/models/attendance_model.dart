import 'dart:convert';

CheckInModel checkInModelFromJson(String str) =>
    CheckInModel.fromJson(json.decode(str));

String checkInModelToJson(CheckInModel data) => json.encode(data.toJson());

class CheckInModel {
  String? attendanceDate;
  String? checkIn;
  double? checkInLat;
  double? checkInLng;
  String? checkInAddress;
  String? status;
  String? alasanIzin;

  CheckInModel({
    this.attendanceDate,
    this.checkIn,
    this.checkInLat,
    this.checkInLng,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
  });

  factory CheckInModel.fromJson(Map<String, dynamic> json) => CheckInModel(
    attendanceDate: json["attendance_date"],
    checkIn: json["check_in"],
    checkInLat: (json["check_in_lat"] as num?)?.toDouble(),
    checkInLng: (json["check_in_lng"] as num?)?.toDouble(),
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate,
    "check_in": checkIn,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_address": checkInAddress,
    "status": status,
    if (alasanIzin != null) "alasan_izin": alasanIzin,
  };
}
