import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> findId(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _errorMessage = (email == 'test@example.com') ? null : '등록되지 않은 이메일 주소입니다.';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> findPassword(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _errorMessage = (userId == 'testuser') ? null : '등록되지 않은 아이디입니다.';
    _isLoading = false;
    notifyListeners();
  }
}

class FindAccountScreen extends StatefulWidget {
  final String role; // 'doctor' 또는 'user'
  const FindAccountScreen({super.key, required this.role});

  @override
  State<FindAccountScreen> createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = AuthViewModel()
      ..addListener(() {
        if (!mounted) return;
        setState(() {});
        if (!_viewModel.isLoading && _viewModel.errorMessage == null) {
          final msg = _tabController.index == 0
              ? '입력하신 이메일로 아이디를 전송했습니다.'
              : '입력하신 이메일로 비밀번호 재설정 링크를 전송했습니다.';
          _showSnack(msg);
        } else if (_viewModel.errorMessage != null) {
          _showSnack(_viewModel.errorMessage!);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _findId() async {
    if (_emailController.text.isNotEmpty) {
      await _viewModel.findId(_emailController.text.trim());
    }
  }

  Future<void> _findPassword() async {
    if (_userIdController.text.isNotEmpty) {
      await _viewModel.findPassword(_userIdController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디/비밀번호 찾기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // role에 따라 로그인 페이지로 정확히 이동
            if (widget.role == 'doctor') {
              context.go('/doctor-login?role=doctor');
            } else {
              context.go('/login?role=user');
            }
          },
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '아이디 찾기'),
              Tab(text: '비밀번호 찾기'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildForm(
                  controller: _emailController,
                  hint: '가입 시 이메일 입력',
                  onSubmit: _findId,
                ),
                _buildForm(
                  controller: _userIdController,
                  hint: '가입 시 사용한 아이디/이메일 입력',
                  onSubmit: _findPassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSubmit,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          _viewModel.isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: onSubmit, child: const Text('전송')),
        ],
      ),
    );
  }
}
