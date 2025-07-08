import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 인증 관련 화면
import '../features/auth/view/RoleSelectionScreen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/register_screen.dart';
import '../features/auth/view/find-Account_screen.dart';
import '../features/auth/view/Doctorlogin.dart';

// 홈 + 하단 탭 구조 관련
import '../features/home/view/main_scaffold.dart';
import '../features/home/view/home_screen.dart';
import '../features/chatbot/view/chatbot_screen.dart';
import '../features/mypage/view/mypage_screen.dart';
import '../features/mypage/view/edit_profile_screen.dart';

// 진단 관련
import '../features/diagnosis/view/upload_screen.dart';
import '../features/diagnosis/view/result_screen.dart';
import '../features/diagnosis/view/realtime_prediction_screen.dart';
import '../features/diagnosis/view/doctor_dashboard_screen.dart';

// 진단 기록
import '../features/history/view/history_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // 역할 선택 화면
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path:'/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      
      // 로그인
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'user';
          return LoginScreen(role: role);
        },
      ),

      // 의료진 로그인
      GoRoute(
        path: '/doctor-login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'doctor';
          return DoctorLoginPage(role: role);
        },
      ),

      // 회원가입
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'user';
          return RegisterScreen(role: role);
        },
      ),

      // 아이디 찾기
      GoRoute(
        path: '/find-account',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'user';
          return FindAccountScreen(role: role);
        },
      ),

      // 진단 실시간 분석
      GoRoute(
        path: '/diagnosis/realtime',
        builder: (context, state) => const RealtimePredictionScreen(),
      ),

      // ✅ [추가] 의료진 대시보드
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),

      // 메인 앱 구조 (하단 네비게이션 포함)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(
          currentLocation: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => const MyPageScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) => const UploadScreen(),
          ),
          GoRoute(
            path: '/result',
            builder: (context, state) => const ResultScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
    ],
  );
}