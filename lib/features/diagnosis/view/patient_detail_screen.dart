// lib/features/diagnosis/view/patient_detail_screen.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../DB/db_helper.dart';

class DiagnosisRequestModel {
  final int id;
  final int userId;
  final String name;
  final String submittedAt;
  final String symptomDetail;
  final String status;
  final String requestType;

  DiagnosisRequestModel.fromJson(Map<String, dynamic> j)
      : id = j['request_id'] ?? 0,
        userId = j['user_id'] ?? 0,
        name = j['user_name'] ?? '',
        submittedAt = j['submitted_at'] ?? '',
        symptomDetail = j['symptom_detail'] ?? '',
        status = j['status'] ?? '',
        requestType = j['request_type'] ?? '';
}

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  int _imgIdx = 0;
  late final List<String> _labels = ['원본', 'AI판단'];
  Uint8List? _imageBytes;

  final _diagnosisCtl = TextEditingController();
  final _planCtl = TextEditingController();

  final patient = <String, String>{
    'id': 'JN7FD168962ZSD6F46',
    'name': '홍길동',
    'gender': '남성',
    'age': '35',
    'tooth': '11, 21',
    'date': '2025/06/26',
  };

  static const _apiBase = 'http://10.0.2.2:5000';
  late Future<List<DiagnosisRequestModel>> _futureRequests;

  @override
  void initState() {
    super.initState();
    _futureRequests = _fetchRequests();
    _loadLocalRecord();
  }

  Future<void> _loadLocalRecord() async {
    final rec = await DBHelper.getRecord(widget.patientId);
    if (rec != null) {
      _diagnosisCtl.text = rec['diagnosis'] ?? '';
      _planCtl.text = rec['plan'] ?? '';
    }
    if (mounted) setState(() {});
  }

  Future<List<DiagnosisRequestModel>> _fetchRequests() async {
    final res = await http.get(Uri.parse('$_apiBase/dashboard/requests'));
    if (res.statusCode != 200) throw Exception('API ${res.statusCode}');
    final list = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return list.map((e) => DiagnosisRequestModel.fromJson(e)).toList();
  }

  void _prev() => setState(() => _imgIdx = (_imgIdx - 1) % _labels.length);
  void _next() => setState(() => _imgIdx = (_imgIdx + 1) % _labels.length);
  void _zoom() {
    if (_imageBytes == null || _imageBytes!.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(child: Image.memory(_imageBytes!)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = _labels[_imgIdx];

    return Scaffold(
      appBar: AppBar(title: const Text('환자 상세 정보'), backgroundColor: const Color(0xFF2d5ca8)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _patientInfoCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _imageCompareCard(label)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _aiResultCard(),
            const SizedBox(height: 24),
            _doctorInputCard(),
          ],
        ),
      ),
    );
  }

  Widget _patientInfoCard() => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('환자 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Text('👤 이름: ${patient['name']}'),
            Text('🆔 ID: ${patient['id']}'),
            Text('♇ 성별: ${patient['gender']}'),
            Text('🎂 나이: ${patient['age']}세'),
            Text('🩧 진료부위: ${patient['tooth']}'),
            Text('🗓️ 방문일: ${patient['date']}'),
          ]),
        ),
      );

  Widget _imageCompareCard(String label) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🖼️ 구각 이미지 비교',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            GestureDetector(
              onTap: _zoom,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 150, minHeight: 100),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: _imageBytes != null && _imageBytes!.isNotEmpty
                      ? Image.memory(_imageBytes!)
                      : Text(label, style: const TextStyle(fontSize: 32, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.arrow_left), onPressed: _prev),
              Text(label),
              IconButton(icon: const Icon(Icons.arrow_right), onPressed: _next),
            ]),
          ]),
        ),
      );

  Widget _aiResultCard() => FutureBuilder<List<DiagnosisRequestModel>>(
        future: _futureRequests,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('⚠️ ${snap.error}'));
          }
          final ai = (snap.data ?? []).firstWhere(
            (e) => '${e.userId}' == widget.patientId,
            orElse: () => DiagnosisRequestModel.fromJson({}),
          );

          if (ai.status.isEmpty) {
            return const Center(child: Text('AI 예측 결과 없음'));
          }

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🤖 AI 진단 결과',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                Text('상태: ${ai.status}'),
                Text('유형: ${ai.requestType}'),
                Text('증상: ${ai.symptomDetail}'),
              ]),
            ),
          );
        },
      );

  Widget _doctorInputCard() => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📝 진단 내용 및 치료 계획',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            TextField(
              controller: _diagnosisCtl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '진단 내용',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _planCtl,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '치료 계획',
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              OutlinedButton(
                onPressed: () {
                  _diagnosisCtl.clear();
                  _planCtl.clear();
                },
                child: const Text('초기화'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  await DBHelper.insertRecord(
                      widget.patientId, _diagnosisCtl.text, _planCtl.text);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('저장되었습니다')));
                },
                child: const Text('저장하기'),
              ),
            ]),
          ]),
        ),
      );
}






