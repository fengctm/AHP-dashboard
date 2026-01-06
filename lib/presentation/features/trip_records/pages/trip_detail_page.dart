import 'package:flutter/material.dart';

import '../../../../data/models/trip_record_model.dart';

class TripRecordDetailPage extends StatelessWidget {
  final TripRecord tripRecord;

  const TripRecordDetailPage({super.key, required this.tripRecord});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程详情'),
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 行程基本信息卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '行程详情',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 行程时间信息
                    _buildDetailItem(
                      context,
                      '开始时间',
                      tripRecord.startTime.toString(),
                      Icons.access_time,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      context,
                      '结束时间',
                      tripRecord.endTime?.toString() ?? '未结束',
                      Icons.stop_circle,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      context,
                      '驾驶时长',
                      _formatDuration(tripRecord.drivingTime),
                      Icons.timer,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 行程统计信息卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '行程统计',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 行程距离信息
                    _buildDetailItem(
                      context,
                      '总里程',
                      '${tripRecord.totalDistance.toStringAsFixed(2)} km',
                      Icons.route,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      context,
                      '最高时速',
                      '${tripRecord.maxSpeed.toStringAsFixed(0)} km/h',
                      Icons.speed,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      context,
                      '平均时速',
                      '${tripRecord.averageSpeed.toStringAsFixed(0)} km/h',
                      Icons.av_timer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value,
      IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme
              .of(context)
              .primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: Theme
                      .of(context)
                      .hintColor,
                ),
              ),
              Text(
                value,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
