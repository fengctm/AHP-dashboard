import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../../../../core/utils/logger_helper.dart';
import '../../../shared/widgets/base_card.dart';


class MapPreview extends StatelessWidget {
  const MapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final Logger logger = LoggerHelper.getWidgetLogger('map_preview');
    logger.fine('构建地图预览组件');

    return SizedBox(
      height: 200,
      child: BaseCard(
        child: Center(
          child: Text(
            '地图预览',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
