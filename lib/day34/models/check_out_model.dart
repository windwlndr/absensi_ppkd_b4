import 'dart:convert';

CheckOutModel checkOutModelFromJson(String str) =>
    CheckOutModel.fromJson(json.decode(str));

String checkOutModelToJson(CheckOutModel data) => json.encode(data.toJson());

class CheckOutModel {
  String? attendanceDate;
  String? checkOut;
  double? checkOutLat;
  double? checkOutLng;
  String? checkOutLocation;
  String? checkOutAddress;

  CheckOutModel({
    this.attendanceDate,
    this.checkOut,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutLocation,
    this.checkOutAddress,
  });

  factory CheckOutModel.fromJson(Map<String, dynamic> json) => CheckOutModel(
    attendanceDate: json["attendance_date"],
    checkOut: json["check_out"],
    checkOutLat: (json["check_out_lat"] as num?)?.toDouble(),
    checkOutLng: (json["check_out_lng"] as num?)?.toDouble(),
    checkOutLocation: json["check_out_location"],
    checkOutAddress: json["check_out_address"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate,
    "check_out": checkOut,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
  };
}
