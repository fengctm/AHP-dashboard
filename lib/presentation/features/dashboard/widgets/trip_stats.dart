import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../../../core/utils/logger_helper.dart';
import '../../../shared/widgets/base_card.dart';

class TripStats extends StatelessWidget {
  final double maxSpeed;
  final double avgSpeed;
  final double tripDistance;
  final VoidCallback onViewTrips;
  final bool isRecording; // 是否正在记录
  final VoidCallback? onEndTrip; // 结束行程回调

  const TripStats({
    super.key,
    required this.maxSpeed,
    required this.avgSpeed,
    required this.tripDistance,
    required this.onViewTrips,
    this.isRecording = false,
    this.onEndTrip,
  });

  @override
  Widget build(BuildContext context) {
    final Logger logger = LoggerHelper.getWidgetLogger('trip_stats');
    logger.fine(
        '构建行程统计组件: 最高速度=${maxSpeed.toStringAsFixed(0)} km/h, 平均速度=${avgSpeed.toStringAsFixed(0)} km/h, 里程=${tripDistance.toStringAsFixed(2)} km');

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BaseCard(
      margin: const EdgeInsets.all(12), // 减小外边距
      padding: const EdgeInsets.all(8), // 减小内边距
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title with View Trips Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '行程',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  if (isRecording) ..[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.fiber_manual_record, size: 8, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            '记录中',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  if (isRecording && onEndTrip != null)
                    TextButton.icon(
                      onPressed: () {
                        logger.info('点击结束行程按钮');
                        onEndTrip!();
                      },
                      icon: const Icon(Icons.stop, size: 14, color: Colors.red),
                      label: const Text(
                        '结束行程',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  if (isRecording && onEndTrip != null)
                    const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () {
                      logger.info('点击查看行程按钮');
                      onViewTrips();
                    },
                    icon: const Icon(Icons.history, size: 14),
                    label: const Text(
                      '查看行程',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: const Size(0, 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8), // 减小间距

          // 根据屏幕方向调整统计数据布局
          isLandscape
              ? // 横屏：垂直布局
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                        context, '最高速度', '${maxSpeed.toStringAsFixed(0)} km/h'),
                    const SizedBox(height: 16),
                    _buildStatItem(
                        context, '平均速度', '${avgSpeed.toStringAsFixed(0)} km/h'),
                    const SizedBox(height: 16),
                    _buildStatItem(
                        context, '里程', '${tripDistance.toStringAsFixed(2)} km'),
                  ],
                )
              : // 竖屏：水平布局
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        context, '最高速度', '${maxSpeed.toStringAsFixed(0)} km/h'),
                    _buildStatItem(
                        context, '平均速度', '${avgSpeed.toStringAsFixed(0)} km/h'),
                    _buildStatItem(
                        context, '里程', '${tripDistance.toStringAsFixed(2)} km'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12, // 减小字体大小
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 4), // 减小间距
        Text(
          value,
          style: TextStyle(
            fontSize: 16, // 减小字体大小
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
