import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/view/login_screen.dart';
import '../features/auth/view/register_screen.dart';
import '../features/home/view/main_scaffold.dart'; // MainScaffold 임포트
import '../features/home/view/home_screen.dart'; // HomeScreen 임포트 (MainScaffold의 자식으로 사용)
import '../features/chatbot/view/chatbot_screen.dart';
import '../features/mypage/view/mypage_screen.dart';
import '../features/diagnosis/view/upload_screen.dart';
import '../features/diagnosis/view/result_screen.dart';
import '../features/history/view/history_screen.dart';
import '../features/diagnosis/view/realtime_prediction_screen.dart';
import '../features/mypage/view/edit_profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>(); // ShellRoute를 위한 별도의 NavigatorKey

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey, // 최상위 NavigatorKey
    initialLocation: '/login', // 앱 시작 시 초기 경로
    routes: [
      // 로그인 및 회원가입 화면 (하단 탭 바 없음)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ✅ ShellRoute: 하단 탭 바가 있는 화면들을 감싸는 역할
      ShellRoute(
        navigatorKey: _shellNavigatorKey, // ShellRoute는 자체 NavigatorKey를 가집니다.
        builder: (context, state, child) {
          // MainScaffold가 하단 탭 바를 제공하고, child는 현재 선택된 탭의 화면입니다.
          // ✅ state.fullPath 대신 state.uri.toString() 사용
          return MainScaffold(child: child, currentLocation: state.uri.toString());
        },
        routes: [
          // MainScaffold 내부에 표시될 탭 화면들
          GoRoute(
            path: '/home', // 홈 탭
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chatbot', // 챗봇 탭
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/mypage', // 마이페이지 탭
            builder: (context, state) => const MyPageScreen(),
            routes: [
              // 개인정보 수정 화면은 마이페이지 탭의 하위 라우트로 중첩
              GoRoute(
                path: 'edit', // '/mypage/edit' 경로가 됨
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/history', // 진단 기록 화면 (탭에서 접근 가능)
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/upload', // 사진 진단 업로드 화면 (탭에서 접근 가능)
            builder: (context, state) => const UploadScreen(),
          ),
          GoRoute(
            path: '/result', // 진단 결과 화면 (탭에서 접근 가능)
            builder: (context, state) => const ResultScreen(),
          ),
        ],
      ),

      // ShellRoute 외부에 있는 화면 (하단 탭 바 없음)
      // 예: 실시간 예측 화면 (전체 화면으로 표시)
      GoRoute(
        path: '/diagnosis/realtime',
        builder: (context, state) => const RealtimePredictionScreen(),
      ),
    ],
  );
}