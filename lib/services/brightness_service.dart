import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrightnessService {
  static const platform = MethodChannel('com.example.card_app/screen_brightness');
  bool _isMaxBrightness = false;
  double _previousBrightness = 0.0;

  bool get isMaxBrightness => _isMaxBrightness;

  Future<void> toggleMaxBrightness() async {
    try {
      if (!_isMaxBrightness) {
        // Store current brightness
        _previousBrightness = await platform.invokeMethod('getBrightness') ?? 0.5;
        // Set max brightness
        await platform.invokeMethod('setBrightness', {'brightness': 1.0});
        _isMaxBrightness = true;
      } else {
        // Restore previous brightness
        await platform.invokeMethod(
          'setBrightness',
          {'brightness': _previousBrightness},
        );
        _isMaxBrightness = false;
      }
    } catch (e) {
      debugPrint('Failed to toggle brightness: $e');
    }
  }

  Future<void> dispose() async {
    if (_isMaxBrightness) {
      try {
        // Restore previous brightness when disposing
        await platform.invokeMethod(
          'setBrightness',
          {'brightness': _previousBrightness},
        );
      } catch (e) {
        debugPrint('Failed to restore brightness: $e');
      }
    }
  }
}
