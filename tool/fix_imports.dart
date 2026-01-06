import 'dart:io';

void main() async {
  print('🔧 修复导入路径...\n');
  
  final replacements = <String, String>{
    // ========== Logger Helper 路径修复 (最关键!) ==========
    // 从 bluetooth 子目录 (adapters/connectors/parsers/factories)
    "import '../../../../core/utils/logger_helper.dart'": "import '../../../../../core/utils/logger_helper.dart'",
    // 从 bluetooth 根目录
    "import '../../../core/utils/logger_helper.dart'": "import '../../../../core/utils/logger_helper.dart'",
    // 从 location/media 目录  
    "import '../../../core/utils/logger_helper.dart'": "import '../../../../core/utils/logger_helper.dart'",
    
    // ========== Model 路径修复 ==========
    // parsers 引用 device_data
    "import '../../data/models/device_data.dart'": "import '../../../../models/device_data_model.dart'",
    // location_source 引用 models
    "import '../../models/location_point_model.dart'": "import '../../../models/location_point_model.dart'",
    "import '../../models/trip_record_model.dart'": "import '../../../models/trip_record_model.dart'",
    // domain 引用 models
    "import '../models/fault_info.dart'": "import '../../data/models/fault_info_model.dart'",
    "import '../../../../models/device_data_model.dart'": "import '../../data/models/device_data_model.dart'",
    
    // ========== Connector/Factory 路径修复 ==========
    "import '../../data/sources/remote/bluetooth/connectors/bms_connector.dart'": "import '../connectors/bms_connector.dart'",
    "import '../../data/sources/remote/bluetooth/connectors/controller_connector.dart'": "import '../connectors/controller_connector.dart'",
    
    // Parsers (错误路径)
    "import '../../../data/sources/remote/bluetooth/adapters/bms_parser.dart'": "import '../parsers/bms_parser.dart'",
    "import '../../../data/sources/remote/bluetooth/adapters/controller_parser.dart'": "import '../parsers/controller_parser.dart'",
    "import '../../../data/sources/remote/bluetooth/adapters/ant_protect_adapter.dart'": "import '../../../../data/sources/remote/bluetooth/adapters/bms_adapter.dart'",
    "import '../../../data/sources/remote/bluetooth/adapters/nan_jing_yuan_qu_adapter.dart'": "import '../../../../data/sources/remote/bluetooth/adapters/controller_adapter.dart'",
    "import '../../../data/sources/remote/bluetooth/adapters/tpms_adapter.dart'": "import '../../../../data/sources/remote/bluetooth/adapters/tpms_adapter.dart'",
    
    // Core interfaces -> Bluetooth interfaces
    "import '../core/interfaces/bluetooth_manager.dart'": "import '../interfaces/bluetooth_manager.dart'",
    "import '../core/interfaces/parser.dart'": "import '../interfaces/parser.dart'",
    "import '../core/interfaces/connector.dart'": "import '../interfaces/connector.dart'",
    "import '../../core/interfaces/bluetooth_manager.dart'": "import '../../../../data/sources/remote/bluetooth/interfaces/bluetooth_manager.dart'",
    "import '../../core/interfaces/device_memory_manager.dart'": "import '../../../../data/sources/local/interfaces/device_cache_manager.dart'",
    "import '../../core/interfaces/location_engine.dart'": "import '../../../../data/sources/remote/location/interfaces/location_engine.dart'",
    "import '../../core/interfaces/media_controller.dart'": "import '../../../../data/sources/remote/media/interfaces/media_controller.dart'",
    "import '../../core/interfaces/permission_manager.dart'": "import '../../../../data/sources/local/interfaces/permission_manager.dart'",
    "import '../../../core/interfaces/bluetooth_manager.dart'": "import '../../../../data/sources/remote/bluetooth/interfaces/bluetooth_manager.dart'",
    "import '../../../core/interfaces/media_controller.dart'": "import '../../../../data/sources/remote/media/interfaces/media_controller.dart'",
    
    // Services -> Sources
    "import 'core/services/theme_provider.dart'": "import 'presentation/theme/theme_provider.dart'",
    "import '../../core/services/bluetooth_manager.dart'": "import '../../../../data/sources/remote/bluetooth/bluetooth_source.dart'",
    "import '../../core/services/database_service.dart'": "import '../../../../data/sources/local/database_source.dart'",
    "import '../../core/services/device_memory_manager.dart'": "import '../../../../data/sources/local/device_cache_source.dart'",
    "import '../../core/services/connector_registry.dart'": "import '../../../../data/sources/remote/bluetooth/connector_registry.dart'",
    "import '../../core/services/location_engine.dart'": "import '../../../../data/sources/remote/location/location_source.dart'",
    "import '../../core/services/media_controller.dart'": "import '../../../../data/sources/remote/media/media_source.dart'",
    "import '../../core/services/permission_manager.dart'": "import '../../../../data/sources/local/permission_source.dart'",
    "import '../../../core/services/bluetooth_manager.dart'": "import '../../../../data/sources/remote/bluetooth/bluetooth_source.dart'",
    "import '../../../core/services/media_controller.dart'": "import '../../../../data/sources/remote/media/media_source.dart'",
    "import '../../../core/services/permission_manager.dart'": "import '../../../../data/sources/local/permission_source.dart'",
    "import 'package:ahp_dashboard/core/services/fault_detection_service.dart'": "import 'package:ahp_dashboard/domain/usecases/detect_faults_usecase.dart'",
    "import 'package:ahp_dashboard/core/services/location_engine.dart'": "import 'package:ahp_dashboard/data/sources/remote/location/location_source.dart'",
    
    // Utils
    "import '../utils/logger_helper.dart'": "import '../../../core/utils/logger_helper.dart'",
    "import './database_service.dart'": "import 'database_source.dart'",
  };

  int fixed = 0;
  final libDir = Directory('lib');
  final testDir = Directory('test');
  
  for (final dir in [libDir, testDir]) {
    if (!await dir.exists()) continue;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('.g.dart')) {
        String content = await entity.readAsString();
        bool modified = false;
        
        for (final entry in replacements.entries) {
          if (content.contains(entry.key)) {
            content = content.replaceAll(entry.key, entry.value);
            modified = true;
          }
        }
        
        if (modified) {
          await entity.writeAsString(content);
          fixed++;
          print('✅ ${entity.path.replaceAll(r'\\', '/')}');
        }
      }
    }
  }
  
  print('\n✨ 修复完成: $fixed 个文件');
  print('\n🔄 现在运行: flutter analyze');
}
