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
  late Future<List<RiwayatAbsenModel>> riwayatHadir;
  late Future<List<RiwayatAbsenModel>> riwayatIzin;

  @override
  void initState() {
    super.initState();

    riwayatHadir = AuthAPI()
        .getRiwayatAbsen("all")
        .then(
          (list) => list
              .where((e) => e.status == "hadir" || e.status == "masuk")
              .toList(),
        );

    riwayatIzin = AuthAPI()
        .getRiwayatAbsen("all")
        .then((list) => list.where((e) => e.status == "izin").toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabBar(
          labelColor: Color(0xff176B87),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: "Hadir"),
            Tab(text: "Izin"),
          ],
        ),

        Expanded(
          child: TabBarView(
            children: [
              _buildRiwayatList(riwayatHadir, "Belum ada riwayat hadir"),
              _buildRiwayatList(riwayatIzin, "Belum ada riwayat izin"),
            ],
          ),
        ),
      ],
    );
  }

  /// BUILDER LIST
  Widget _buildRiwayatList(
    Future<List<RiwayatAbsenModel>> future,
    String emptyMessage,
  ) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyTab(emptyMessage);
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

  /// EMPTY TAB
  Widget _buildEmptyTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// LIST ITEM
  Widget _itemTile(RiwayatAbsenModel item) {
    final tanggal = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.parse(item.attendanceDate));

    return Card(
      color: const Color(0xffB4D4FF),
      shadowColor: const Color(0xff176B87),
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

            const SizedBox(height: 10),

            /// --- KHUSUS HADIR ---
            if (item.status == "hadir" || item.status == "masuk") ...[
              _rowInfo("Check In", item.checkInTime ?? "-"),
              _rowInfo("Lokasi In", item.checkInAddress ?? "-"),
              const SizedBox(height: 8),
              _rowInfo("Check Out", item.checkOutTime ?? "-"),
              _rowInfo("Lokasi Out", item.checkOutAddress ?? "-"),
            ],

            /// --- KHUSUS IZIN ---
            if (item.status == "izin") ...[
              _rowInfo("Waktu", item.checkInTime ?? "-"),
              _rowInfo("Lokasi", item.checkInAddress ?? "-"),
              const SizedBox(height: 8),
              Text(
                "Alasan: ${item.alasanIzin ?? '-'}",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
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
