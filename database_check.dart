import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;

// 이 스크립트는 데이터베이스 내용을 확인하기 위한 간단한 도구입니다.
// 사용법: dart run database_check.dart

Database openConnection() {
  // Windows의 Documents 폴더 경로를 직접 사용
  final homeDir = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
  final dbPath = p.join(homeDir, 'Documents', 'app_database.db');
  final file = File(dbPath);
  
  if (!file.existsSync()) {
    print('데이터베이스 파일을 찾을 수 없습니다: $dbPath');
    print('앱을 먼저 실행하여 데이터베이스를 생성하세요.');
    exit(1);
  }
  
  return sqlite3.open(dbPath);
}

void main() {
  final database = openConnection();
  
  print('=== 헬스케어 앱 데이터베이스 내용 확인 ===');
  print('');
  
  try {
    // 각 테이블의 데이터 개수 확인
    print('📊 테이블별 데이터 개수:');
    
    final tablesQuery = database.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    
    for (final table in tablesQuery) {
      final tableName = table['name'];
      final countResult = database.select('SELECT COUNT(*) as count FROM $tableName');
      final count = countResult.first['count'];
      print('  • $tableName: $count개');
    }
    
    print('');
    print('👤 사용자 정보:');
    try {
      final userResult = database.select('SELECT * FROM user_preferences LIMIT 1');
      
      if (userResult.isNotEmpty) {
        final user = userResult.first;
        print('  • 사용자 ID: ${user['user_id']}');
        print('  • 목표: ${user['goal']}');
        print('  • 일일 칼로리 목표: ${user['daily_calorie_goal']} kcal');
        print('  • 키: ${user['height']} cm');
        print('  • 몸무게: ${user['weight']} kg');
      } else {
        print('  사용자 데이터가 없습니다.');
      }
    } catch (e) {
      print('  사용자 데이터 조회 오류: $e');
    }
    
    print('');
    print('🍽️ 최근 식사 기록 (최대 5개):');
    try {
      final foodResult = database.select('''
        SELECT fe.meal_type, f.name_ko, fe.portion_grams, 
               DATE(fe.timestamp) as date,
               f.kcal_per100g * (fe.portion_grams / 100) as calories
        FROM food_entries fe
        JOIN foods f ON fe.food_id = f.id
        ORDER BY fe.timestamp DESC
        LIMIT 5
      ''');
      
      if (foodResult.isNotEmpty) {
        for (final meal in foodResult) {
          final mealType = meal['meal_type'] ?? '미정';
          final foodName = meal['name_ko'] ?? '음식';
          final portion = meal['portion_grams'] ?? 0;
          final date = meal['date'] ?? '';
          final calories = meal['calories']?.toStringAsFixed(0) ?? '0';
          
          print('  • $date $mealType: $foodName ${portion}g (${calories} kcal)');
        }
      } else {
        print('  식사 기록이 없습니다.');
      }
    } catch (e) {
      print('  식사 데이터 조회 오류: $e');
    }
    
    print('');
    print('🏃 최근 활동 기록 (최대 5개):');
    try {
      final activityResult = database.select('''
        SELECT date, steps, calories_burned, active_minutes
        FROM daily_activities
        ORDER BY date DESC
        LIMIT 5
      ''');
      
      if (activityResult.isNotEmpty) {
        for (final activity in activityResult) {
          final date = activity['date'] ?? '';
          final steps = activity['steps'] ?? 0;
          final calories = activity['calories_burned'] ?? 0;
          final minutes = activity['active_minutes'] ?? 0;
          
          print('  • $date: ${steps}걸음, ${calories}kcal 소모, ${minutes}분 활동');
        }
      } else {
        print('  활동 기록이 없습니다.');
      }
    } catch (e) {
      print('  활동 데이터 조회 오류: $e');
    }
    
    print('');
    print('🥗 음식 데이터베이스 샘플 (최대 10개):');
    try {
      final foodDbResult = database.select('''
        SELECT name_ko, kcal_per100g, protein_per100g, carb_per100g, fat_per100g
        FROM foods
        LIMIT 10
      ''');
      
      if (foodDbResult.isNotEmpty) {
        for (final food in foodDbResult) {
          final name = food['name_ko'] ?? '음식';
          final kcal = food['kcal_per100g']?.toStringAsFixed(0) ?? '0';
          final protein = food['protein_per100g']?.toStringAsFixed(1) ?? '0';
          final carb = food['carb_per100g']?.toStringAsFixed(1) ?? '0';
          final fat = food['fat_per100g']?.toStringAsFixed(1) ?? '0';
          
          print('  • $name: ${kcal}kcal (단백질:${protein}g, 탄수화물:${carb}g, 지방:${fat}g)');
        }
      } else {
        print('  음식 데이터가 없습니다.');
      }
    } catch (e) {
      print('  음식 DB 조회 오류: $e');
    }
    
  } catch (e) {
    print('데이터베이스 연결 오류: $e');
    print('');
    print('💡 해결방법:');
    print('1. 앱을 최소 한 번은 실행해서 데이터베이스가 생성되었는지 확인하세요.');
    print('2. 앱에서 데이터 초기화가 완료되었는지 확인하세요.');
    print('3. 데이터베이스 파일 경로가 올바른지 확인하세요.');
  }
  
  print('');
  print('=== 데이터베이스 확인 완료 ===');
  
  // 연결 닫기
  database.dispose();
  exit(0);
}