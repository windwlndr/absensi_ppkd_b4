import 'package:absensi_ppkd_b4/day34/views/maps_detail_screen.dart';
import 'package:absensi_ppkd_b4/day34/views/profil_user.dart';
import 'package:absensi_ppkd_b4/day34/views/riwayat_absen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';

class DashboardPageDay34 extends StatefulWidget {
  const DashboardPageDay34({super.key});

  @override
  State<DashboardPageDay34> createState() => _DashboardPageDay34State();
}

class _DashboardPageDay34State extends State<DashboardPageDay34> {
  final api = AuthAPI();
  String userName = "";
  int currentIndex = 0;

  String today = DateFormat(
    "EEEE, dd MMMM yyyy",
    "id_ID",
  ).format(DateTime.now());

  double? lat;
  double? lng;

  @override
  void initState() {
    super.initState();
    loadUser();
    getLocation();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("name") ?? "Pengguna";
    setState(() {});
  }

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    lat = pos.latitude;
    lng = pos.longitude;

    setState(() {});
  }

  Future<void> handleCheckIn() async {
    if (lat == null) return;

    final now = DateTime.now();

    final success = await api.absenCheckIn(
      attendanceDate: DateFormat("yyyy-MM-dd").format(now),
      checkIn: DateFormat("HH:mm:ss").format(now),
      lat: lat!,
      lng: lng!,
      address: "Lokasi pengguna",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Absen Masuk Berhasil" : "Gagal Absen Masuk"),
      ),
    );
  }

  Future<void> handleCheckOut() async {
    if (lat == null) return;

    final now = DateTime.now();

    final success = await api.absenCheckOut(
      attendanceDate: DateFormat("yyyy-MM-dd").format(now),
      checkOut: DateFormat("HH:mm:ss").format(now),
      lat: lat!,
      lng: lng!,
      address: "Lokasi pengguna",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Absen Pulang Berhasil" : "Gagal Absen Pulang"),
      ),
    );
  }

  // ==========================
  // BOTTOM NAV BAR SWITCH
  // ==========================
  Widget getSelectedPage() {
    if (currentIndex == 1) {
      return const RiwayatAbsenPage(); // Buat nanti
    } else if (currentIndex == 2) {
      return const ProfilePage(); // Buat nanti
    }
    return buildDashboardContent(); // default: dashboard
  }

  // ==========================
  // DASHBOARD UI CONTENT
  // ==========================
  Widget buildDashboardContent() {
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

            // LOCATION STATUS
            if (lat != null)
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  Text("Lokasi: $lat, $lng"),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapDetailPage(lat: lat!, lng: lng!),
                        ),
                      );
                    },
                    child: const Text("Lihat Map"),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: handleCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Absen Masuk"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: handleCheckOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Absen Pulang"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Statistik Absen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

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

            const SizedBox(height: 20),

            const Text(
              "Absensi Hari Ini",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Card(
              child: ListTile(
                title: const Text("Check In"),
                trailing: Text(DateFormat("HH:mm").format(DateTime.now())),
              ),
            ),
            Card(
              child: const ListTile(
                title: Text("Check Out"),
                trailing: Text("-"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // MAIN BUILD
  // ==========================
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
        onTap: (index) {
          setState(() => currentIndex = index);
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
}
