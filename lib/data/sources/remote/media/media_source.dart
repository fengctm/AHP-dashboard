import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'interfaces/media_controller.dart';
import '../../../../../core/utils/logger_helper.dart';

class MediaController implements IMediaController {
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.ahp_dashboard/media_control');
  static const EventChannel _eventChannel =
      EventChannel('com.example.ahp_dashboard/media_events');

  final StreamController<MediaState> _mediaStateController =
      StreamController<MediaState>.broadcast();

  StreamSubscription? _eventSubscription;
  MediaState? _currentState;

  bool _isInitialized = false;

  final Logger _logger = LoggerHelper.getCoreLogger('media_controller');

  @override
  Stream<MediaState> get mediaStateStream => _mediaStateController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.fine('媒体控制器已初始化，忽略重复请求');
      return;
    }

    _logger.info('开始初始化媒体控制器');

    try {
      // Listen to media events from native code
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          _logger.fine('收到媒体事件: $event');
          _handleMediaEvent(event);
        },
        onError: (error) {
          _logger.severe('媒体事件流错误: $error');
        },
      );

      _isInitialized = true;
      _logger.info('媒体控制器初始化完成');
    } catch (e) {
      _logger.severe('初始化媒体控制器失败: $e');
      rethrow;
    }
  }

  void _handleMediaEvent(dynamic event) {
    try {
      if (event is! Map) {
        _logger.warning('无效的媒体事件格式: $event');
        return;
      }

      // 检查是否是权限更新事件
      if (event.containsKey('permissionGranted')) {
        final granted = event['permissionGranted'] as bool? ?? false;
        final serviceRunning = event['serviceRunning'] as bool? ?? false;
        final needRestart = event['needRestart'] as bool? ?? false;
        
        _logger.info('收到权限状态更新: 权限=$granted, 服务运行=$serviceRunning');
        
        if (needRestart) {
          _logger.warning('⚠️ NotificationListener 服务未运行！');
          _logger.warning('请在设置中：');
          _logger.warning('1. 关闭 AHP Dashboard 的通知监听权限');
          _logger.warning('2. 重新开启 AHP Dashboard 的通知监听权限');
          _logger.warning('3. 或者重启手机');
        }
        
        // 权限状态更新不需要更新MediaState，只需要记录日志
        return;
      }

      final title = event['title'] as String? ?? '';
      final artist = event['artist'] as String? ?? '';
      final album = event['album'] as String? ?? '';
      final duration = (event['duration'] as num?)?.toInt();
      final position = (event['position'] as num?)?.toInt();
      final isPlaying = event['isPlaying'] as bool? ?? false;
      final artworkBase64 = event['artworkBase64'] as String?;

      // Convert base64 artwork to memory image if available
      Uint8List? artworkBytes;
      if (artworkBase64 != null && artworkBase64.isNotEmpty) {
        try {
          artworkBytes = base64Decode(artworkBase64);
        } catch (e) {
          _logger.warning('解码封面图失败: $e');
        }
      }

      final mediaState = MediaState(
        title: title.isNotEmpty ? title : null,
        artist: artist.isNotEmpty ? artist : null,
        album: album.isNotEmpty ? album : null,
        playbackState: isPlaying ? MediaPlaybackState.playing : MediaPlaybackState.paused,
        repeatMode: MediaRepeatMode.none,
        shuffleMode: MediaShuffleMode.off,
        position: position,
        duration: duration,
        artworkBytes: artworkBytes,
        artworkUri: null,
        lyrics: null,
      );

      _currentState = mediaState;
      _mediaStateController.add(mediaState);

      _logger.fine('媒体状态更新: $title by $artist');
    } catch (e) {
      _logger.severe('处理媒体事件失败: $e');
    }
  }

  @override
  Future<void> play() async {
    _logger.info('发送播放指令');
    try {
      final success = await _methodChannel.invokeMethod<bool>('mediaControl', {'action': 'play'});
      if (success == true) {
        _logger.info('播放指令发送成功');
      } else {
        _logger.warning('播放指令发送失败');
      }
    } catch (e) {
      _logger.severe('发送播放指令时出错: $e');
    }
  }

  @override
  Future<void> pause() async {
    _logger.info('发送暂停指令');
    try {
      final success = await _methodChannel.invokeMethod<bool>('mediaControl', {'action': 'pause'});
      if (success == true) {
        _logger.info('暂停指令发送成功');
      } else {
        _logger.warning('暂停指令发送失败');
      }
    } catch (e) {
      _logger.severe('发送暂停指令时出错: $e');
    }
  }

  @override
  Future<void> playPause() async {
    _logger.info('发送播放/暂停切换指令');
    try {
      final success = await _methodChannel.invokeMethod<bool>('mediaControl', {'action': 'playPause'});
      if (success == true) {
        _logger.info('播放/暂停切换指令发送成功');
      } else {
        _logger.warning('播放/暂停切换指令发送失败');
      }
    } catch (e) {
      _logger.severe('发送播放/暂停切换指令时出错: $e');
    }
  }

  @override
  Future<void> next() async {
    _logger.info('发送下一曲指令');
    try {
      final success = await _methodChannel.invokeMethod<bool>('mediaControl', {'action': 'next'});
      if (success == true) {
        _logger.info('下一曲指令发送成功');
      } else {
        _logger.warning('下一曲指令发送失败');
      }
    } catch (e) {
      _logger.severe('发送下一曲指令时出错: $e');
    }
  }

  @override
  Future<void> previous() async {
    _logger.info('发送上一曲指令');
    try {
      final success = await _methodChannel.invokeMethod<bool>('mediaControl', {'action': 'previous'});
      if (success == true) {
        _logger.info('上一曲指令发送成功');
      } else {
        _logger.warning('上一曲指令发送失败');
      }
    } catch (e) {
      _logger.severe('发送上一曲指令时出错: $e');
    }
  }

  @override
  Future<void> stop() async {
    _logger.info('发送停止指令');
    try {
      final success = await _methodChannel.invokeMethod<bool>('mediaControl', {'action': 'stop'});
      if (success == true) {
        _logger.info('停止指令发送成功');
      } else {
        _logger.warning('停止指令发送失败');
      }
    } catch (e) {
      _logger.severe('发送停止指令时出错: $e');
    }
  }

  @override
  Future<void> seekTo(int position) async {
    _logger.fine('跳转功能暂不支持');
    // Media control not supported - read-only mode
  }

  @override
  Future<void> setVolume(double volume) async {
    _logger.fine('音量控制功能暂不支持');
    // Media control not supported - read-only mode
  }

  @override
  Future<void> setRepeatMode(MediaRepeatMode mode) async {
    _logger.fine('重复模式功能暂不支持');
    // Media control not supported - read-only mode
  }

  @override
  Future<void> setShuffleMode(MediaShuffleMode mode) async {
    _logger.fine('随机播放功能暂不支持');
    // Media control not supported - read-only mode
  }

  @override
  Future<void> dispose() async {
    _logger.info('释放媒体控制器资源');
    await _eventSubscription?.cancel();
    await _mediaStateController.close();
  }

  /// 检查通知监听权限
  Future<bool> checkNotificationPermission() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } catch (e) {
      _logger.severe('检查通知权限失败: $e');
      return false;
    }
  }
}
