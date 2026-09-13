import 'package:flutter/material.dart';

class _GuideItem {
  final IconData icon;
  final String title;
  final String description;

  const _GuideItem({required this.icon, required this.title, required this.description});
}

const _guideItems = [
  _GuideItem(
    icon: Icons.list_alt,
    title: '목록',
    description: '오른쪽 아래 + 버튼으로 기도 제목을 추가하고, 유형·상태별로 모아볼 수 있어요.',
  ),
  _GuideItem(
    icon: Icons.touch_app,
    title: '진행 기록',
    description: '기도 제목을 누르면 상세 화면에서 상태(긴급/기도 중/응답됨/보류)를 바꾸고 진행 기록을 남길 수 있어요.',
  ),
  _GuideItem(
    icon: Icons.calendar_month,
    title: '날짜별',
    description: '캘린더에서 날짜를 선택하면 그날 등록되거나 기록이 남은 기도 제목을 볼 수 있어요.',
  ),
  _GuideItem(
    icon: Icons.search,
    title: '검색',
    description: '유형·이름·상태·날짜를 조합해서 원하는 기도 제목을 찾을 수 있어요.',
  ),
  _GuideItem(
    icon: Icons.bar_chart,
    title: '통계',
    description: '유형별·대상자별·상태별·월별 등록 건수를 한눈에 확인할 수 있어요.',
  ),
  _GuideItem(
    icon: Icons.backup_outlined,
    title: '데이터 백업',
    description: '설정 안의 카테고리 관리 탭 아래에서 모든 데이터를 파일로 내보내거나 복원할 수 있어요.',
  ),
  _GuideItem(
    icon: Icons.tune,
    title: '설정',
    description: '설정 탭에서 화면 모드(라이트/다크), 앱 색상, 비밀번호를 바꿀 수 있어요.',
  ),
];

class UsageGuideView extends StatelessWidget {
  const UsageGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final item in _guideItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
