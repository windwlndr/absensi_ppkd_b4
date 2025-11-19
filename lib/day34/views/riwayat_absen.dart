import 'package:absensi_ppkd_b4/day34/models/history_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/api_service.dart';

class RiwayatAbsenPage extends StatefulWidget {
  const RiwayatAbsenPage({super.key});

  @override
  State<RiwayatAbsenPage> createState() => _RiwayatAbsenPageState();
}

class _RiwayatAbsenPageState extends State<RiwayatAbsenPage> {
  late Future<List<RiwayatAbsenModel>> last7Days;
  late Future<List<RiwayatAbsenModel>> last30Days;

  @override
  void initState() {
    super.initState();
    last7Days = AuthAPI().getRiwayatAbsen(7);
    last30Days = AuthAPI().getRiwayatAbsen(30);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Absensi"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "7 Hari"),
              Tab(text: "30 Hari"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRiwayatList(last7Days),
            _buildRiwayatList(last30Days),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatList(Future<List<RiwayatAbsenModel>> future) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyView();
        }

        final data = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return _itemTile(data[index]);
          },
        );
      },
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_toggle_off, size: 70, color: Colors.grey),
          SizedBox(height: 8),
          Text("Belum ada riwayat absensi."),
        ],
      ),
    );
  }

  Widget _itemTile(RiwayatAbsenModel item) {
    final tanggal = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.parse(item.attendanceDate));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tanggal,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // Check In
            _rowInfo("Check In", item.checkInTime ?? "-"),
            _rowInfo("Lokasi In", item.checkInAddress ?? "-"),

            const SizedBox(height: 6),

            // Check Out
            _rowInfo("Check Out", item.checkOutTime ?? "-"),
            _rowInfo("Lokasi Out", item.checkOutAddress ?? "-"),

            if (item.status == "izin") ...[
              const SizedBox(height: 8),
              const Divider(),
              Text(
                "Izin: ${item.alasanIzin ?? '-'}",
                style: const TextStyle(
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String title, String value) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text("$title:")),
        Expanded(
          child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
