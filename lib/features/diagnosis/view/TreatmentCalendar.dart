// treatment_calendar.dart (updated to navigate to PatientDetailScreen on schedule tap)
import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';

class TreatmentCalendarScreen extends StatefulWidget {
  const TreatmentCalendarScreen({super.key});

  @override
  State<TreatmentCalendarScreen> createState() => _TreatmentCalendarScreenState();
}

class _TreatmentCalendarScreenState extends State<TreatmentCalendarScreen> {
  final int year = 2025;
  int month = 7;
  int? selectedDay;

  final Map<String, List<Map<String, dynamic>>> detailedSchedules = {
    '2025-07-02': [
      {'user_id': 101, 'name': '홍길동', 'time': '09:30 - 10:00', 'purpose': '정기 검진', 'status': '신청중'},
    ],
    '2025-07-09': [
      {'user_id': 102, 'name': '김철수', 'time': '10:30 - 11:00', 'purpose': '충치 치료', 'status': '대기중'},
      {'user_id': 103, 'name': '이영희', 'time': '13:30 - 14:00', 'purpose': '임플란트 상담', 'status': '답변완료'},
    ],
    '2025-07-15': [
      {'user_id': 104, 'name': '박예은', 'time': '11:00 - 11:30', 'purpose': '사랑니 치료', 'status': '신청중'},
    ],
  };

  final Map<int, String> daySchedules = {
    2: '종일진료',
    5: '종일진료',
    9: '오전진료',
    15: '오후진료',
    18: '오전진료',
    20: '오후진료',
    25: '오후진료',
  };

  static const Map<String, Color> scheduleColors = {
    '종일진료': Color(0xFF4A90E2),
    '오전진료': Color(0xFF7ED321),
    '오후진료': Color(0xFFD0021B),
  };

  static const Map<String, Color> statusColors = {
    '신청중': Color(0xFFFFD54F),
    '대기중': Color(0xFF4FC3F7),
    '답변완료': Color(0xFF81C784),
  };

  String? selectedDateStr;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday % 7;
    final lastDate = DateTime(year, month + 1, 0).day;
    final blanks = List.generate(firstWeekday, (_) => null);
    final days = List.generate(lastDate, (i) => i + 1);

    selectedDateStr = selectedDay != null
        ? '$year-${month.toString().padLeft(2, '0')}-${selectedDay.toString().padLeft(2, '0')}'
        : null;

    final schedules = selectedDateStr != null
        ? (detailedSchedules[selectedDateStr!] ?? <Map<String, dynamic>>[])
        : <Map<String, dynamic>>[];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildCalendar(blanks, days)),
          const SizedBox(width: 24),
          Expanded(child: _buildSchedulePanel(schedules)),
        ],
      ),
    );
  }

  Widget _buildCalendar(List blanks, List days) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellHeight = 56.0;
        final cellWidth = constraints.maxWidth / 7;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left, size: 20)),
                  Flexible(
                    child: Text('$year년 ${month.toString().padLeft(2, '0')}월',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right, size: 20)),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: ['일', '월', '화', '수', '목', '금', '토']
                    .map((d) => Center(
                        child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold))))
                    .toList(),
              ),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: cellWidth / cellHeight,
                children: [
                  ...blanks.map((_) => const SizedBox()),
                  ...days.map((day) {
                    final type = daySchedules[day];
                    final isSelected = selectedDay == day;
                    final bgColor = isSelected
                        ? Colors.black
                        : scheduleColors[type] ?? Colors.transparent;
                    final textColor = isSelected
                        ? Colors.white
                        : scheduleColors.containsKey(type)
                            ? Colors.white
                            : Colors.black;

                    return GestureDetector(
                      onTap: () => setState(() => selectedDay = day),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: type != null && !isSelected
                              ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(day.toString().padLeft(2, '0'),
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: scheduleColors.entries
                    .map((e) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: e.value, borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 4),
                            Text(e.key, style: const TextStyle(fontSize: 12)),
                          ],
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchedulePanel(List<Map<String, dynamic>> schedules) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedDateStr != null ? '$selectedDateStr 진료 일정' : '날짜를 선택해주세요',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (selectedDateStr == null)
            const Text('날짜를 선택해주세요.')
          else if (schedules.isEmpty)
            const Text('예약된 일정이 없습니다.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (_, idx) {
                  final item = schedules[idx];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailScreen(
                              patientId: item['user_id']),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  '${item['name']} (${item['time']}) | ${item['purpose']}')),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusColors[item['status']] ?? Colors.grey,
                                borderRadius: BorderRadius.circular(14)),
                            child: Text(item['status'] ?? '',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _prevMonth() => setState(() {
        if (month == 1) {
          month = 12;
        } else {
          month -= 1;
        }
        selectedDay = null;
      });

  void _nextMonth() => setState(() {
        if (month == 12) {
          month = 1;
        } else {
          month += 1;
        }
        selectedDay = null;
      });
}
