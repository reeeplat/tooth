// C:\Users\sptzk\Desktop\t0703\lib\features\diagnosis\view\result_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ViewModel과 연동하여 진단 결과 출력
    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ 진단 결과 화면에서 '사진으로 예측하기' 화면으로 직접 이동
            // 일반적으로는 context.pop()을 사용하여 이전 스택으로 돌아가지만,
            // 특정 상황에서 반응이 없을 경우 context.go()를 사용하여 명시적으로 이동할 수 있습니다.
            context.go('/upload'); 
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '진단 결과가 여기에 표시됩니다.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // TODO: 실제 진단 이미지 및 결과 데이터 표시
            const Text('충치 의심 (치아 21번)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Image.network(
              'https://placehold.co/300x200/png?text=Diagnosis+Result', // Placeholder Image
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
            ),
          ],
        ),
      ),
    );
  }
}