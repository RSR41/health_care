import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../providers/activity_providers.dart';
import '../../../features/food/providers/food_providers.dart';
import '../../../features/food/repositories/food_entry_repository.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(context),
            const SizedBox(height: 16),
            
            // Today's Summary
            _buildTodaySummary(context, ref),
            const SizedBox(height: 16),

            // Today's Food Summary
            _buildTodaysFoodSummary(context, ref),
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActions(context),
            const SizedBox(height: 16),
            
            // Recent Activities
            _buildRecentActivities(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요! 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '오늘도 건강한 하루를 시작해보세요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '오늘 날씨: 맑음 22°C',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, WidgetRef ref) {
    final todayGoalProgress = ref.watch(todayGoalProgressProvider);
    final todayActivitySummary = ref.watch(todayActivitySummaryProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 활동',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        todayActivitySummary.when(
          data: (summary) => todayGoalProgress.when(
            data: (progress) {
              final steps = summary['steps']?.toInt() ?? 0;
              final calories = summary['calories']?.toInt() ?? 0;
              final activeMinutes = summary['activeMinutes']?.toInt() ?? 0;
              final distance = summary['distance']?.toDouble() ?? 0.0;
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          icon: Icons.directions_walk,
                          title: '걸음 수',
                          value: _formatNumber(steps),
                          unit: '걸음',
                          progress: progress['steps']?.clamp(0.0, 1.0) ?? 0.0,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          icon: Icons.local_fire_department,
                          title: '칼로리',
                          value: calories.toString(),
                          unit: 'kcal',
                          progress: progress['calories']?.clamp(0.0, 1.0) ?? 0.0,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          icon: Icons.timer,
                          title: '활동 시간',
                          value: activeMinutes.toString(),
                          unit: '분',
                          progress: progress['activeMinutes']?.clamp(0.0, 1.0) ?? 0.0,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context: context,
                          icon: Icons.straighten,
                          title: '이동 거리',
                          value: distance.toStringAsFixed(1),
                          unit: 'km',
                          progress: progress['distance']?.clamp(0.0, 1.0) ?? 0.0,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => _buildLoadingSummaryCards(context),
            error: (_, __) => _buildErrorSummaryCards(context),
          ),
          loading: () => _buildLoadingSummaryCards(context),
          error: (_, __) => _buildErrorSummaryCards(context),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required double progress,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$value $unit',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}% 달성',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysFoodSummary(BuildContext context, WidgetRef ref) {
    final todayNutrition = ref.watch(todayNutritionProvider);
    final todayMeals = ref.watch(todayMealsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '오늘의 식단',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                context.go(AppRoutes.food);
              },
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              label: Text('더 보기'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // AI 추천 배너
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI가 분석한 음식을 바로 기록해보세요!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NEW',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 칼로리 요약
                todayNutrition.when(
                  data: (nutrition) {
                    final totalCalories = nutrition?.totalCalories?.round() ?? 0;
                    final calorieGoal = nutrition?.calorieGoal?.round() ?? 1800;
                    final progress = calorieGoal > 0 ? (totalCalories / calorieGoal).clamp(0.0, 1.0) : 0.0;
                    
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '오늘 섭취한 칼로리',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    totalCalories.toString(),
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                                    child: Text(
                                      '/ $calorieGoal kcal',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 원형 진행률
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 6,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${(progress * 100).round()}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘 섭취한 칼로리',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                  error: (_, __) => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘 섭취한 칼로리',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('오류'),
                          ],
                        ),
                      ),
                      const Icon(Icons.error, color: Colors.red, size: 60),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 최근 식단 및 AI 촬영 버튼
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최근 식단',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // 실제 식사 데이터 사용
                          todayMeals.when(
                            data: (meals) {
                              if (meals.isEmpty) {
                                return Text(
                                  '오늘 아직 식사 기록이 없습니다',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                );
                              }
                              
                              // 최근 3개 식사만 표시
                              final recentMeals = meals.take(3).toList();
                              
                              return Column(
                                children: recentMeals.asMap().entries.map((entry) {
                                  final meal = entry.value;
                                  final calories = _calculateMealCalories(meal);
                                  final time = _formatTime(meal.entry.timestamp);
                                  final mealTypeName = _getMealTypeName(meal.entry.mealType);
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: entry.key < recentMeals.length - 1 ? 6.0 : 0.0),
                                    child: _buildRecentMealItem(
                                      context,
                                      mealTypeName,
                                      meal.food.nameKo,
                                      '${calories.round()} kcal',
                                      time,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => Text(
                              '식사 데이터를 불러올 수 없습니다',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // AI 촬영 버튼
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // AI 인식 탭으로 직접 이동
                                context.go(AppRoutes.food);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'AI 촬영',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '음식 촬영하고\n영양 정보 확인',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMealItem(BuildContext context, String mealType, String foodName, String calories, String time) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getMealColor(mealType),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$mealType • $time',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                foodName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          calories,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case '아침':
        return Colors.orange;
      case '점심':
        return Colors.green;
      case '저녁':
        return Colors.blue;
      case '간식':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 실행',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(context,
                icon: Icons.camera_alt,
                title: 'AI 음식 인식',
                subtitle: '사진으로 영양 분석',
                onTap: () {
                  context.go(AppRoutes.food);
                },
                isAI: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(context,
                icon: Icons.chat,
                title: 'AI 상담',
                subtitle: '건강 상담받기',
                onTap: () {
                  // TODO: Navigate to chat
                },
                isAI: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(context,
                icon: Icons.fitness_center,
                title: '운동 시작',
                subtitle: '맞춤 운동하기',
                onTap: () {
                  // TODO: Navigate to exercise
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(context,
                icon: Icons.assessment,
                title: '건강 리포트',
                subtitle: '분석 결과 보기',
                onTap: () {
                  // TODO: Navigate to report
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isAI = false,
  }) {
    return Card(
      elevation: isAI ? 3 : 1,
      child: Container(
        decoration: isAI
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    if (isAI)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.psychology,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAI ? Theme.of(context).colorScheme.primary : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAI
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isAI) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'AI',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, WidgetRef ref) {
    final recentWorkouts = ref.watch(recentWorkoutsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 활동',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        recentWorkouts.when(
          data: (workouts) {
            if (workouts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '최근 운동 기록이 없습니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '새 운동을 시작해보세요!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workouts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  final icon = _getWorkoutIcon(workout.type);
                  final color = _getWorkoutColor(workout.type);
                  final timeFormatted = _formatTime(workout.startTime);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${workout.duration}분 • ${workout.caloriesBurned} kcal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      timeFormatted,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            );
          },
          loading: () => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    '운동 기록을 불러오는 중...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.error,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '운동 기록을 불러올 수 없습니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 로딩 상태의 요약 카드들
  Widget _buildLoadingSummaryCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingSummaryCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingSummaryCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLoadingSummaryCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingSummaryCard(context)),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLoadingSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_empty, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '로딩 중...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
  
  // 에러 상태의 요약 카드들
  Widget _buildErrorSummaryCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildErrorSummaryCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildErrorSummaryCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildErrorSummaryCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildErrorSummaryCard(context)),
          ],
        ),
      ],
    );
  }
  
  Widget _buildErrorSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '오류',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '데이터를 불러올 수\n없습니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 숫자 포매팅 헬퍼
  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
  
  // 식사 칼로리 계산
  double _calculateMealCalories(FoodEntryWithFood meal) {
    return meal.entry.portionGrams * meal.food.kcalPer100g / 100;
  }
  
  // 시간 포매팅
  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
  
  // 식사 타입 이름 변환
  String _getMealTypeName(String mealType) {
    switch (mealType) {
      case 'breakfast': return '아침';
      case 'lunch': return '점심';
      case 'dinner': return '저녁';
      case 'snack': return '간식';
      default: return mealType;
    }
  }
  
  // 운동 타입 아이콘
  IconData _getWorkoutIcon(String workoutType) {
    switch (workoutType) {
      case 'running': return Icons.directions_run;
      case 'cycling': return Icons.directions_bike;
      case 'swimming': return Icons.pool;
      case 'strength_training': return Icons.fitness_center;
      case 'walking': return Icons.directions_walk;
      case 'yoga': return Icons.self_improvement;
      default: return Icons.sports;
    }
  }
  
  // 운동 타입 색상
  Color _getWorkoutColor(String workoutType) {
    switch (workoutType) {
      case 'running': return Colors.red;
      case 'cycling': return Colors.blue;
      case 'swimming': return Colors.cyan;
      case 'strength_training': return Colors.orange;
      case 'walking': return Colors.green;
      case 'yoga': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

