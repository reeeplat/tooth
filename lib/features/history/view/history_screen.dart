// C:\Users\sptzk\Desktop\t0703\lib\features\history\view\history_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // go_router 임포트

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ViewModel과 연동하여 진단 기록 리스트 출력
    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 기록'),
        // ✅ 뒤로 가기 버튼 추가
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home'); // 홈 화면으로 이동
          },
        ),
      ),
      body: ListView.builder(
        itemCount: 3, // 임시 더미 데이터
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('🦷 진단 $index'),
            subtitle: const Text('충치 의심 (2025.07.03)'),
            onTap: () {
              // TODO: 상세보기 가능하도록 구현
            },
          );
        },
      ),
    );
  }
}