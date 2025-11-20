import 'dart:async';
import 'package:absensi_ppkd_b4/day34/views/profil_user.dart';
import 'package:absensi_ppkd_b4/day34/views/riwayat_absen.dart';
import 'package:absensi_ppkd_b4/day34/widgets/copyright_widget.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';

class DashboardPageDay34 extends StatefulWidget {
  const DashboardPageDay34({super.key});

  @override
  State<DashboardPageDay34> createState() => _DashboardPageDay34State();
}

class _DashboardPageDay34State extends State<DashboardPageDay34> {
  final api = AuthAPI();
  GoogleMapController? mapController;

  StreamSubscription<Position>? positionStream;
  LatLng? currentLatLng;

  String userName = "";
  String? checkInTime;
  String? checkOutTime;
  LatLng? currentPosition;
  String currentAddress = "Mendeteksi lokasi...";
  bool isIzin = false;
  String? izinTime;
  String? izinAlasan;
  bool hasCheckedIn = false;
  bool hasTakenIzin = false;

  String today = DateFormat(
    "EEEE, dd MMMM yyyy",
    "id_ID",
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadUser();
    _initLocation();
    startRealtimeLocation();
    loadCheckHistory();
    loadIzinStatus();
    hasCheckedIn = checkInTime != null;
    hasTakenIzin = isIzin;
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("name") ?? "Pengguna";
    setState(() {});
  }

  Future<void> loadCheckHistory() async {
    final prefs = await SharedPreferences.getInstance();
    checkInTime = prefs.getString("check_in_time");
    checkOutTime = prefs.getString("check_out_time");
    setState(() {});
  }

  // GPS LOCATION
  Future<void> _initLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      openAppSettings(); // WAJIB
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();

    setState(() {
      currentLatLng = LatLng(pos.latitude, pos.longitude);
    });

    final place = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    setState(() {
      currentAddress =
          "${place.first.street}, ${place.first.subLocality}, ${place.first.locality}";
    });
  }

  void startRealtimeLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          currentLatLng = LatLng(pos.latitude, pos.longitude);
          setState(() {});

          // follow user position automatically
          mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng!));
        });
  }

  String formatTime(DateTime date) =>
      DateFormat('HH:mm:ss', 'id_ID').format(date);

  String formatDate(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

  //GET ADDRESS
  Future<String> getAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}";
    } catch (_) {
      return "Tidak diketahui";
    }
  }

  // CHECK IN
  Future<void> handleCheckIn() async {
    if (isIzin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa Check In karena sedang izin")),
      );
      return;
    }
    if (currentLatLng == null) return;

    final now = DateTime.now();
    final timeStr = DateFormat("HH:mm").format(now);
    final dateStr = DateFormat("yyyy-MM-dd").format(now);

    final address = await getAddress(
      currentLatLng!.latitude,
      currentLatLng!.longitude,
    );

    final success = await api.absenCheckIn(
      attendanceDate: dateStr,
      checkIn: timeStr,
      lat: currentLatLng!.latitude,
      lng: currentLatLng!.longitude,
      address: address,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("check_in_time", timeStr);

      setState(() => checkInTime = timeStr);
    }

    print('success: $success');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Berhasil Check In" : "Gagal Check In")),
    );
  }

  // CHECK OUT
  Future<void> handleCheckOut() async {
    if (isIzin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak bisa Check Out karena sedang izin"),
        ),
      );
      return;
    }

    if (checkInTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Anda belum Check In")));
      return;
    }
    if (currentLatLng == null) return;

    final now = DateTime.now();
    final timeStr = DateFormat("HH:mm").format(now);
    final dateStr = DateFormat("yyyy-MM-dd").format(now);

    final address = await getAddress(
      currentLatLng!.latitude,
      currentLatLng!.longitude,
    );

    final success = await api.absenCheckOut(
      attendanceDate: dateStr,
      checkOut: timeStr,
      lat: currentLatLng!.latitude,
      lng: currentLatLng!.longitude,
      address: address,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("check_out_time", timeStr);

      setState(() => checkOutTime = timeStr);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Berhasil Check Out" : "Gagal Check Out"),
      ),
    );
  }

  //STATUS IZIN
  Future<void> loadIzinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isIzin = prefs.getBool("status") ?? false;
    setState(() {});
  }

  Future<void> showIzinDialog() async {
    final alasanController = TextEditingController();

    // Stream real-time untuk jam & tanggal
    Stream<DateTime> timeStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<DateTime>(
          stream: timeStream,
          builder: (context, snapshot) {
            final now = snapshot.data ?? DateTime.now();
            final dateStr = DateFormat("yyyy-MM-dd").format(now);
            final timeStr = DateFormat("HH:mm:ss").format(now);

            return AlertDialog(
              title: const Text("Form Izin"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Real-time tanggal
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Tanggal",
                      hintText: dateStr,
                    ),
                  ),

                  // Real-time waktu
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Jam",
                      hintText: timeStr,
                    ),
                  ),

                  // Input alasan
                  TextField(
                    controller: alasanController,
                    decoration: const InputDecoration(labelText: "Alasan Izin"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Batal"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Kirim"),
                  onPressed: () async {
                    final alasan = alasanController.text.trim();

                    if (alasan.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Alasan izin wajib diisi"),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    final success = await api.submitIzin(
                      date: dateStr,
                      time: timeStr,
                      alasan: alasan,
                    );

                    if (success) {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool("status", true);
                      prefs.setString("izin_time", timeStr);
                      prefs.setString("izin_alasan", alasan);

                      setState(() {
                        isIzin = true;
                        izinTime = timeStr;
                        izinAlasan = alasan;
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Izin berhasil diajukan"
                              : "Gagal mengajukan izin",
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DASHBOARD PAGE UI
  Widget dashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $userName 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(today, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),

            // GOOGLE MAPS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color(0xff176B87),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(8),
                  child: currentLatLng == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: currentLatLng!,
                            zoom: 17,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("me"),
                              position: currentLatLng!,
                              infoWindow: const InfoWindow(
                                title: "Lokasi Anda",
                              ),
                            ),
                          },
                          onMapCreated: (c) => mapController = c,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                        ),
                ),

                // Refresh Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Lokasi Anda saat ini: $currentAddress",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                      ),
                    ),
                    SizedBox(width: 6),
                    IconButton(
                      onPressed: () {
                        _initLocation();
                      },
                      icon: Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CHECK IN / OUT BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BUTTON MASUK
                Expanded(
                  child: ElevatedButton(
                    onPressed: (hasCheckedIn || hasTakenIzin)
                        ? null
                        : handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // BUTTON PULANG
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (hasCheckedIn && !hasTakenIzin && checkOutTime == null)
                        ? handleCheckOut
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Pulang"),
                  ),
                ),

                const SizedBox(width: 12),

                // BUTTON IZIN
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!hasCheckedIn && !hasTakenIzin)
                        ? showIzinDialog
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff86B6F6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Izin",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            //RIWAYAT ABSEN HARI INI
            const SizedBox(height: 10),
            Card(
              color: Color(0xffEEF5FF),
              shadowColor: Color(0xff176B87),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowInfo("Tanggal", today),
                    const SizedBox(height: 8),
                    _rowInfo("Check In", checkInTime ?? "-"),
                    _rowInfo("Check Out", checkOutTime ?? "-"),
                    const SizedBox(height: 8),

                    if (isIzin) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      Text(
                        "Status: Izin",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _rowInfo("Jam Izin", izinTime ?? "-"),
                      _rowInfo("Alasan", izinAlasan ?? "-"),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Statistik Absen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Card(
              color: Color(0xffB4D4FF),
              shadowColor: Color(0xff176B87),
              child: ListTile(
                title: const Text("Hadir Bulan Ini"),
                trailing: const Text("18 Hari"),
              ),
            ),
            Card(
              color: Color(0xffB4D4FF),
              shadowColor: Color(0xff176B87),
              child: ListTile(
                title: const Text("Izin"),
                trailing: const Text("1 Hari"),
              ),
            ),
            Card(
              color: Color(0xffB4D4FF),
              shadowColor: Color(0xff176B87),
              child: ListTile(
                title: const Text("Sakit"),
                trailing: const Text("0 Hari"),
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
    );
  }

  // NAVIGATION
  int currentIndex = 0;
  String getAppBarTitle() {
    switch (currentIndex) {
      case 0:
        return "Absensi PPKD B4"; // Dashboard
      case 1:
        return "Riwayat Absensi";
      case 2:
        return "Profil";
      default:
        return "Absensi PPKD B4";
    }
  }

  Widget getSelectedPage() {
    if (currentIndex == 1) return const RiwayatAbsenPage();
    if (currentIndex == 2) return const ProfileScreen();
    return dashboardContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          getAppBarTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff176B87),
      ),
      body: DefaultTabController(length: 2, child: getSelectedPage()),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xffEEF5FF),
        currentIndex: currentIndex,
        selectedItemColor: Color(0xff176B87),
        unselectedItemColor: Colors.black54,
        onTap: (i) {
          setState(() => currentIndex = i);

          // refresh nama di dashboard
          if (i == 0) loadUser();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _rowInfo(String title, String value) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text("$title:")),
        Expanded(child: Text(value)),
      ],
    );
  }
}
