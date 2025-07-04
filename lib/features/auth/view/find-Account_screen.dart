import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatter를 위해 필요
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/model/user.dart'; // User 모델 임포트
import '../viewmodel/userinfo_viewmodel.dart';

// 실제 프로젝트에서는 provider 등의 상태 관리 라이브러리를 사용하여 이 ViewModel을 주입받습니다.
// 여기서는 단순화를 위해 직접 인스턴스화합니다.
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> findId(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 아이디 찾기 API 호출 로직 구현 (가상 딜레이)
      await Future.delayed(const Duration(seconds: 2));
      if (email == 'test@example.com') {
        // 성공 시
        _errorMessage = null; // 에러 메시지 초기화
      } else {
        _errorMessage = '등록되지 않은 이메일 주소입니다.';
      }
    } catch (e) {
      _errorMessage = '아이디 찾기 실패: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> findPassword(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 비밀번호 찾기 API 호출 로직 구현 (가상 딜레이)
      await Future.delayed(const Duration(seconds: 2));
      if (userId == 'testuser') {
        // 성공 시
        _errorMessage = null; // 에러 메시지 초기화
      } else {
        _errorMessage = '등록되지 않은 아이디입니다.';
      }
    } catch (e) {
      _errorMessage = '비밀번호 찾기 실패: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class FindAccountScreen extends StatefulWidget {
  const FindAccountScreen({super.key});

  @override
  State<FindAccountScreen> createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _findIdFormKey = GlobalKey<FormState>();
  final _findPasswordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();

  // ViewModel 인스턴스 (실제 프로젝트에서는 Provider로 관리하는 것을 권장)
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ViewModel 초기화
    _authViewModel = AuthViewModel();
    // ViewModel의 상태 변화를 감지하여 UI 업데이트
    _authViewModel.addListener(_onViewModelStateChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _authViewModel.removeListener(_onViewModelStateChanged);
    _authViewModel.dispose(); // ViewModel dispose 추가
    super.dispose();
  }

  void _onViewModelStateChanged() {
    if (mounted) { // 위젯이 마운트된 상태에서만 setState 호출
      setState(() {
        // 로딩 상태 변경 또는 에러 메시지 업데이트 시 UI 갱신
      });
      if (!_authViewModel.isLoading) {
        if (_authViewModel.errorMessage == null) {
          // 성공 메시지
          if (_tabController.index == 0) { // 아이디 찾기 탭
            _showSnack('입력하신 이메일로 아이디를 전송했습니다.');
          } else { // 비밀번호 찾기 탭
            _showSnack('입력하신 이메일로 비밀번호 재설정 링크를 전송했습니다.');
          }
        } else {
          // 에러 메시지
          _showSnack(_authViewModel.errorMessage!);
        }
      }
    }
  }

  // 아이디 찾기
  void _findId() {
    if (_findIdFormKey.currentState?.validate() ?? false) {
      _authViewModel.findId(_emailController.text.trim());
    }
  }

  // 비밀번호 찾기
  void _findPassword() {
    if (_findPasswordFormKey.currentState?.validate() ?? false) {
      _authViewModel.findPassword(_userIdController.text.trim());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // 플로팅 스낵바
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // 둥근 모서리
        margin: const EdgeInsets.all(15), // 여백
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이디/비밀번호 찾기'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor, // 앱 테마 색상 사용
        foregroundColor: Colors.white, // 타이틀 색상 흰색
        leading: IconButton( // EditProfileScreen과 동일한 뒤로가기 버튼 추가
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // 이전 화면으로 돌아가기 (go_router 사용)
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: '아이디 찾기'),
              Tab(text: '비밀번호 찾기'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIdFinderTab(),
                _buildPasswordFinderTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EditProfileScreen의 _buildTextField와 유사하게 통합된 헬퍼 위젯
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isPassword = false,
        int? maxLength,
        TextInputType? keyboardType,
        ValueChanged<String>? onChanged,
        List<TextInputFormatter>? inputFormatters,
        bool readOnly = false,
        InputDecoration? decoration, // decoration을 외부에서 받을 수 있도록 변경
        FormFieldValidator<String>? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // EditProfileScreen과 동일한 패딩
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        decoration: decoration ?? InputDecoration( // 외부에서 decoration이 없으면 기본값 사용
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder( // EditProfileScreen과 동일한 포커스 효과
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          counterText: '', // maxLength 사용 시 숫자 표시 제거
        ),
        validator: validator,
      ),
    );
  }

  /// 이메일 유효성 검사 로직
  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '유효한 이메일 형식이 아닙니다.';
    }
    return null;
  }

  /// 로딩 상태에 따라 위젯 (로딩 인디케이터 또는 버튼)을 전환하는 위젯
  Widget _buildLoadingButton({
    required bool isLoading,
    required VoidCallback onPressed,
    required String buttonText,
    required BuildContext context,
  }) {
    if (isLoading) {
      return const CircularProgressIndicator();
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, // EditProfileScreen 버튼 색상으로 변경
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // EditProfileScreen과 동일한 곡률
          ),
          child: Text(buttonText, style: const TextStyle(fontSize: 18)),
        ),
      );
    }
  }

  Widget _buildIdFinderTab() {
    return Padding(
      padding: const EdgeInsets.all(16), // EditProfileScreen과 동일한 패딩
      child: Form(
        key: _findIdFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView( // Column 대신 ListView 사용하여 스크롤 가능하게 (더 유연함)
          children: [
            _buildTextField(
              _emailController,
              '가입 시 이메일',
              hintText: '예: example@email.com', // _buildTextField 내부에서 hintText 처리 X, decoration을 직접 넘겨야 함
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 20),
            _buildLoadingButton(
              isLoading: _authViewModel.isLoading,
              onPressed: _findId,
              buttonText: '아이디 찾기',
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordFinderTab() {
    return Padding(
      padding: const EdgeInsets.all(16), // EditProfileScreen과 동일한 패딩
      child: Form(
        key: _findPasswordFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView( // Column 대신 ListView 사용하여 스크롤 가능하게 (더 유연함)
          children: [
            _buildTextField(
              _userIdController,
              '아이디(이메일)',
              hintText: '가입 시 사용한 아이디 또는 이메일', // _buildTextField 내부에서 hintText 처리 X, decoration을 직접 넘겨야 함
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 20),
            _buildLoadingButton(
              isLoading: _authViewModel.isLoading,
              onPressed: _findPassword,
              buttonText: '비밀번호 찾기',
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}