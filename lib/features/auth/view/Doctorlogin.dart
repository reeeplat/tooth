import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorLoginPage extends StatefulWidget {
  final String role;

  const DoctorLoginPage({Key? key, required this.role}) : super(key: key);

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final _formKey = GlobalKey<FormState>();

  String email = 'doctor1@hospital.com';
  String password = 'doc12345';
  bool rememberMe = true;
  String errorMessage = '';

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://192.168.0.135:5000/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['user'] != null && data['user']['role'] == 'doctor') {
        setState(() {
          errorMessage = '';
        });
        context.go('/doctor-dashboard'); // 로그인 성공 시 이동
      } else {
        setState(() {
          errorMessage = '❌ 아이디 또는 비밀번호가 잘못되었습니다.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '❌ 서버 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDbe9F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        context.go('/role-selection');
                      },
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1976D2)),
                      label: const Text(
                        '이전으로',
                        style: TextStyle(color: Color(0xFF1976D2), fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset('assets/images/tooth_ai_banner.png', width: 220),
                  const SizedBox(height: 24),
                  const Text(
                    '의사 로그인',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1976D2)),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? '이메일을 입력하세요' : null,
                    onChanged: (value) => email = value,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1976D2)),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? '비밀번호를 입력하세요' : null,
                    onChanged: (value) => password = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        '로그인 상태 유지',
                        style: TextStyle(fontSize: 14, color: Color(0xFF444444)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.go('/find-account?role=doctor');
                        },
                        child: const Text(
                          '아이디/비밀번호 찾기',
                          style: TextStyle(color: Color(0xFF1976D2), fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register?role=doctor');
                        },
                        child: const Text(
                          '회원 가입',
                          style: TextStyle(color: Color(0xFF1976D2), fontSize: 13),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



