import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app/router.dart';
import 'app/theme.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'features/chatbot/viewmodel/chatbot_viewmodel.dart';

void main() {
  // 🌐 플랫폼에 따라 API 기본 URL 설정
  final String baseUrl = kIsWeb
      ? "http://127.0.0.1:5000"      // 웹 (Chrome, Edge 등)에서 실행 시
      : "http://10.0.2.2:5000";      // Android 에뮬레이터용 (로컬호스트 접근)

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(baseUrl: baseUrl)),
        ChangeNotifierProvider(create: (_) => UserInfoViewModel()),
        ChangeNotifierProvider(create: (_) => ChatbotViewModel(baseUrl: baseUrl)),
      ],
      child: const MediToothApp(),
    ),
  );
}

class MediToothApp extends StatelessWidget {
  const MediToothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
