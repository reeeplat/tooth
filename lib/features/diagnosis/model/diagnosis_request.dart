class DiagnosisRequest {
  final int id;
  final String name;
  final String submittedAt;
  final String symptomDetail;
  final String status;
  final String requestType;

  DiagnosisRequest({
    required this.id,
    required this.name,
    required this.submittedAt,
    required this.symptomDetail,
    required this.status,
    required this.requestType,
  });

  // JSON -> 객체
  factory DiagnosisRequest.fromJson(Map<String, dynamic> json) {
    return DiagnosisRequest(
      id: json['id'] as int,
      name: json['name'] as String,
      submittedAt: json['submitted_at'] as String,
      symptomDetail: json['symptom_detail'] as String,
      status: json['status'] as String,
      requestType: json['request_type'] as String,
    );
  }

  // 객체 -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'submitted_at': submittedAt,
      'symptom_detail': symptomDetail,
      'status': status,
      'request_type': requestType,
    };
  }
}