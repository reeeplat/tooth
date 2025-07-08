import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  final String role; // 'doctor' 또는 'user'

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedGender = 'M';
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isChecking = false;
  bool _isDuplicate = false;
  bool _isIdChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _checkDuplicateId() async {
    final viewModel = context.read<AuthViewModel>();
    final id = _userIdController.text.trim();

    if (id.length < 4) {
      _showSnack('아이디는 최소 4자 이상이어야 합니다');
      setState(() {
        _isIdChecked = false;
        _isDuplicate = true;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _isIdChecked = false;
    });

    final exists = await viewModel.checkUserIdDuplicate(id);

    setState(() {
      _isChecking = false;
      _isIdChecked = true;
      _isDuplicate = exists ?? true;
    });

    if (exists == null) {
      _showSnack('ID 중복검사 실패: 서버와 연결할 수 없습니다');
    } else if (exists) {
      _showSnack('이미 사용 중인 아이디입니다');
    } else {
      _showSnack('사용 가능한 아이디입니다');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('모든 필드를 올바르게 입력해주세요.');
      return;
    }
    if (!_isIdChecked) {
      _showSnack('아이디 중복 확인이 필요합니다.');
      return;
    }
    if (_isDuplicate) {
      _showSnack('이미 사용 중인 아이디입니다. 다른 아이디를 사용해주세요.');
      return;
    }

    final userData = {
      'name': _nameController.text.trim(),
      'gender': _selectedGender,
      'birth': _birthController.text.trim(),
      'phone': _phoneController.text.trim(),
      'user_id': _userIdController.text.trim(),
      'password': _passwordController.text.trim(),
      'role': widget.role, // role 포함
    };

    final viewModel = context.read<AuthViewModel>();
    final error = await viewModel.registerUser(userData);

    if (error == null) {
      _showSnack('회원가입 성공!');
      final targetLogin = widget.role == 'doctor' ? '/doctor-login?role=doctor' : '/login?role=user';
      context.go(targetLogin);
    } else {
      _showSnack(error);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = widget.role == 'doctor';

    return Scaffold(
      appBar: AppBar(
        title: Text(isDoctor ? '의료진 회원가입' : '일반 회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final targetLogin = isDoctor ? '/doctor-login?role=doctor' : '/login?role=user';
            context.go(targetLogin);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              buildTextField(_nameController, '이름 (한글만)', keyboardType: TextInputType.name),
              buildGenderSelector(),
              buildTextField(
                _birthController,
                '생년월일 (YYYY-MM-DD)',
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
              ),
              buildTextField(
                _phoneController,
                '전화번호 (숫자만)',
                maxLength: 11,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      _userIdController,
                      '아이디 (최소 4자, 최대 20자)',
                      minLength: 4,
                      maxLength: 20,
                      onChanged: (val) {
                        setState(() {
                          _isIdChecked = false;
                          _isDuplicate = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isChecking ? null : _checkDuplicateId,
                    child: _isChecking
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('중복확인'),
                  ),
                ],
              ),
              buildTextField(_passwordController, '비밀번호 (최소 6자)', isPassword: true, minLength: 6),
              buildTextField(_confirmController, '비밀번호 확인', isPassword: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('회원가입 완료')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    int? maxLength,
    int? minLength,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), counterText: ''),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '$label을 입력해주세요';
          if (minLength != null && value.trim().length < minLength) return '$label은 $minLength자 이상이어야 합니다';
          if (label == '비밀번호 확인' && value != _passwordController.text) return '비밀번호가 일치하지 않습니다';
          if (label == '이름 (한글만)' && !RegExp(r'^[가-힣]+$').hasMatch(value)) return '이름은 한글만 입력 가능합니다';
          if (label == '전화번호 (숫자만)' && !RegExp(r'^\d{10,11}$').hasMatch(value)) return '유효한 전화번호를 입력하세요 (숫자 10-11자리)';
          if (label == '생년월일 (YYYY-MM-DD)') {
            if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return '올바른 생년월일 형식(YYYY-MM-DD)으로 입력하세요';
            try {
              final dt = DateTime.parse(value);
              if (dt.isAfter(DateTime.now())) return '생년월일은 오늘을 넘을 수 없습니다';
            } catch (e) {
              return '유효하지 않은 날짜입니다';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Text('성별', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('남'),
              value: 'M',
              groupValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('여'),
              value: 'F',
              groupValue: _selectedGender,
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
          ),
        ],
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue nw) {
    final digits = nw.text.replaceAll(RegExp(r'\D'), '');
    String result = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 6) result += '-';
      result += digits[i];
      if (result.length >= 10) break;
    }
    return nw.copyWith(text: result, selection: TextSelection.collapsed(offset: result.length));
  }
}
