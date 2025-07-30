import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart'; // 새 import 추가 - 이미지 인식 플러그인
import 'dart:io';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/services/api_service.dart';

class FoodScreen extends ConsumerStatefulWidget {
  const FoodScreen({super.key});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '분석'),
            Tab(text: '기록'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildAnalysisTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFoodDialog();
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Summary Card
          _buildDailySummaryCard(),
          const SizedBox(height: 16),

          // Meals
          _buildMealSection('아침', Icons.wb_sunny, [
            {'name': '현미밥', 'calories': 150, 'time': '08:00'},
            {'name': '된장찌개', 'calories': 80, 'time': '08:00'},
            {'name': '김치', 'calories': 20, 'time': '08:00'},
          ]),
          const SizedBox(height: 16),

          _buildMealSection('점심', Icons.wb_sunny_outlined, [
            {'name': '닭가슴살 샐러드', 'calories': 320, 'time': '12:30'},
            {'name': '방울토마토', 'calories': 30, 'time': '12:30'},
          ]),
          const SizedBox(height: 16),

          _buildMealSection('저녁', Icons.nightlight_round, []),
          const SizedBox(height: 16),

          _buildMealSection('간식', Icons.cookie, [
            {'name': '아몬드', 'calories': 160, 'time': '15:00'},
          ]),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '오늘의 칼로리',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Circular Progress and Text in a Row
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Row 내부 요소들을 가로축 중앙에 배치 (선택 사항)
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Row 내부 요소들을 세로축 중앙에 배치
              children: [
                // CircularProgressIndicator on the left
                SizedBox(
                  width: 40, // 원 그래프 크기 조절
                  height: 40, // 원 그래프 크기 조절
                  child: CircularProgressIndicator(
                    value: 0.65,
                    strokeWidth: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 24), // 그래프와 텍스트 사이 간격

                // Text on the right
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
                  mainAxisAlignment: MainAxisAlignment.center, // 세로축 중앙 정렬
                  children: [
                    Text(
                      '760',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    Text(
                      '/ 1200 kcal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Macros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMacroInfo('탄수화물', '45g', '30%', Colors.orange),
                _buildMacroInfo('단백질', '65g', '35%', Colors.blue),
                _buildMacroInfo('지방', '30g', '35%', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(
      String name, String amount, String percentage, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          percentage,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildMealSection(
      String mealName, IconData icon, List<Map<String, dynamic>> foods) {
    final totalCalories =
        foods.fold<int>(0, (sum, food) => sum + (food['calories'] as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  mealName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${totalCalories} kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (foods.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '음식을 추가해보세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              )
            else
              ...foods
                  .map((food) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.restaurant,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food['name'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    food['time'] as String,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${food['calories']} kcal',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주간 칼로리 추이',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: Center(
                      child: Text(
                        '차트 영역\n(실제 구현 시 charts_flutter 패키지 사용)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nutrition Analysis
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '영양소 분석',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionBar('탄수화물', 0.6, Colors.orange),
                  const SizedBox(height: 12),
                  _buildNutritionBar('단백질', 0.8, Colors.blue),
                  const SizedBox(height: 12),
                  _buildNutritionBar('지방', 0.4, Colors.green),
                  const SizedBox(height: 12),
                  _buildNutritionBar('식이섬유', 0.3, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 추천',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationItem(
                    '단백질 섭취량을 늘려보세요',
                    '현재 단백질 섭취량이 권장량보다 부족합니다.',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationItem(
                    '식이섬유가 풍부한 음식을 드세요',
                    '야채와 과일 섭취를 늘리면 좋겠어요.',
                    Icons.eco,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBar(String name, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(
      String title, String description, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dates = ['오늘', '어제', '2일 전', '3일 전', '4일 전', '5일 전', '6일 전'];
        final calories = [760, 1180, 1050, 1320, 980, 1150, 1200];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              dates[index],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Text('총 ${calories[index]} kcal'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to detailed day view
            },
          ),
        );
      },
    );
  }

  Future<void> _captureAndRecognize() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked == null) return;

    // ML Kit 초기화 (기본 옵션: 싱글 이미지, 분류 활성화)
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single, // 한 장 사진 처리
      classifyObjects: true, // 물체 분류 (음식 이름 추출)
      multipleObjects: true, // 여러 음식 인식
    );
    final objectDetector = ObjectDetector(options: options);

    // 사진을 InputImage로 변환 (ML Kit 입력 형식)
    final inputImage = InputImage.fromFilePath(picked.path);

    // 아직 인식 안 함 – 다음 단계에서
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);

    // 임시: 콘솔에 출력 (Android Studio 로그 확인)
    print('Detected objects: ${objects.length}');

    List<String> foodNames = [];
    for (var obj in objects) {
      for (var label in obj.labels) {
        if (label.confidence > 0.5) {
          // 신뢰도 50% 이상만
          foodNames.add(label.text); // 음식 이름 (예: "banana")
        }
      }
    }

    // 결과 출력
    if (foodNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음식 인식 실패')),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (_) => ListView(
          children:
              foodNames.map((name) => ListTile(title: Text(name))).toList(),
        ),
      );
    }

    objectDetector.close(); // 메모리 해제

    // 기존 결과 처리 (다음 단계에서 확장)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('사진 찍음: ${objects.length} 물체 감지')),
    );

    final notifier = ref.read(foodRecognitionProvider.notifier);
    await notifier.recognizeFood(File(picked.path));

    final result = ref.read(foodRecognitionProvider);
  }

  void _showAddFoodDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '음식 추가하기',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _captureAndRecognize();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('사진 촬영'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('직접 입력 기능 준비 중입니다')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('직접 입력'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecognitionResultSheet extends StatelessWidget {
  final List<FoodItem> foods;

  const _RecognitionResultSheet({required this.foods});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인식 결과',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...foods.map(
              (f) => ListTile(
                title: Text(f.name),
                subtitle: Text(
                    '${(f.caloriesPerGram * 100).toStringAsFixed(0)} kcal/100g'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
