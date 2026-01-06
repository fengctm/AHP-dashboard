import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../../../core/utils/logger_helper.dart';
import '../../../../data/sources/local/permission_source.dart';
import '../../../../data/sources/remote/media/interfaces/media_controller.dart';
import '../../../../data/sources/remote/media/media_source.dart';

class MediaCard extends ConsumerStatefulWidget {
  const MediaCard({
    super.key,
    required this.isPermissionGranted,
    required this.onPermissionChanged,
  });

  final bool isPermissionGranted;
  final Function(bool) onPermissionChanged;

  @override
  ConsumerState<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends ConsumerState<MediaCard> with WidgetsBindingObserver {
  late MediaController _mediaController;
  late PermissionManager _permissionManager;
  MediaState? _currentMediaState;

  final Logger _logger = LoggerHelper.getWidgetLogger('media_card');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mediaController = MediaController();
    _permissionManager = PermissionManager();
    _initializeMediaController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logger.info('释放媒体控制器资源');
    _mediaController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _logger.info('App回到前台，重新检查权限');
      _checkPermission();
    }
  }

  Future<void> _initializeMediaController() async {
    _logger.info('初始化媒体控制器');
    await _mediaController.initialize();
    
    // 检查通知监听权限
    await _checkPermission();
    
    _mediaController.mediaStateStream.listen((mediaState) {
      _logger.fine(
          '媒体状态更新: 标题=${mediaState.title}, 播放状态=${mediaState.playbackState}');
      if (mounted) {
        setState(() {
          _currentMediaState = mediaState;
        });
      }
    });
    _logger.fine('媒体控制器初始化完成');
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _mediaController.checkNotificationPermission();
    _logger.info('通知监听权限状态: $hasPermission');
    
    if (mounted && hasPermission != widget.isPermissionGranted) {
      widget.onPermissionChanged(hasPermission);
    }
  }

  @override
  void didUpdateWidget(MediaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 widget 更新时重新检查权限
    if (oldWidget.isPermissionGranted != widget.isPermissionGranted) {
      _logger.info('权限状态变化: ${widget.isPermissionGranted}');
    }
  }

  Future<void> _requestNotificationPermission() async {
    _logger.info('请求通知权限');
    final result = await _permissionManager.ensureNotification();
    _logger.fine('通知权限请求结果: ${result.success}');
    widget.onPermissionChanged(result.success);
    if (!result.success) {
      _logger.warning('通知权限未授予，打开设置页面');
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: widget.isPermissionGranted
          ? _buildMediaCardWithPermission()
          : _buildMediaCardWithoutPermission(),
    );
  }

  Widget _buildMediaCardWithoutPermission() {
    return Column(
      children: [
        Icon(
          Icons.music_off,
          size: 64,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(height: 16),
        Text(
          '需要通知监听权限',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AHP仪表盘需要通知监听权限以获取媒体播放信息',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '点击下方按钮将打开“通知使用权限”设置',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _requestNotificationPermission,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          icon: const Icon(Icons.settings),
          label: const Text('打开设置'),
        ),
      ],
    );
  }

  Widget _buildMediaCardWithPermission() {
    final mediaState = _currentMediaState;
    final title = mediaState?.title ?? '暂无媒体播放';
    final artist = mediaState?.artist ?? '';
    final album = mediaState?.album ?? '';
    final lyrics = mediaState?.lyrics ?? '';
    final isPlaying = mediaState?.playbackState == MediaPlaybackState.playing;
    final artworkBytes = mediaState?.artworkBytes;
    
    // 如果没有媒体信息，显示提示
    if (mediaState == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无媒体播放',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请打开音乐播放器并播放歌曲',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '如果已经播放但仍无信息，请尝试：',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 关闭并重新开启通知监听权限\n• 关闭并重启 APP',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).hintColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _requestNotificationPermission,
            icon: const Icon(Icons.settings),
            label: const Text('打开通知设置'),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // Background with artwork if available
        if (artworkBytes != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.memory(
                artworkBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),

        // Content
        Column(
          children: [
            // 封面图（如果有）
            if (artworkBytes != null)
              RepaintBoundary(
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      artworkBytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true, // 避免图片闪烁
                    ),
                  ),
                ),
              ),

            // Top section: Title and Artist (滚动文本)
            Column(
              children: [
                _buildScrollingText(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                ),
                if (artist.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _buildScrollingText(
                      artist,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                if (album.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _buildScrollingText(
                      album,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor.withOpacity(0.8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 播放进度
            if (mediaState?.duration != null && mediaState!.duration! > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (mediaState.position ?? 0) / mediaState.duration!,
                      backgroundColor: Theme.of(context).hintColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(mediaState.position ?? 0),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Text(
                          _formatDuration(mediaState.duration ?? 0),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const Spacer(),

            // Bottom section: Media Controls
            RepaintBoundary(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 32,
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () async {
                      _logger.info('点击上一曲');
                      // 不立即更新 UI，等待原生事件回调
                      await _mediaController.previous();
                    },
                  ),
                  const SizedBox(width: 24),
                  // 使用 AnimatedSwitcher 平滑切换播放/暂停图标
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: IconButton(
                        key: ValueKey<bool>(isPlaying),
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        iconSize: 48,
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          _logger.info('点击播放/暂停');
                          // 不立即更新 UI，等待原生事件回调
                          await _mediaController.playPause();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () async {
                      _logger.info('点击下一曲');
                      // 不立即更新 UI，等待原生事件回调
                      await _mediaController.next();
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  /// 构建滚动文本 widget
  Widget _buildScrollingText(String text, {required TextStyle style}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final isOverflow = textPainter.width > constraints.maxWidth;

        if (!isOverflow) {
          // 文本不超出，直接显示
          return Text(
            text,
            style: style,
            textAlign: TextAlign.center,
            maxLines: 1,
          );
        }

        // 文本超出，使用滚动动画
        return SizedBox(
          height: style.fontSize! * 1.5,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10000, // 无限循环
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                key: ValueKey('$text-$index'),
                tween: Tween<double>(begin: 0, end: -textPainter.width - 50),
                duration: Duration(
                  milliseconds: (text.length * 200).clamp(3000, 10000),
                ),
                curve: Curves.linear,
                onEnd: () {
                  // 动画结束后重新开始
                },
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(value + (index * (textPainter.width + 50)), 0),
                    child: Row(
                      children: [
                        Text(
                          text,
                          style: style,
                          maxLines: 1,
                        ),
                        const SizedBox(width: 50), // 间隔
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 格式化时长
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
