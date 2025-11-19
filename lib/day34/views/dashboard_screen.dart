import 'dart:async';
import 'package:absensi_ppkd_b4/day34/views/profil_user.dart';
import 'package:absensi_ppkd_b4/day34/views/riwayat_absen.dart';
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
  String? currentAddress = "Mendeteksi lokasi...";

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

  // ==============================================
  // GPS LOCATION
  // ==============================================
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

  // ============================
  // ADDRESS GETTER
  // ============================
  Future<String> getAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}";
    } catch (_) {
      return "Tidak diketahui";
    }
  }

  // ============================
  // CHECK IN
  // ============================
  Future<void> handleCheckIn() async {
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

  // ============================
  // CHECK OUT
  // ============================
  Future<void> handleCheckOut() async {
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

  // =====================================
  // DASHBOARD PAGE UI
  // =====================================
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

            // ============================
            // GOOGLE MAPS REALTIME
            // ============================
            SizedBox(
              height: 300,
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
                          infoWindow: const InfoWindow(title: "Lokasi Anda"),
                        ),
                      },
                      onMapCreated: (c) => mapController = c,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                    ),
            ),

            const SizedBox(height: 10),

            // Refresh Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _initLocation();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Lokasi"),
              ),
            ),

            const SizedBox(height: 20),

            // ============================
            // CHECK IN / OUT INFORMATION
            // ============================
            Card(
              child: ListTile(
                title: const Text("Check In"),
                subtitle: Text(checkInTime ?? "-"),
                trailing: ElevatedButton(
                  onPressed: handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Masuk"),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Check Out"),
                subtitle: Text(checkOutTime ?? "-"),
                trailing: ElevatedButton(
                  onPressed: handleCheckOut,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Pulang"),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Statistik Absen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Card(
              child: ListTile(
                title: const Text("Hadir Bulan Ini"),
                trailing: const Text("18 Hari"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Izin"),
                trailing: const Text("1 Hari"),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Sakit"),
                trailing: const Text("0 Hari"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NAVIGATION
  int currentIndex = 0;

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
        title: const Text(
          "Absensi PPKD B4",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black54,
        onTap: (i) => setState(() => currentIndex = i),
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
}
