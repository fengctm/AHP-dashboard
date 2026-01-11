import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/permission_provider.dart';
import '../widgets/molecules/permission_request_card.dart';
import '../widgets/atoms/adaptive_card.dart';
import '../widgets/atoms/custom_button.dart';
import '../../../core/constants/permission_constants.dart';
import '../../../core/theme/app_colors.dart';
import 'dashboard_page.dart';

/// 权限请求页面
/// 应用启动时显示，要求用户授予必要权限
class PermissionPage extends ConsumerStatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends ConsumerState<PermissionPage> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    // 初始化时检查权限
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPermissions();
    });
  }

  Future<void> _checkInitialPermissions() async {
    final permissionNotifier = ref.read(permissionProvider.notifier);
    await permissionNotifier.refresh();
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在请求权限...';
    });

    try {
      final permissionNotifier = ref.read(permissionProvider.notifier);
      final allGranted = await permissionNotifier.requestAllRequiredPermissions();

      setState(() {
        _isLoading = false;
      });

      if (allGranted) {
        setState(() {
          _statusMessage = PermissionConstants.readyToProceed;
        });
        
        // 延迟后跳转
        await Future.delayed(const Duration(milliseconds: 1500));
        _proceedToDashboard();
      } else {
        final missing = permissionNotifier.getMissingPermissions();
        setState(() {
          _statusMessage = '缺少 ${missing.length} 个必要权限';
        });
        
        _showWarning(missing.length);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '请求失败: $e';
      });
      _showError();
    }
  }

  Future<void> _proceedToDashboard() async {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showWarning(int missingCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('还有 $missingCount 个权限未授予，请手动授予权限'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '我知道了',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Text('权限请求出错，请重试'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openSettings() async {
    final permissionNotifier = ref.read(permissionProvider.notifier);
    final result = await permissionNotifier.openSettings();
    
    if (result) {
      // 等待用户返回并刷新
      await Future.delayed(const Duration(seconds: 1));
      await permissionNotifier.refresh();
      
      // 检查是否所有权限都已授予
      if (await permissionNotifier.hasAllRequiredPermissions()) {
        _proceedToDashboard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionUtils = ref.watch(permissionUtilsProvider);
    final state = ref.watch(permissionProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题区域
              _buildHeader(),
              const SizedBox(height: 24),
              
              // 权限说明
              _buildExplanation(),
              const SizedBox(height: 20),
              
              // 权限列表
              if (state.value != null) ...[
                PermissionRequestList(
                  permissions: PermissionGroup.required,
                  onAllGranted: () {
                    // 所有权限授予后自动跳转
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        _proceedToDashboard();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // 可选权限
                _buildOptionalPermissions(),
                const SizedBox(height: 16),
                
                // 权限总结
                const PermissionSummaryCard(),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('正在检查权限...'),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // 操作按钮
              _buildActionButtons(permissionUtils),
              
              // 状态消息
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildStatusMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Animate(
      effects: [
        FadeEffect(duration: 400.ms, delay: 100.ms),
        SlideEffect(
          begin: const Offset(0, -0.2),
          duration: 400.ms,
          delay: 100.ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            PermissionConstants.permissionRequiredTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PermissionConstants.permissionRequiredDescription,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return AdaptiveCard(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                PermissionConstants.whyNeedPermissions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• ${PermissionConstants.bluetoothExplanation}\n'
            '• ${PermissionConstants.locationExplanation}\n'
            '• ${PermissionConstants.backgroundExplanation}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalPermissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '可选权限（推荐）',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const PermissionRequestList(
          permissions: PermissionGroup.optional,
        ),
      ],
    );
  }

  Widget _buildActionButtons(PermissionUtils permissionUtils) {
    return Column(
      children: [
        // 主要操作按钮
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: _isLoading ? '请求中...' : PermissionConstants.requestAll,
                onPressed: _isLoading ? null : _requestAllPermissions,
                icon: Icons.key,
                expanded: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 辅助按钮
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _openSettings,
                icon: const Icon(Icons.settings),
                label: const Text(PermissionConstants.openSettings),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        // 跳过可选权限（如果已满足必要权限）
        FutureBuilder<bool>(
          future: permissionUtils.hasAllRequiredPermissions,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading ? null : _proceedToDashboard,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('跳过可选权限'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    final hasError = _statusMessage.contains('失败') || _statusMessage.contains('错误');
    final isSuccess = _statusMessage.contains('成功') || _statusMessage.contains('就绪');

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
      ],
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasError
              ? Colors.red.withValues(alpha: 0.1)
              : isSuccess
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasError
                ? Colors.red
                : isSuccess
                    ? Colors.green
                    : Colors.orange,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasError ? Icons.error : (isSuccess ? Icons.check_circle : Icons.info),
              color: hasError ? Colors.red : (isSuccess ? Colors.green : Colors.orange),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: hasError
                      ? Colors.red
                      : isSuccess
                          ? Colors.green
                          : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}