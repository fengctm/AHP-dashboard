import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../../../core/utils/logger_helper.dart';
import '../../../../data/models/trip_record_model.dart';
import '../../../../data/sources/local/database_source.dart';
import 'trip_detail_page.dart';


class TripRecordsPage extends ConsumerStatefulWidget {
  const TripRecordsPage({super.key});

  @override
  ConsumerState<TripRecordsPage> createState() => _TripRecordsPageState();
}

class _TripRecordsPageState extends ConsumerState<TripRecordsPage> {
  List<TripRecord> _tripRecords = [];
  bool _isLoading = true;

  final Logger _logger = LoggerHelper.getModuleLogger('trip_records');

  @override
  void initState() {
    super.initState();
    _loadTripRecords();
  }

  Future<void> _loadTripRecords() async {
    _logger.info('开始加载行程记录');
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await DatabaseService().getAllTripRecords();
      _logger.fine('成功加载 ${records.length} 条行程记录');
      setState(() {
        _tripRecords = records;
      });
    } catch (e) {
      _logger.severe('加载行程记录失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _logger.fine('行程记录加载完成');
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // 格式化日期时间，仅显示日期和时间的精简格式
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(
        2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour
        .toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(
        2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行程记录'),
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tripRecords.isEmpty
          ? const Center(child: Text('暂无行程记录'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tripRecords.length,
        itemBuilder: (context, index) {
          final trip = _tripRecords[index];
          return GestureDetector(
            onTap: () {
              // 点击跳转到行程详情页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TripRecordDetailPage(tripRecord: trip),
                ),
              );
            },
            child: Card(
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
                      '行程 ${index + 1}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '开始时间: ${_formatDateTime(trip.startTime)}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '结束时间: ${trip.endTime != null ? _formatDateTime(
                              trip.endTime!) : '未结束'}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTripStat(
                          '总里程',
                          '${trip.totalDistance.toStringAsFixed(2)} km',
                          Icons.route,
                        ),
                        _buildTripStat(
                          '最高时速',
                          '${trip.maxSpeed.toStringAsFixed(0)} km/h',
                          Icons.speed,
                        ),
                        _buildTripStat(
                          '平均时速',
                          '${trip.averageSpeed.toStringAsFixed(0)} km/h',
                          Icons.speed,
                        ),
                        _buildTripStat(
                          '驾驶时间',
                          _formatDuration(trip.drivingTime),
                          Icons.timer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme
            .of(context)
            .primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme
              .of(context)
              .textTheme
              .bodySmall,
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
    );
  }
}
