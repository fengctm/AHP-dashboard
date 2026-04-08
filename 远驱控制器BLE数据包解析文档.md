# 远驱电机控制器 BLE 协议解析规范（AI 可复刻版）

> 本文档的目标读者是 **AI 代码生成器**。任何 AI 读完后应能 100% 复刻出正确的解析器，无需额外上下文。

---

## 0. 全局约定

### 0.1 数据包格式

- 每个 BLE 数据包固定 **16 字节**
- `data[0]` 恒为 `0xAA`（十进制 170），不是则丢弃
- `data[14]` 和 `data[15]` 是校验字节（仅 Legacy 协议使用，FlashRead 不校验）

### 0.2 有符号整数处理

```python
def to_signed_int16(v):
    """将 0~65535 的无符号值转为 -32768~32767 的有符号值"""
    return v - 65536 if v > 32767 else v
```

### 0.3 字节序警告（最容易出错的地方）

**本协议混合使用大端和小端，且两套协议的字节序不同！**

| 场景 | 字节序 | 示例 |
|------|--------|------|
| FlashRead addr=232 电压 | **小端**（低字节在低偏移） | `data[3]*256 + data[2]` |
| Legacy CMD=1 电压 | **大端**（高字节在低偏移） | `data[2]*256 + data[3]` |
| FlashRead addr=226 转速 | **小端** | `data[9]*256 + data[8]` |
| Legacy CMD=0 转速 | **大端** | `data[6]*256 + data[7]` |

> ⚠️ **规则**：FlashRead 协议中，多字节整数的低字节在低偏移（小端）；Legacy 协议中，高字节在低偏移（大端）。**不要假设统一字节序！**

---

## 1. 协议判定（解析的第一步）

```python
if (data[1] & 0xC0) == 0x80:
    → FlashRead 协议，进入第 2 节
else:
    → Legacy 协议，进入第 3 节
```

---

## 2. FlashRead 协议

### 2.1 解码 Index 和 Addr

```python
index = data[1] & 0x7F          # 取低 7 位，范围 0~54
addr = FlashReadAddr[index]     # 查表
```

`FlashReadAddr` 映射表（55 项）：

```python
FlashReadAddr = [
    226, 232, 238,   0,   6,  12,  18, 226, 232, 238,  # index  0- 9
     24,  30,  36,  42, 226, 232, 238,  48,  93,  99,  # index 10-19
    105, 226, 232, 238, 124, 130, 136, 142, 226, 232,  # index 20-29
    238, 148, 154, 160, 166, 226, 232, 238, 172, 178,  # index 30-39
    184, 190, 226, 232, 238, 196, 202, 208, 226, 232,  # index 40-49
    238, 214, 220, 244, 250                           # index 50-54
]
```

### 2.2 Addr 分发

**只有以下 addr 有解析逻辑，其余 addr 直接跳过（C# 源码中无对应 case）：**

| addr | 内容 | 见章节 |
|------|------|--------|
| 226 | 转速 + 挡位 + 调制比 + 故障 | 2.3 |
| 232 | 电压 + 电流 + 油门深度 | 2.4 |
| 238 | A/C 相电流 + 圈数 | 2.5 |
| 214 | 全局状态寄存器 + MOS 温度 | 2.6 |
| 250 | 电机运行/停止状态 | 2.7 |
| 244 | 电机温度 + SOC | 2.8 |
| 130 | 油门电压 + 固件版本 | 2.9 |
| 208 | 平均能耗 + 车速参数 | 2.10 |
| 18 | 极对数 | 2.11 |
| 105 | 里程低 16 位 | 2.12 |
| 124 | 工作时长 + 里程高 16 位 | 2.13 |
| 154 | 报警记录 | 2.14 |

**以下 addr 在 C# 源码中无解析逻辑，直接跳过：**
`0, 6, 12, 24, 30, 36, 42, 48, 93, 99, 136, 142, 148, 160, 166, 172, 178, 184, 190, 196, 202, 220`

### 2.3 addr=226：转速 / 挡位 / 调制比 / 故障

**逐字节定义：**

```
data[2]  bit0-1   → 挡位 (0~3)
data[2]  bit2-3   → 巡航模式 (0~3)
data[2]  bit4     → 倒车标志
data[2]  bit5     → 滚动电压标志
data[2]  bit7     → 手机配套确认
data[3]  bit3-4   → 密码匹配状态 (0~3)
data[3]  bit7     → 功能使能
data[4]           → 故障低字节（位解析，见第 5 节故障表）
data[5]  bit0-6   → 故障高字节（位解析）
data[5]  bit7     → 停机标志
data[6]           → 调制比原始值
data[8:10]        → 转速（小端 int16）
```

**解析公式：**

```python
gear          = data[2] & 0x03
xs_control    = (data[2] >> 2) & 0x03
reversing     = (data[2] >> 4) & 1
rolling_v     = (data[2] >> 5) & 1
comp_phone    = (data[2] & 0x80) != 0
pass_ok       = (data[3] & 0x18) >> 3
function_en   = (data[3] & 0x80) != 0
modulation    = data[6] / 128.0          # 浮点，范围 0.0~2.0
rpm           = to_signed_int16(data[9] * 256 + data[8])
stop          = (data[5] & 0x80) != 0
faults        = parse_faults(data[4], data[5], gs1=0, gs2=0, mss=0)
```

**方向判断：**

```python
if rolling_v == 0:
    direction = 0          # 静止
elif reversing == 0:
    direction = 1 if (gear < 2 or gear == 3) else -1
else:
    direction = 1 if (gear >= 2 or gear == 3) else -1
# direction: 1=前进, -1=后退, 0=静止
```

### 2.4 addr=232：电压 / 电流 / 油门深度

**解析公式（注意小端序）：**

```python
voltage       = to_signed_int16(data[3] * 256 + data[2]) / 10.0   # V
current       = to_signed_int16(data[7] * 256 + data[6]) / 4.0    # A
throttle_depth = data[13] * 256 + data[12]                         # ADC 原始值
power         = voltage * current                                   # W（计算值）
```

### 2.5 addr=238：A/C 相电流（RMS）+ 圈数

```python
turns         = data[5] * 256 + data[4]                             # UInt16
raw_a         = data[6] * 65536 + data[7] * 256 + data[8]          # 24 位
phase_a       = 1.953125 * math.sqrt(raw_a)                        # A
raw_c         = data[9] * 65536 + data[10] * 256 + data[11]        # 24 位
phase_c       = 1.953125 * math.sqrt(raw_c)                        # A
```

> 系数 1.953125 = 2000/1024，这是 RMS 能量模型，不是线性 ADC。

### 2.6 addr=214：全局状态寄存器 + MOS 温度

```python
mos_temp      = to_signed_int16(data[13] * 256 + data[12])          # ℃
gs1           = data[5] * 256 + data[4]
gs2           = data[7] * 256 + data[6]
gs3           = data[9] * 256 + data[8]
gs4           = data[11] * 256 + data[10]
autolearn     = (gs1 & 0x20) != 0        # 自学习中
weak_field    = (gs2 & 0x08) != 0        # 弱磁模式（否则 MTPA）
motor_on      = (gs1 & 0x2000) != 0      # 马达开启
```

### 2.7 addr=250：电机运行/停止状态

```python
motor_stop    = data[7] * 256 + data[6]
motor_run     = data[11] * 256
```

### 2.8 addr=244：电机温度 + SOC

```python
motor_temp    = to_signed_int16(data[3] * 256 + data[2])            # ℃
soc           = data[5]                                              # 0~100%
```

### 2.9 addr=130：油门电压 + 固件版本

```python
throttle_v    = (data[3] * 256 + data[2]) * 0.01                    # V
fw_version    = chr(data[11])                                       # 字符，>'6' 表示完整数据
```

### 2.10 addr=208：平均能耗 + 车速参数

```python
avg_power_wh  = data[5] * 4              # Wh/Km
avg_speed_kmh = data[8]                  # Km/h
wheel_ratio   = data[6]
wheel_radius  = data[7]
wheel_width   = data[9]
rate_ratio    = data[11] * 256 + data[10]
```

### 2.11 addr=18：极对数

```python
pole_pairs    = data[6]
```

### 2.12 addr=105：里程低 16 位

```python
distance_low  = data[11] * 256 + data[10]   # 单位 0.1 Km
```

### 2.13 addr=124：工作时长 + 里程高 16 位

```python
total_time_s  = (data[7]*256+data[6]) * 65536 + data[5]*256 + data[4]  # 秒
work_hours    = total_time_s / 3600.0
distance_high = data[13] * 256 + data[12]
distance_km   = ((distance_high << 16) + distance_low) / 10.0          # Km
```

### 2.14 addr=154：报警记录

```python
alarm_rec     = data[7] * 256 + data[6]   # 解析为 3 位十六进制数
```

---

## 3. Legacy 协议

### 3.0 校验（可选）

```python
checksum  = sum(data[0:14])
expected  = data[14] * 256 + data[15]
is_valid  = (checksum == expected)
```

### 3.1 CMD 分发

**只有以下 CMD 有解析逻辑，其余 CMD 直接跳过：**

| CMD | 内容 | 见章节 |
|-----|------|--------|
| 0 | 转速 + 挡位 + 故障 | 3.2 |
| 1 | 电压 + 电流 + 调制比 + 油门深度 | 3.3 |
| 2 | A/C 相电流 | 3.4 |
| 3 | 相电流比例 | 3.5 |
| 4 | MOS 温度 + 线电流比 | 3.6 |
| 8 | 极对数 | 3.7 |
| 10 | SOC | 3.8 |
| 13 | 油门电压 + 电机温度 + 版本 | 3.9 |
| 15 | 全部状态寄存器 | 3.10 |
| 18 | BMS 串联数（需先收到 CMD=32 确认 BMS 模式） | 3.11 |
| 32~35 | BMS 电芯电压（每帧 6 节） | 3.12 |
| 36~39 | BMS 电芯电流（每帧 6 节） | 3.12 |

**以下 CMD 在 C# 源码中无解析逻辑，直接跳过：**
`5, 6, 7, 9, 11, 12, 14, 16, 17, 19, 20, 21, 22, 23`

### 3.2 CMD=0：转速 + 挡位 + 故障

**逐字节定义：**

```
data[4]  bit0-1   → 挡位 (0~3)
data[4]  bit2-3   → 巡航模式（注意：有异或 2！）
data[4]  bit4-7   → 方向位
data[5]  bit2-3   → 密码匹配状态
data[5]  bit4     → 手机配套确认
data[5]  bit0-1   → EABS（值为 2 时启用）
data[6:8]         → 转速（大端 int16）
data[8]           → 故障低字节（位解析，见第 5 节）
data[9]  bit0-6   → 故障高字节（位解析）
data[9]  bit7     → 停机标志
```

**解析公式：**

```python
gear          = data[4] & 0x03
xs_control    = ((data[4] >> 2) ^ 2) & 0x03    # ⚠️ 有异或 2！
pass_ok       = (data[5] & 0x0C) >> 2
comp_phone    = (data[5] & 0x10) != 0
eabs          = (data[5] & 0x03) == 2
rpm           = to_signed_int16(data[6] * 256 + data[7])   # 大端
stop          = (data[9] & 0x80) != 0
faults        = parse_faults(data[8], data[9], gs1=0, gs2=0, mss=0)
```

**方向判断：**

```python
dir_bits = (data[4] & 0xF0) >> 4
if dir_bits == 0:
    direction = 0
elif dir_bits == 1:
    direction = 1 if (gear < 2 or gear == 3) else -1
else:
    direction = 1 if (gear >= 2 or gear == 3) else -1
```

> ⚠️ **与 FlashRead addr=226 的区别：**
> - Legacy CMD=0：挡位在 `data[4]`，故障在 `data[8]/data[9]`，转速在 `data[6:8]`（大端），巡航模式有 `^2`
> - FlashRead addr=226：挡位在 `data[2]`，故障在 `data[4]/data[5]`，转速在 `data[8:10]`（小端），巡航模式无 `^2`

### 3.3 CMD=1：电压 / 电流 / 调制比 / 油门深度

**解析公式（注意大端序）：**

```python
voltage       = to_signed_int16(data[2] * 256 + data[3]) / 10.0   # V
current       = to_signed_int16(data[4] * 256 + data[5]) / 4.0    # A
modulation    = data[6] / 128.0
weak_field    = (data[7] & 0x01) != 0     # True=弱磁, False=MTPA
throttle_depth = data[12] * 256 + data[13]                         # ADC
power         = voltage * current
```

### 3.4 CMD=2：A/C 相电流

```python
raw_a  = data[2] * 65536 + data[3] * 256 + data[4]
phase_a = 1.953125 * math.sqrt(raw_a)                              # A
raw_c  = data[9] * 65536 + data[10] * 256 + data[11]
phase_c = 1.953125 * math.sqrt(raw_c)                              # A
```

### 3.5 CMD=3：相电流比例

```python
phase_a_ratio = data[8] * 256 + data[9]
phase_c_ratio = data[10] * 256 + data[11]
```

### 3.6 CMD=4：MOS 温度 + 线电流比

```python
mos_raw  = data[4]
if mos_raw > 200:
    mos_raw -= 256               # 有符号字节
mos_temp  = mos_raw              # ℃
line_curr_ratio = data[8] * 256 + data[9]
```

### 3.7 CMD=8：极对数

```python
pole_pairs = data[10]
```

### 3.8 CMD=10：SOC

```python
soc = data[10]                   # 0~100%
```

### 3.9 CMD=13：油门电压 + 电机温度 + 版本

```python
motor_temp    = data[2]                                              # ℃（无符号字节）
throttle_v    = (data[4] * 256 + data[5]) * 3.3 * 1.5 / 4096.0    # V
fw_version    = chr(data[10]) if data[10] >= 32 else '?'
```

### 3.10 CMD=15：全部状态寄存器

```python
motor_stop    = data[4] * 256 + data[5]
function_st   = data[2]
motor_run     = data[3] * 256
gs1           = data[6] * 256 + data[7]
gs2           = data[8] * 256 + data[9]
gs3           = data[10] * 256 + data[11]
gs4           = data[12] * 256 + data[13]
autolearn     = (gs1 & 0x20) != 0
motor_on      = (gs1 & 0x2000) != 0
```

### 3.11 CMD=18：BMS 串联数

```python
# 仅在 BMS 模式下有效（需先收到 CMD=32）
series_count  = data[8]
```

### 3.12 CMD=32~39：BMS 电芯数据

```python
# CMD=32: 电芯 0~5 电压    CMD=33: 电芯 6~11 电压
# CMD=34: 电芯 12~17 电压   CMD=35: 电芯 18~23 电压
# CMD=36: 电芯 0~5 电流    CMD=37: 电芯 6~11 电流
# CMD=38: 电芯 12~17 电流   CMD=39: 电芯 18~23 电流

cell_index_base = (cmd - 32) * 6    # CMD=32→0, CMD=33→6, ...

for i in range(6):
    cell_mv = to_signed_int16(data[i*2+2] * 256 + data[i*2+3])  # mV
    # 容量估算（仅电压帧 CMD=32~35）
    if cmd <= 35:
        if cell_mv > 4110:   cap = 127
        elif cell_mv < 3600: cap = 0
        else:                 cap = (cell_mv - 3600) // 4
```

---

## 4. 故障解析函数

```python
def parse_faults(byte_low, byte_high, gs1, gs2, mss):
    """
    byte_low  : 故障低字节
    byte_high : 故障高字节（只用 bit0~6，bit7 是停机标志）
    gs1       : Global_state1（用于区分代码 11/17）
    gs2       : Global_state2（用于区分代码 05/18）
    mss       : motor_stop_state（用于代码 16）
    """
    if byte_low == 0 and (byte_high & 0x7F) == 0:
        return ["系统正常"]

    f = []
    if byte_low & 0x01: f.append("01.电机霍尔故障")
    if byte_low & 0x02: f.append("02.油门踏板故障")
    if byte_low & 0x04: f.append("03.电流保护重启")
    if byte_low & 0x08: f.append("04.相电流突变")
    if byte_low & 0x10:
        f.append("05.过压故障" if (gs2 & 0x8000) else "18.欠压故障")
    if byte_low & 0x20: f.append("06.防盗报警")
    if byte_low & 0x40: f.append("07.电机过温")
    if byte_low & 0x80: f.append("08.控制器过温")
    if byte_high & 0x01: f.append("09.相电流溢出")
    if byte_high & 0x02: f.append("10.相线零点故障")
    if byte_high & 0x04:
        f.append("17.缺相故障" if (gs1 & 0x800) else "11.相线短路故障")
    if byte_high & 0x08: f.append("12.线电流零点故障")
    if byte_high & 0x10: f.append("13.MOSFET上桥故障")
    if byte_high & 0x20: f.append("14.MOSFET下桥故障")
    if byte_high & 0x40: f.append("15.MOE电流保护")
    if mss & 0x8000: f.append("16.刹车故障")
    return f
```

---

## 5. 验证用例（AI 自检用）

以下用例覆盖了两套协议的主要 CMD/addr，任何实现必须通过全部用例。

### 用例 1：Legacy CMD=0

```
输入: AA0000040101000000000011FFF402B4
hex:  AA 00 00 04 01 01 00 00 00 00 00 11 FF F4 02 B4

判定: data[1]=0x00, (0x00 & 0xC0)=0x00 ≠ 0x80 → Legacy, CMD=0

解析:
  data[4]=0x01 → gear = 0x01 & 0x03 = 1
  data[4]=0x01 → xs_control = ((0x01 >> 2) ^ 2) & 3 = (0 ^ 2) & 3 = 2
  data[5]=0x01 → pass_ok = (0x01 & 0x0C) >> 2 = 0
  data[5]=0x01 → comp_phone = (0x01 & 0x10) != 0 = False
  data[5]=0x01 → eabs = (0x01 & 0x03) == 2 = False
  data[6:8]=0x0000 → rpm = to_signed_int16(0*256+0) = 0
  data[8]=0x00, data[9]=0x00 → faults = ["系统正常"]
  data[9] bit7 → stop = False

期望输出: gear=1, xs_control=2, rpm=0, faults=["系统正常"], stop=False
```

### 用例 2：Legacy CMD=1

```
输入: AA0103040000000000000000000000B2
hex:  AA 01 03 04 00 00 00 00 00 00 00 00 00 00 00 B2

判定: Legacy, CMD=1

解析:
  data[2:4]=0x0304 → voltage = to_signed_int16(3*256+4)/10 = 772/10 = 77.2 V
  data[4:6]=0x0000 → current = to_signed_int16(0*256+0)/4 = 0.0 A
  data[6]=0x00 → modulation = 0/128 = 0.0
  data[7]=0x00 → weak_field = False
  data[12:14]=0x0000 → throttle_depth = 0
  power = 77.2 * 0.0 = 0.0 W

期望输出: voltage=77.2, current=0.0, modulation=0.0, weak_field=False, throttle_depth=0
```

### 用例 3：Legacy CMD=4

```
输入: AA0402001E0001000203010002F701CE
hex:  AA 04 02 00 1E 00 01 00 02 03 01 00 02 F7 01 CE

判定: Legacy, CMD=4

解析:
  data[4]=0x1E=30 → 30 <= 200, 不减 256 → mos_temp = 30 ℃
  data[8:10]=0x0203 → line_curr_ratio = 2*256+3 = 515

期望输出: mos_temp=30, line_curr_ratio=515
```

### 用例 4：Legacy CMD=10

```
输入: AA0A0488636117780910460916550366
hex:  AA 0A 04 88 63 61 17 78 09 10 46 09 16 55 03 66

判定: Legacy, CMD=10

解析:
  data[10]=0x46=70 → soc = 70%

期望输出: soc=70
```

### 用例 5：Legacy CMD=13

```
输入: AA0D000002A80876000447311F4002BA
hex:  AA 0D 00 00 02 A8 08 76 00 04 47 31 1F 40 02 BA

判定: Legacy, CMD=13

解析:
  data[2]=0x00 → motor_temp = 0 ℃
  data[4:6]=0x02A8=680 → throttle_v = 680 * 3.3 * 1.5 / 4096 = 3366/4096 = 0.822 V
  data[10]=0x47='G' → fw_version = 'G'

期望输出: motor_temp=0, throttle_voltage≈0.822, fw_version='G'
```

### 用例 6：Legacy CMD=15

```
输入: AA0F00000000000233800400008501F7
hex:  AA 0F 00 00 00 00 00 02 33 80 04 00 00 85 01 F7

判定: Legacy, CMD=15

解析:
  motor_stop = 0*256+0 = 0
  function_st = 0
  motor_run = 0*256 = 0
  gs1 = 0*256+2 = 2 → autolearn=(2&0x20)!=0=False, motor_on=(2&0x2000)!=0=False
  gs2 = 0x33*256+0x80 = 13184
  gs3 = 0x04*256+0x00 = 1024
  gs4 = 0x00*256+0x85 = 133

期望输出: gs1=2, gs2=13184, gs3=1024, gs4=133, autolearn=False, motor_on=False
```

### 用例 7：Legacy CMD=2

```
输入: AA0200000000000000000000000000AC
hex:  AA 02 00 00 00 00 00 00 00 00 00 00 00 00 00 AC

判定: Legacy, CMD=2

解析:
  raw_a = 0*65536+0*256+0 = 0 → phase_a = 1.953125*sqrt(0) = 0.0 A
  raw_c = 0*65536+0*256+0 = 0 → phase_c = 0.0 A

期望输出: phase_a=0.0, phase_c=0.0
```

---

## 6. 完整可运行代码

以下代码整合了上述所有逻辑，可直接运行：

```python
import math

def to_signed_int16(v):
    return v - 65536 if v > 32767 else v

FlashReadAddr = [
    226, 232, 238,   0,   6,  12,  18, 226, 232, 238,
     24,  30,  36,  42, 226, 232, 238,  48,  93,  99,
    105, 226, 232, 238, 124, 130, 136, 142, 226, 232,
    238, 148, 154, 160, 166, 226, 232, 238, 172, 178,
    184, 190, 226, 232, 238, 196, 202, 208, 226, 232,
    238, 214, 220, 244, 250
]

# 有解析逻辑的 addr 集合（FlashRead）
KNOWN_ADDRS = {226, 232, 238, 214, 250, 244, 130, 208, 18, 105, 124, 154}

# 有解析逻辑的 CMD 集合（Legacy）
KNOWN_CMDS = {0, 1, 2, 3, 4, 8, 10, 13, 15, 18, 32, 33, 34, 35, 36, 37, 38, 39}

def parse_faults(bl, bh, gs1, gs2, mss):
    if bl == 0 and (bh & 0x7F) == 0:
        return ["系统正常"]
    f = []
    if bl & 0x01: f.append("01.电机霍尔故障")
    if bl & 0x02: f.append("02.油门踏板故障")
    if bl & 0x04: f.append("03.电流保护重启")
    if bl & 0x08: f.append("04.相电流突变")
    if bl & 0x10:
        f.append("05.过压故障" if (gs2 & 0x8000) else "18.欠压故障")
    if bl & 0x20: f.append("06.防盗报警")
    if bl & 0x40: f.append("07.电机过温")
    if bl & 0x80: f.append("08.控制器过温")
    if bh & 0x01: f.append("09.相电流溢出")
    if bh & 0x02: f.append("10.相线零点故障")
    if bh & 0x04:
        f.append("17.缺相故障" if (gs1 & 0x800) else "11.相线短路故障")
    if bh & 0x08: f.append("12.线电流零点故障")
    if bh & 0x10: f.append("13.MOSFET上桥故障")
    if bh & 0x20: f.append("14.MOSFET下桥故障")
    if bh & 0x40: f.append("15.MOE电流保护")
    if mss & 0x8000: f.append("16.刹车故障")
    return f

def parse_flashread(data, index, addr):
    r = {}
    if addr == 226:
        r['gear'] = data[2] & 0x03
        r['xs_control'] = (data[2] >> 2) & 0x03
        r['comp_phone'] = (data[2] & 0x80) != 0
        r['pass_ok'] = (data[3] & 0x18) >> 3
        r['function_en'] = (data[3] & 0x80) != 0
        r['modulation'] = round(data[6] / 128.0, 4)
        r['rpm'] = to_signed_int16(data[9] * 256 + data[8])
        r['stop'] = (data[5] & 0x80) != 0
        r['faults'] = parse_faults(data[4], data[5], 0, 0, 0)
    elif addr == 232:
        r['voltage'] = to_signed_int16(data[3]*256 + data[2]) / 10.0
        r['current'] = to_signed_int16(data[7]*256 + data[6]) / 4.0
        r['throttle_depth'] = data[13]*256 + data[12]
    elif addr == 238:
        r['turns'] = data[5]*256 + data[4]
        ra = data[6]*65536 + data[7]*256 + data[8]
        r['phase_a'] = round(1.953125 * math.sqrt(ra), 2)
        rc = data[9]*65536 + data[10]*256 + data[11]
        r['phase_c'] = round(1.953125 * math.sqrt(rc), 2)
    elif addr == 214:
        r['mos_temp'] = to_signed_int16(data[13]*256 + data[12])
        r['gs1'] = data[5]*256 + data[4]
        r['gs2'] = data[7]*256 + data[6]
        r['gs3'] = data[9]*256 + data[8]
        r['gs4'] = data[11]*256 + data[10]
        r['autolearn'] = (r['gs1'] & 0x20) != 0
        r['weak_field'] = (r['gs2'] & 0x08) != 0
        r['motor_on'] = (r['gs1'] & 0x2000) != 0
    elif addr == 250:
        r['motor_stop'] = data[7]*256 + data[6]
        r['motor_run'] = data[11]*256
    elif addr == 244:
        r['motor_temp'] = to_signed_int16(data[3]*256 + data[2])
        r['soc'] = data[5]
    elif addr == 130:
        r['throttle_v'] = (data[3]*256 + data[2]) * 0.01
        r['fw_ver'] = chr(data[11]) if data[11] >= 32 else '?'
    elif addr == 208:
        r['avg_power_wh'] = data[5] * 4
        r['avg_speed_kmh'] = data[8]
    elif addr == 18:
        r['pole_pairs'] = data[6]
    elif addr == 105:
        r['dist_low'] = data[11]*256 + data[10]
    elif addr == 124:
        r['total_time_s'] = (data[7]*256+data[6])*65536 + data[5]*256 + data[4]
        r['dist_high'] = data[13]*256 + data[12]
    elif addr == 154:
        r['alarm_rec'] = data[7]*256 + data[6]
    return r

def parse_legacy(data, cmd):
    r = {}
    if cmd == 0:
        r['gear'] = data[4] & 0x03
        r['xs_control'] = ((data[4] >> 2) ^ 2) & 0x03
        r['pass_ok'] = (data[5] & 0x0C) >> 2
        r['comp_phone'] = (data[5] & 0x10) != 0
        r['eabs'] = (data[5] & 0x03) == 2
        r['rpm'] = to_signed_int16(data[6]*256 + data[7])
        r['stop'] = (data[9] & 0x80) != 0
        r['faults'] = parse_faults(data[8], data[9], 0, 0, 0)
    elif cmd == 1:
        r['voltage'] = to_signed_int16(data[2]*256 + data[3]) / 10.0
        r['current'] = to_signed_int16(data[4]*256 + data[5]) / 4.0
        r['modulation'] = round(data[6] / 128.0, 4)
        r['weak_field'] = (data[7] & 0x01) != 0
        r['throttle_depth'] = data[12]*256 + data[13]
    elif cmd == 2:
        ra = data[2]*65536 + data[3]*256 + data[4]
        r['phase_a'] = round(1.953125 * math.sqrt(ra), 2)
        rc = data[9]*65536 + data[10]*256 + data[11]
        r['phase_c'] = round(1.953125 * math.sqrt(rc), 2)
    elif cmd == 3:
        r['phase_a_ratio'] = data[8]*256 + data[9]
        r['phase_c_ratio'] = data[10]*256 + data[11]
    elif cmd == 4:
        mos = data[4]
        if mos > 200: mos -= 256
        r['mos_temp'] = mos
        r['line_curr_ratio'] = data[8]*256 + data[9]
    elif cmd == 8:
        r['pole_pairs'] = data[10]
    elif cmd == 10:
        r['soc'] = data[10]
    elif cmd == 13:
        r['motor_temp'] = data[2]
        r['throttle_v'] = round((data[4]*256 + data[5]) * 3.3 * 1.5 / 4096.0, 3)
        r['fw_ver'] = chr(data[10]) if data[10] >= 32 else '?'
    elif cmd == 15:
        r['motor_stop'] = data[4]*256 + data[5]
        r['function_st'] = data[2]
        r['motor_run'] = data[3]*256
        r['gs1'] = data[6]*256 + data[7]
        r['gs2'] = data[8]*256 + data[9]
        r['gs3'] = data[10]*256 + data[11]
        r['gs4'] = data[12]*256 + data[13]
        r['autolearn'] = (r['gs1'] & 0x20) != 0
        r['motor_on'] = (r['gs1'] & 0x2000) != 0
    elif cmd == 18:
        r['series_count'] = data[8]
    elif 32 <= cmd <= 39:
        base = (cmd - 32) * 6
        for i in range(6):
            mv = to_signed_int16(data[i*2+2]*256 + data[i*2+3])
            r[f'cell_{base+i}_mv'] = mv
            if cmd <= 35:
                if mv > 4110: cap = 127
                elif mv < 3600: cap = 0
                else: cap = (mv - 3600) // 4
                r[f'cell_{base+i}_cap'] = cap
    return r

def parse(hex_str):
    """解析一个 hex 字符串，返回 dict"""
    data = bytes.fromhex(hex_str.strip())
    if len(data) != 16 or data[0] != 0xAA:
        return None

    result = {'raw': hex_str.strip()}

    if (data[1] & 0xC0) == 0x80:
        index = data[1] & 0x7F
        if index >= len(FlashReadAddr):
            return result
        addr = FlashReadAddr[index]
        result['protocol'] = 'FlashRead'
        result['index'] = index
        result['addr'] = addr
        if addr in KNOWN_ADDRS:
            result.update(parse_flashread(data, index, addr))
    else:
        cmd = data[1]
        result['protocol'] = 'Legacy'
        result['cmd'] = cmd
        if cmd in KNOWN_CMDS:
            result.update(parse_legacy(data, cmd))

    return result
```

---

## 7. Legacy 参数帧（CMD=6~21，连接时一次性读取）

> ⚠️ 这些 CMD 在 `ParaPage.cs` 中定义，用于读取控制器配置参数，**不是实时遥测数据**。仅在蓝牙连接时读取一次。

### 7.1 CMD 分发

| CMD | 内容 | 见章节 |
|-----|------|--------|
| 6 | 电机方向 + 停车配置 | 7.2 |
| 7 | 通用参数存储（无特殊解析） | 7.3 |
| 9 | 额定/最大/中间转速 | 7.4 |
| 10 | 最大线电流 + 参数索引 | 7.5 |
| 11 | 欠压保护/恢复 + 倒车电流 | 7.6 |
| 12 | 软件版本号 | 7.7 |
| 13 | 硬件版本 + 电池额定容量 | 7.8 |
| 14 | 产品代码 + 生产日期 + 传感器类型 | 7.9 |
| 15 | 新蓝牙钥匙标志 | 7.10 |
| 18 | 低/中速电流 | 7.11 |
| 19 | 产品编号前半部分（ASCII） | 7.12 |
| 20 | 产品编号后半部分（ASCII） | 7.13 |
| 21 | EN最大电流 + 配置字节 | 7.14 |

**CMD=16, 17**：C# 源码中仅存储到 gflash 数组，无特殊解析逻辑。

### 7.2 CMD=6：电机方向 + 停车配置

```python
motor_direction = (data[13] & 0x80) >> 7   # 0 或 1
park_config     = (data[13] >> 5) & 0x03    # 0~3
cfg11l          = data[12]                   # 配置低字节
cfg11h          = data[13]                   # 配置高字节
```

### 7.3 CMD=7：通用参数存储

```python
# 仅存储到 gflash[12~17]，无特殊解析
gflash_12 = data[3]*256 + data[2]
gflash_13 = data[5]*256 + data[4]
gflash_14 = data[7]*256 + data[6]
gflash_15 = data[9]*256 + data[8]
gflash_16 = data[11]*256 + data[10]
gflash_17 = data[13]*256 + data[12]
```

### 7.4 CMD=9：额定/最大/中间转速

```python
rated_speed = data[4] * 256 + data[5]    # 额定转速 RPM
max_speed   = data[6] * 256 + data[7]    # 最大转速 RPM
mid_speed   = data[8] * 256 + data[9]    # 中间转速 RPM
```

### 7.5 CMD=10：最大线电流 + 参数索引

```python
max_line_curr = (data[2] * 256 + data[3]) / 4   # A
para_index    = data[5]                           # 参数索引
```

### 7.6 CMD=11：欠压保护/恢复 + 倒车电流

```python
low_vol_restore = (data[8] * 256 + data[9]) / 10.0    # V
low_vol_protect = (data[6] * 256 + data[7]) / 10.0    # V
stop_back_curr  = (data[10] * 256 + data[11]) / 4     # A（倒车电流）
```

### 7.7 CMD=12：软件版本号

```python
soft_ver = data[13]    # 整数
```

### 7.8 CMD=13：硬件版本 + 电池额定容量

```python
kzq_version0     = chr(data[10]) if data[10] >= 32 else '?'   # 硬件版本字符0
kzq_version1     = chr(data[11]) if data[11] >= 32 else '?'   # 硬件版本字符1
batt_rated_cap   = data[7]                                      # 电池额定容量
```

### 7.9 CMD=14：产品代码 + 生产日期 + 传感器类型

```python
custom_code0 = chr(data[2])                # 产品代码字符0（如 'X'）
custom_code1 = chr(data[3])                # 产品代码字符1（如 'K'）
year         = data[5] + 2000              # 生产年份
month        = data[6]                     # 生产月份
day          = data[7]                     # 生产日
hour         = data[8]                     # 时
minute       = data[9]                     # 分
second       = data[10]                    # 秒
bmq_hall     = (data[11] >> 2) & 1         # 传感器类型
park_config  = ((data[11] >> 1) & 1) << 1  # 停车配置
low_speed    = data[12] * 256 + data[13]   # 低速值
```

> ⚠️ **固件差异警告**：某些固件版本中，CMD=14 的 data[2:14] 全部为 ASCII 产品编号字符串（如 `XK2101205327`），此时不应按上述数值方式解析日期。判断方法：如果 `data[5]` 到 `data[13]` 全部在 0x30~0x39（'0'~'9'）范围内，则整个 data[2:14] 是 ASCII 产品编号。

### 7.10 CMD=15：新蓝牙钥匙标志

```python
new_blue_key = (data[4] & 0x01) != 0   # True=新蓝牙钥匙
```

### 7.11 CMD=18：低/中速电流

```python
low_speed_line_curr  = int(data[7] * 100 / 128 + 0.5)   # A
mid_speed_line_curr  = int(data[8] * 100 / 128 + 0.5)   # A
low_speed_phase_curr = int(data[9] * 100 / 128 + 0.5)   # A
mid_speed_phase_curr = int(data[10] * 100 / 128 + 0.5)  # A
```

### 7.12 CMD=19：产品编号前半部分（ASCII）

```python
serial_part1 = ''
for i in range(2, 10):
    if 32 < data[i] <= 126:
        serial_part1 += chr(data[i])
    else:
        serial_part1 += ' '
serial_part1 = serial_part1.strip()
# 示例输出: "GXNN-24G"（可能是型号标识）
```

### 7.13 CMD=20：产品编号后半部分（ASCII）

```python
serial_part2 = ''
for i in range(2, 14):
    if 32 < data[i] <= 126:
        serial_part2 += chr(data[i])
    else:
        serial_part2 += ' '
serial_part2 = serial_part2.strip()
# 示例输出: "XK2101205327"（产品编号）

# 完整产品编号 = serial_part1 + serial_part2
# 示例: "GXNN-24GXK2101205327"
```

### 7.14 CMD=21：EN最大电流 + 配置字节

```python
en_max_line_curr = data[2] * 256 + data[3]   # EN最大线电流（原始值）
en_max_phase_curr = data[4] * 256 + data[5]  # EN最大相电流（原始值）
cfg190l = data[6]                              # 配置低字节
cfg190h = data[7]                              # 配置高字节
morse_code = data[8]                           # 摩斯码
```

---

## 8. 与之前版本的关键修正

| # | 之前（验证4.py） | 修正后 | 原因 |
|---|-----------------|--------|------|
| 1 | CMD=1 电压 = `data[3]*256+data[2]` = 102.7V | `data[2]*256+data[3]` = **77.2V** | C# 源码为 `(short)(arg[2]*256+arg[3])`，大端序 |
| 2 | CMD=0 故障用 data[4]/data[5] | 用 **data[8]/data[9]** | C# 源码 Legacy case 0 中故障位在 arg[8]/arg[9] |
| 3 | CMD=0 未解析转速 | `to_signed_int16(data[6]*256+data[7])` | C# 源码 `m_MeasureSpeed = (short)(arg[6]*256+arg[7])` |
| 4 | CMD=4 同时赋值电机温度=MOS温度 | 仅 MOS 温度 = data[4] | C# 源码 CMD=4 只赋 `m_mostemp = arg[4]` |
| 5 | FlashRead addr=226 未解析 | 完整解析转速/挡位/调制比/故障 | C# 源码 case 226 有完整逻辑 |
| 6 | FlashRead addr=232 未解析油门深度 | `data[13]*256+data[12]` | C# 源码 `ThrottleDepth = arg[13]*256+arg[12]` |
| 7 | FlashRead addr=244 未解析 | 电机温度 + SOC | C# 源码 case 244 |
| 8 | FlashRead addr=214 未解析 MOS 温度 | `to_signed_int16(data[13]*256+data[12])` | C# 源码 case 214 |

---

## 9. 控制器型号与产品编号

> ⚠️ **重要**：型号和产品编号 **不在实时遥测数据包中**，而是在 **FlashRead 参数帧** 中。需要收到多个 addr 的参数帧后拼装。

### 9.1 型号拼装规则

型号字符串由以下参数组合而成（C# 源码：`ParaPage.cs` 第 1579~1661 行 `GenName()` 函数）：

```
型号格式（示例）: YQ72V150H_4_88_G101
                  ↑↑ ↑  ↑  ↑ ↑ ↑  ↑ ↑↑ ↑
                  │ │ │  │  │ │ │  │ ││ │
                  │ │ │  │  │ │ │  │ ││ └─ 软件版本号
                  │ │ │  │  │ │ │  │ └└── 硬件版本号(2字符)
                  │ │ │  │  │ │ │  └───── 参数索引(1字符)
                  │ │ │  │  │ │ └──────── 电机直径代码
                  │ │ │  │  │ └────────── 传感器类型(P/Q/B/无)
                  │ │ │  │  └──────────── 额定功率(×100W)
                  │ │ │  └─────────────── 额定电压(V)
                  │ │ └────────────────── 最大线电流(A)
                  │ └──────────────────── 产品代码(2字符)
                  └────────────────────── 产品代码(2字符)
```

### 9.2 型号所需的参数及其来源

| 参数 | 变量名 | 来源 addr | 字节位置 | 说明 |
|------|--------|-----------|----------|------|
| 产品代码0 | `rcv_CustomCode0` | 30 | `data[6]` | 字符，如 'Y' |
| 产品代码1 | `rcv_CustomCode1` | 30 | `data[7]` | 字符，如 'Q' |
| 额定电压 | `rcv_RatedVoltage` | 18 | `data[12:14]` | `(data[13]*256+data[12])/10`，单位 V |
| 额定功率 | `rcv_RatedPower100` | 18 | `data[10:12]` | `(data[11]*256+data[10])/100`，单位 100W |
| 极对数 | `rcv_PolePairs` | 18 | `data[6]` | 直接值 |
| 传感器类型 | `rcv_Bmq_Hall` | 226 | `data[3]` bit5 | ≥8→P, ≥4→Q, >0→B, 0→无 |
| 电机直径代码 | `rcv_MOTORDIA` | 99 | `data[6]` | 直接值 |
| 最大线电流 | `rcv_ENMaxLineCurr` | 99 | `data[2:4]` | `data[3]*256+data[2]` |
| 最大相电流 | `rcv_ENMaxPhaseCurr` | 99 | `data[4:6]` | `data[5]*256+data[4]` |
| 参数索引 | `rcv_ParaIndex` | 105 | `data[12]` | 直接值 |
| 特殊代码 | `rcv_SpecialCode` | 105 | `data[13]` | 字符 |
| 硬件版本0 | `rcv_kzqVersion0` | 130 | `data[11]` | 字符，>'6' 表示完整数据 |
| 硬件版本1 | `rcv_kzqVersion1` | 130 | `data[12]` | 字符 |
| 软件版本 | `rcv_SoftVer` | 130 | `data[13]` | 整数 |

### 9.3 型号拼装逻辑（Python）

```python
def generate_model_name(params):
    """
    params 字典需包含以下键：
      custom_code0, custom_code1, rated_voltage, rated_power100,
      pole_pairs, bmq_hall, motordia, en_max_line_curr, en_max_phase_curr,
      para_index, special_code, kzq_version0, kzq_version1, soft_ver
    """
    cc0 = params['custom_code0']   # char
    cc1 = params['custom_code1']   # char
    voltage = params['rated_voltage']
    power100 = params['rated_power100']
    pp = params['pole_pairs']
    hall = params['bmq_hall']
    dia = params['motordia']
    max_line = params['en_max_line_curr']
    max_phase = params['en_max_phase_curr']
    pidx = params['para_index']
    sp_code = params['special_code']
    v0 = params['kzq_version0']
    v1 = params['kzq_version1']
    sv = params['soft_ver']

    # 参数索引转字符
    if pidx < 10:
        pidx2 = chr(pidx + 48)       # '0'~'9'
    elif pidx < 20:
        pidx2 = chr(pidx + 48 - 10)  # 偏移
    else:
        pidx2 = chr(pidx)

    # 特殊代码转字符
    if '0' <= sp_code < chr(0x7F):
        pidx3 = sp_code
    else:
        pidx3 = '_'

    # 电机直径代码转换
    cfg190h_byte = 0  # 需从 addr=99 的高字节获取
    num7 = dia
    if not new_version:
        pass  # 直接用 dia
    else:
        n = cfg190h_byte & 0xF
        if n < 2:
            num7 = dia + 10
        elif n < 10:
            num7 = dia + n * 10
        else:
            num7 = 0

    # 根据条件选择型号格式
    dia_mod = dia % 10
    if dia_mod in (0, 2, 3, 4):
        # 新格式：带传感器类型后缀
        num8 = max_phase // 4
        if hall >= 8:
            suffix = "P"
        elif hall >= 4:
            suffix = "Q"
        elif hall > 0:
            suffix = "B"
        else:
            suffix = ""
        model = f"{cc0}{cc1}{voltage}{num8}{suffix}_{num7}_{pidx2}{pidx3}{v0}{v1}{sv}"
    elif cc0 == 'Y' and cc1 == 'C':
        # YC 系列特殊格式
        v_str = f"{voltage:03d}" if voltage >= 100 else f"0{voltage}"
        curr_str = f"{max_line//4:03d}" if max_line//4 >= 100 else f"0{max_line//4}"
        model = f"{cc0}{cc1}K{v_str}{curr_str}{pidx2}{pidx3}{v0}{v1}{sv}"
    elif pidx > 47:
        # 大功率格式
        num10 = max_line // 4
        if hall >= 8:
            suffix = "P"
        elif hall >= 4:
            suffix = "Q"
        elif hall > 0:
            suffix = "B"
        else:
            suffix = ""
        model = f"{cc0}{cc1}{voltage}V{num10}A{suffix}_{num7}_{pidx2}{pidx3}{v0}{v1}{sv}"
    elif hall > 0:
        # 带霍尔传感器
        model = f"{cc0}{cc1}{voltage}V{power100}H_{pp}{num7}_{pidx2}{pidx3}{v0}{v1}{sv}"
    else:
        # 默认格式
        model = f"{cc0}{cc1}{voltage}V{power100}H_{pp}{num7}_{pidx2}{pidx3}{v0}{v1}{sv}"

    return model
```

### 9.4 产品编号（Serial Number）

产品编号从 **addr=93** 的参数帧中读取（C# 源码：`ParaPage.cs` 第 1195~1205 行）：

```python
# addr=93 时，data[2:12] 为 ASCII 字符串
serial_number = ''.join(chr(b) for b in data[2:12]).strip()
# 示例: "CHINA96Z2019"
```

> **注意**：产品编号是控制器出厂时烧录的固定字符串，不会变化。

### 9.5 如何在实际中获取型号

**实际操作流程**：

1. 连接蓝牙后，APP 会依次发送 FlashRead 请求（index 0~54）
2. 控制器返回 55 个参数帧
3. APP 从这些帧中提取参数，拼装出型号
4. **你不需要主动请求**，只要正常连接并等待参数读取完成即可

**如果你只抓到了实时数据包（Legacy CMD=0~15），是拿不到型号的**。必须抓到 FlashRead 参数帧（data[1] & 0xC0 == 0x80 的包）才能解析出型号。

**最快获取型号的方法**：监听以下 addr 的 FlashRead 帧：
- **addr=30**（index=5 或 index=14 等）→ 产品代码
- **addr=18**（index=6）→ 额定电压、功率、极对数
- **addr=99**（index=19）→ 电机直径、最大电流
- **addr=226**（index=0）→ 传感器类型
- **addr=105**（index=20）→ 参数索引
- **addr=130**（index=25）→ 硬件/软件版本
