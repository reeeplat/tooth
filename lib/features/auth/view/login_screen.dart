// C:\Users\sptzk\Desktop\t0703\lib\features\auth\view\login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart'; // AuthViewModel 임포트
import '../../mypage/viewmodel/userinfo_viewmodel.dart'; // UserInfoViewModel 임포트

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 스낵바 표시 유틸리티 함수
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
        backgroundColor: Colors.blueGrey[700], // 스낵바 배경색 변경
      ),
    );
  }

  // 로그인 처리 함수
  Future<void> _login() async {
    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      _showSnack('아이디와 비밀번호를 모두 입력해주세요.');
      return;
    }

    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    final authViewModel = context.read<AuthViewModel>();
    final userInfoViewModel = context.read<UserInfoViewModel>(); // UserInfoViewModel 인스턴스 가져오기

    try {
      // 로그인 시도 중 로딩 인디케이터 표시
      showDialog(
        context: context,
        barrierDismissible: false, // 사용자가 다이얼로그 밖을 탭하여 닫을 수 없도록 설정
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent)); // 로딩 인디케이터 색상 변경
        },
      );

      final user = await authViewModel.loginUser(userId, password); // User 객체 반환 받음

      // 로딩 인디케이터 닫기
      Navigator.of(context).pop();

      if (user != null) {
        userInfoViewModel.loadUser(user); // ✅ 로그인 성공 시 UserInfoViewModel에 사용자 정보 로드
        _showSnack('로그인 성공!');
        context.go('/home'); // 로그인 성공 시 이동할 홈 경로 (필요에 따라 변경)
      }
    } catch (e) {
      // 로딩 인디케이터 닫기 (오류 발생 시에도)
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showSnack(e.toString()); // AuthViewModel에서 throw한 오류 메시지 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '로그인',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), // 앱바 텍스트 색상 변경
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // 앱바 배경색 흰색으로 변경
        elevation: 0.5, // 앱바 그림자 유지
      ),
      body: Container(
        color: Colors.grey[50], // 배경색을 아주 연한 회색으로 변경
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 또는 앱 이름
                  Icon(
                    Icons.lock_open_rounded,
                    size: 80, // 아이콘 크기 줄임
                    color: Colors.blue.shade700, // 아이콘 색상 변경
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '환영합니다!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black87, // 텍스트 색상 변경
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // 아이디 입력 필드
                  TextFormField(
                    controller: _userIdController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87), // 텍스트 색상
                    decoration: InputDecoration(
                      labelText: '아이디 (이메일)',
                      labelStyle: TextStyle(color: Colors.grey[600]), // 라벨 색상
                      hintText: 'example@example.com',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white, // 필드 배경색 흰색으로 변경
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300), // 테두리 색상 변경
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 2), // 포커스 시 테두리
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent), // 에러 텍스트 색상 변경
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '아이디를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호 입력 필드
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: '비밀번호를 입력해주세요',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // 버튼 배경색을 파란색으로 변경
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3, // 그림자 효과 줄임
                        shadowColor: Colors.blueAccent.withOpacity(0.3), // 그림자 색상 변경
                      ),
                      child: Text(
                        '로그인',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white, // 텍스트 색상 흰색으로 변경
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 회원가입 버튼
                  TextButton(
                    onPressed: () => context.go('/register'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade400, width: 1), // 테두리 색상 변경
                      ),
                    ),
                    child: Text(
                      '회원가입',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black54, // 텍스트 색상 변경
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
