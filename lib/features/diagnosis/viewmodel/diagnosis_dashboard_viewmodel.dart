
import 'package:flutter/material.dart';
import '../model/diagnosis_request.dart';

class DiagnosisDashboardViewModel extends ChangeNotifier {
  List<DiagnosisRequest> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DiagnosisRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDiagnosisRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 API 호출로 대체하세요.
      await Future.delayed(const Duration(seconds: 1));

      _requests = [
        DiagnosisRequest(
          id: 1,
          name: '홍길동',
          submittedAt: '2025-06-10',
          symptomDetail: '충치 의심, 잇몸 통증',
          status: '대기중',
          requestType: 'AI 분석',
        ),
        DiagnosisRequest(
          id: 2,
          name: '김철수',
          submittedAt: '2025-06-13',
          symptomDetail: '치아 시림',
          status: '진료중',
          requestType: '비대면',
        ),
      ];
    } catch (e) {
      _errorMessage = '데이터를 불러오는 데 실패했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}