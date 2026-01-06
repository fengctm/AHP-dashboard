class DeviceStatusHelper {
  // BMS电池状态判断
  static Map<String, dynamic> getBMSStatus({
    required double voltage,
    required double current,
    required double soc,
    required double temperature,
    Map<String, dynamic>? extra,
  }) {
    String batteryStatus = '未知';
    String simpleStatus = '正常';
    List<String> errors = [];

    // 根据电流判断充电/放电/静止状态
    if (current > 0.5) {
      batteryStatus = '充电';
    } else if (current < -0.5) {
      batteryStatus = '放电';
    } else {
      batteryStatus = '静止';
    }

    // 电压异常检测
    if (voltage < 40.0) {
      simpleStatus = '异常';
      errors.add('电压过低');
    } else if (voltage > 58.0) {
      simpleStatus = '异常';
      errors.add('电压过高');
    }

    // 温度异常检测
    if (temperature > 60.0) {
      simpleStatus = '异常';
      errors.add('温度过高');
    } else if (temperature < -10.0) {
      simpleStatus = '异常';
      errors.add('温度过低');
    }

    // SOC异常检测
    if (soc < 5.0) {
      simpleStatus = '异常';
      errors.add('电量过低');
    }

    // 额外异常检测（如果有）
    if (extra != null) {
      // 放电管异常
      if (extra.containsKey('dischargeTubeError') &&
          extra['dischargeTubeError'] == true) {
        simpleStatus = '异常';
        errors.add('放电管异常');
      }

      // 充电管异常
      if (extra.containsKey('chargeTubeError') &&
          extra['chargeTubeError'] == true) {
        simpleStatus = '异常';
        errors.add('充电管异常');
      }

      // 压差过限
      if (extra.containsKey('voltageDiff') && extra['voltageDiff'] > 0.5) {
        simpleStatus = '异常';
        errors.add('压差过限');
      }

      // 短路保护
      if (extra.containsKey('shortCircuit') && extra['shortCircuit'] == true) {
        simpleStatus = '异常';
        errors.add('短路保护');
      }

      // 均衡状态
      if (extra.containsKey('balancing') && extra['balancing'] == true) {
        batteryStatus = '均衡';
      }
    }

    return {
      'batteryStatus': batteryStatus,
      'simpleStatus': simpleStatus,
      'errors': errors,
    };
  }

  // 控制器系统状态判断
  static Map<String, dynamic> getControllerStatus({
    required double voltage,
    required double temperature,
    required double current,
    required double rpm,
    Map<String, dynamic>? extra,
  }) {
    String systemStatus = '正常运行';
    String simpleStatus = '正常';
    List<String> errors = [];

    // MOS温度异常检测
    if (temperature > 80.0) {
      simpleStatus = '异常';
      errors.add('MOS温度过高');
      systemStatus = '系统异常';
    }

    // 电压异常检测
    if (voltage < 40.0) {
      simpleStatus = '异常';
      errors.add('输入电压过低');
      systemStatus = '系统异常';
    } else if (voltage > 58.0) {
      simpleStatus = '异常';
      errors.add('输入电压过高');
      systemStatus = '系统异常';
    }

    // 电流异常检测
    if (current > 100.0) {
      simpleStatus = '异常';
      errors.add('输出电流过大');
      systemStatus = '系统异常';
    }

    // 额外异常检测（如果有）
    if (extra != null) {
      // 过流保护
      if (extra.containsKey('overCurrent') && extra['overCurrent'] == true) {
        simpleStatus = '异常';
        errors.add('过流保护');
        systemStatus = '系统异常';
      }

      // 过压保护
      if (extra.containsKey('overVoltage') && extra['overVoltage'] == true) {
        simpleStatus = '异常';
        errors.add('过压保护');
        systemStatus = '系统异常';
      }

      // 欠压保护
      if (extra.containsKey('underVoltage') && extra['underVoltage'] == true) {
        simpleStatus = '异常';
        errors.add('欠压保护');
        systemStatus = '系统异常';
      }

      // 温度保护
      if (extra.containsKey('temperatureProtection') &&
          extra['temperatureProtection'] == true) {
        simpleStatus = '异常';
        errors.add('温度保护');
        systemStatus = '系统异常';
      }

      // 电机故障
      if (extra.containsKey('motorError') && extra['motorError'] == true) {
        simpleStatus = '异常';
        errors.add('电机故障');
        systemStatus = '系统异常';
      }
    }

    return {
      'systemStatus': systemStatus,
      'simpleStatus': simpleStatus,
      'errors': errors,
    };
  }

  // 获取挡位显示
  static String getGearDisplay(int gear) {
    if (gear < 0) {
      return 'R${gear.abs()}';
    } else if (gear == 0) {
      return 'N';
    } else {
      return 'D$gear';
    }
  }
}
