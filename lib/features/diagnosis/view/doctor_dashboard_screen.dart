import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'patient_detail_screen.dart';
import 'TreatmentCalendar.dart';

/*──────────────── 모델 ────────────────*/
class DiagnosisRequestModel {
  final int id;
  final int userId;
  final String name;
  final String submittedAt;
  final String symptomDetail;
  final String status;
  final String requestType;

  DiagnosisRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.submittedAt,
    required this.symptomDetail,
    required this.status,
    required this.requestType,
  });

  factory DiagnosisRequestModel.fromJson(Map<String, dynamic> j) {
    return DiagnosisRequestModel(
      id: j['request_id'] is int ? j['request_id'] : int.tryParse('${j['request_id']}') ?? 0,
      userId: j['user_id'] is int ? j['user_id'] : int.tryParse('${j['user_id']}') ?? 0,
      name: j['user_name'] ?? '이름 없음',
      submittedAt: j['submitted_at'] ?? '',
      symptomDetail: j['symptom_detail'] ?? '',
      status: j['status'] ?? '알 수 없음',
      requestType: j['request_type'] ?? '',
    );
  }
}

/*──────────────── 대시보드 ────────────────*/
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  static const String apiBase = 'http://192.168.0.135:5000';

  /// 0 = 진료 목록, 1 = 캘린더
  int _selectedIndex = 0;
  late Future<List<DiagnosisRequestModel>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = _fetchRequests();
  }

  /*───────── API 호출 ─────────*/
  Future<List<DiagnosisRequestModel>> _fetchRequests() async {
    final res = await http.get(Uri.parse('$apiBase/dashboard/requests'));
    if (res.statusCode != 200) throw Exception('요청 실패: ${res.statusCode}');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => DiagnosisRequestModel.fromJson(e)).toList();
  }

  /*───────── 뱃지 색상 ─────────*/
  Color _badgeBg(String s) => {
        '진료중':  const Color(0xFFFFE7BA),
        '대기중':  const Color(0xFFCCE4FF),
        '답변완료': const Color(0xFFD1F5D0),
      }[s] ?? Colors.grey.shade300;

  Color _badgeFg(String s) => {
        '진료중':  const Color(0xFFB36B00),
        '대기중':  const Color(0xFF1E5CB3),
        '답변완료': const Color(0xFF2B8C28),
      }[s] ?? Colors.black87;

  /*───────── 환자 상세로 이동 ─────────*/
  void _openPatient(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patientId: userId.toString()),
      ),
    );
  }

  /*───────── 사이드바 ─────────*/
  Widget _buildSidebar() {
    final items = ['비대면 진료 신청', '진료 캘린더'];
    return Container(
      width: 220,
      color: const Color(0xFF2D5CA8),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Text('TOOTH AI',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ElevatedButton(
                onPressed: () => setState(() => _selectedIndex = i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == i ? Colors.white : const Color(0xFF2D5CA8),
                  foregroundColor: _selectedIndex == i ? const Color(0xFF2D5CA8) : Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(items[i], style: const TextStyle(fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }

  /*───────── 진료 목록 ─────────*/
  Widget _buildRequestList() {
    return FutureBuilder<List<DiagnosisRequestModel>>(
      future: _futureRequests,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('⚠️ ${snap.error}'));

        final list = snap.data ?? [];
        if (list.isEmpty) return const Center(child: Text('📭 요청이 없습니다.'));

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _futureRequests = _fetchRequests());
            await _futureRequests;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: list.length,
            itemBuilder: (_, idx) {
              final r = list[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  title: Text(r.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('${r.submittedAt}  |  ${r.symptomDetail}'),
                      const SizedBox(height: 4),
                      Text('요청 유형: ${r.requestType}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _badgeBg(r.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r.status,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: _badgeFg(r.status))),
                  ),
                  onTap: () => _openPatient(r.userId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /*───────── build ─────────*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBE9F5),
      body: Row(
        children: [
          _buildSidebar(),                           // ▶ 항상 고정된 사이드바
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _selectedIndex == 0
                  ? _buildRequestList()
                  : const TreatmentCalendarScreen(),
            ),
          ),
        ],
      ),
    );
  }
}




