import 'dart:io';
import 'dart:ui';
import 'detector.dart';
import 'detection.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class UltralyticsYoloDetector implements VisionDetector {
  final String modelPath;
  bool _loaded = false;
  UltralyticsYolo? _engine;

  UltralyticsYoloDetector({
    this.modelPath = 'yolo11n',
  });

  @override
  Future<void> load() async {
    try {
      _engine = UltralyticsYolo();
      await _engine!.loadModel(
        taskType: YOLOTask.detect,
        modelPath: modelPath,
        imageSize: 640,
        confThreshold: 0.4,
        iouThreshold: 0.5,
      );
      _loaded = true;
    } catch (e) {
      print('YOLO 모델 로딩 실패: $e');
      _loaded = false;
    }
  }

  @override
  bool get isLoaded => _loaded;

  @override
  Future<List<Detection>> detect(File imageFile) async {
    if (!_loaded || _engine == null) {
      return const [];
    }

    try {
      final results = await _engine!.detectObjects(imagePath: imageFile.path);
      
      return results.map((result) {
        // YOLO 결과를 Detection 객체로 변환
        return Detection(
          bbox: Rect.fromLTWH(
            result.box.x1,
            result.box.y1,
            result.box.x2 - result.box.x1,
            result.box.y2 - result.box.y1,
          ),
          label: result.className,
          score: result.confidence,
        );
      }).toList();
    } catch (e) {
      print('YOLO 추론 실패: $e');
      return const [];
    }
  }

  @override
  void dispose() {
    _engine?.dispose();
    _engine = null;
    _loaded = false;
  }
}

