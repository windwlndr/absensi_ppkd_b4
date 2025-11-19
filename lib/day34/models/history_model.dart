class RiwayatAbsenModel {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? status;
  final String? alasanIzin;

  RiwayatAbsenModel({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
  });

  factory RiwayatAbsenModel.fromJson(Map<String, dynamic> json) {
    return RiwayatAbsenModel(
      id: json["id"],
      attendanceDate: json["attendance_date"],
      checkInTime: json["check_in_time"],
      checkOutTime: json["check_out_time"],
      checkInAddress: json["check_in_address"],
      checkOutAddress: json["check_out_address"],
      status: json["status"],
      alasanIzin: json["alasan_izin"],
    );
  }
}
