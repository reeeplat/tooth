//C:\Users\sptzk\Desktop\t0703\lib\features\diagnosis\viewmodel\diagnosis_viewmodel.dart
import 'package:flutter/material.dart';
import '../model/tooth_image.dart';

class DiagnosisViewModel extends ChangeNotifier {
  ToothImage? _result;
  ToothImage? get result => _result;

  Future<void> submitImage(String imagePath) async {
    // TODO: 서버로 이미지 전송 후 결과 파싱
    await Future.delayed(const Duration(seconds: 2)); // 모의 대기

    _result = ToothImage(
      imagePath: imagePath,
      diagnosis: '충치 의심',
      toothNumber: '11',
    );

    notifyListeners();
  }

  void clear() {
    _result = null;
    notifyListeners();
  }
}