import 'dart:io';
import 'dart:ui';
import 'detector.dart';
import 'detection.dart';

class MockDetector implements VisionDetector {
  bool _loaded = false;
  @override
  Future<void> load() async {
    _loaded = true;
  }

  @override
  bool get isLoaded => _loaded;

  @override
  Future<List<Detection>> detect(File imageFile) async {
    // 단순 모의 감지: 중앙 박스 하나 반환
    // 실제 앱 플로우를 테스트하기 위한 용도
    final img = await decodeImageFromList(await imageFile.readAsBytes());
    return [
      Detection(
        bbox: Rect.fromLTWH(
          img.width * 0.25,
          img.height * 0.25,
          img.width * 0.5,
          img.height * 0.5,
        ),
        label: 'apple',
        score: 0.82,
      )
    ];
  }
}

