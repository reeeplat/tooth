import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // 추가

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('toothai')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/doctor-login');  // go_router 스타일로 변경
              },
              child: const Text('의료진 로그인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/login');  // 라우터에 정의된 경로와 일치하게 수정
              },
              child: const Text('일반 사용자 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
