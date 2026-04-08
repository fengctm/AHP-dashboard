import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/permission_provider.dart';
import '../widgets/molecules/permission_request_card.dart';
import '../widgets/atoms/adaptive_card.dart';
import '../widgets/atoms/custom_button.dart';
import '../../../core/constants/permission_constants.dart';
import 'dashboard_page.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text('还有 $missingCount 个权限未授予，请手动授予权限'),
            ),
          ],
        ),
        backgroundColor: colorScheme.errorContainer,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '我知道了',
          textColor: colorScheme.onErrorContainer,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showError() {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            const Text('权限请求出错，请重试'),
          ],
        ),
        backgroundColor: colorScheme.errorContainer,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _openSettings() async {
    final permissionNotifier = ref.read(permissionProvider.notifier);
    final result = await permissionNotifier.openSettings();
    
    if (result) {
      await Future.delayed(const Duration(seconds: 1));
      await permissionNotifier.refresh();
      
      if (await permissionNotifier.hasAllRequiredPermissions()) {
        _proceedToDashboard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionUtils = ref.watch(permissionUtilsProvider);
    final state = ref.watch(permissionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme),
              const SizedBox(height: 24),
              
              _buildExplanation(colorScheme),
              const SizedBox(height: 20),
              
              if (state.value != null) ...[
                PermissionRequestList(
                  permissions: PermissionGroup.required,
                  onAllGranted: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        _proceedToDashboard();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                _buildOptionalPermissions(),
                const SizedBox(height: 16),
                
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
              
              _buildActionButtons(permissionUtils, colorScheme),
              
              if (_statusMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildStatusMessage(colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
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
          Card.filled(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.security,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            PermissionConstants.permissionRequiredTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PermissionConstants.permissionRequiredDescription,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation(ColorScheme colorScheme) {
    return AdaptiveCard(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
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
        const Text(
          '可选权限（推荐）',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        PermissionRequestList(
          permissions: PermissionGroup.optional,
        ),
      ],
    );
  }

  Widget _buildActionButtons(PermissionUtils permissionUtils, ColorScheme colorScheme) {
    return Column(
      children: [
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

  Widget _buildStatusMessage(ColorScheme colorScheme) {
    final hasError = _statusMessage.contains('失败') || _statusMessage.contains('错误');
    final isSuccess = _statusMessage.contains('成功') || _statusMessage.contains('就绪');

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
      ],
      child: Card.filled(
        color: hasError
            ? colorScheme.errorContainer
            : isSuccess
                ? colorScheme.primaryContainer
                : colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                hasError ? Icons.error : (isSuccess ? Icons.check_circle : Icons.info),
                color: hasError
                    ? colorScheme.error
                    : isSuccess
                        ? colorScheme.primary
                        : colorScheme.tertiary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: hasError
                        ? colorScheme.onErrorContainer
                        : isSuccess
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
