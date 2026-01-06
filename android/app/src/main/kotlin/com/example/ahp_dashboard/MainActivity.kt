package com.example.ahp_dashboard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val METHOD_CHANNEL = "com.example.ahp_dashboard/media_control"
    private val EVENT_CHANNEL = "com.example.ahp_dashboard/media_events"
    
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    
    private val mediaReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == NotificationListener.ACTION_MEDIA_STATE) {
                val mediaData = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getSerializableExtra(
                        NotificationListener.EXTRA_MEDIA_DATA,
                        HashMap::class.java
                    ) as? HashMap<String, Any?>
                } else {
                    @Suppress("DEPRECATION")
                    intent.getSerializableExtra(NotificationListener.EXTRA_MEDIA_DATA) as? HashMap<String, Any?>
                }
                
                mediaData?.let {
                   Log.d(TAG, "收到媒体数据: ${it["title"]}")
                    eventSink?.success(it)
                }
            }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 确保 NotificationListener 服务已启动
        Log.d(TAG, "检查 NotificationListener 服务状态")
        val hasPermission = NotificationListener.isPermissionGranted(this)
        Log.d(TAG, "通知监听权限状态: $hasPermission")
        
        // Setup Method Channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    val granted = NotificationListener.isPermissionGranted(this)
                    Log.d(TAG, "权限检查结果: $granted")
                    result.success(granted)
                }
                "openNotificationListenerSettings" -> {
                    try {
                        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "打开通知监听设置失败", e)
                        result.error("ERROR", "Failed to open settings: ${e.message}", null)
                    }
                }
                "mediaControl" -> {
                    try {
                        val action = call.argument<String>("action")
                        Log.d(TAG, "收到媒体控制调用，操作: $action")
                        
                        if (action != null) {
                            // 获取 NotificationListener 实例并执行媒体控制
                            var listener = NotificationListener.getInstance()
                            
                            // 如果实例为空，等待一下（服务可能还没启动）
                            if (listener == null) {
                                Log.w(TAG, "NotificationListener 实例为空，等待服务启动...")
                                Thread.sleep(500)
                                listener = NotificationListener.getInstance()
                            }
                            
                            if (listener == null) {
                                Log.e(TAG, "NotificationListener 服务未运行")
                                Log.e(TAG, "请确保已授予通知监听权限")
                                Log.e(TAG, "提示: 在设置中关闭并重新开启通知监听权限")
                                result.success(false)
                                return@setMethodCallHandler
                            }
                            
                            Log.d(TAG, "找到 NotificationListener 实例，调用 performMediaAction")
                            val success = listener.performMediaAction(action)
                            Log.d(TAG, "媒体操作结果: $success")
                            result.success(success)
                        } else {
                            result.error("INVALID_ARGUMENT", "Action is null", null)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "媒体控制出错", e)
                        result.error("ERROR", "Media control failed: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        
        // Setup Event Channel
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                Log.d(TAG, "事件通道监听器已附加")
                eventSink = events
            }
            
            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "事件通道监听器已取消")
                eventSink = null
            }
        })
        
        // Register broadcast receiver
        val filter = IntentFilter(NotificationListener.ACTION_MEDIA_STATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(mediaReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(mediaReceiver, filter)
        }
        
        Log.d(TAG, "Flutter 引擎配置完成")
    }
    
    override fun onResume() {
        super.onResume()
        // 延迟检查，给系统时间启动 NotificationListener 服务
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            checkAndRebindNotificationListener()
        }, 1000) // 延迟1秒
    }
    
    private fun checkAndRebindNotificationListener() {
        val granted = NotificationListener.isPermissionGranted(this)
        Log.d(TAG, "onResume延迟检查: 通知监听权限 = $granted")
        
        // 尝试重启 NotificationListener 服务（如果权限已授予但服务未运行）
        if (granted) {
            val listener = NotificationListener.getInstance()
            if (listener == null) {
                Log.w(TAG, "权限已授予但 NotificationListener 服务未运行，请求重新绑定")
                
                // 请求系统重新绑定服务
                NotificationListener.requestRebind(this)
                
                // 发送一个提示，告知用户需要重启服务
                val permissionData = hashMapOf<String, Any>(
                    "permissionGranted" to granted,
                    "serviceRunning" to false,
                    "needRestart" to true
                )
                eventSink?.success(permissionData)
            } else {
                Log.d(TAG, "NotificationListener 服务正在运行")
                // 发送正常状态
                val permissionData = hashMapOf<String, Any>(
                    "permissionGranted" to granted,
                    "serviceRunning" to true
                )
                eventSink?.success(permissionData)
            }
        } else {
            // 权限未授予
            val permissionData = hashMapOf<String, Any>(
                "permissionGranted" to false,
                "serviceRunning" to false
            )
            eventSink?.success(permissionData)
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(mediaReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "取消注册接收器出错", e)
        }
    }
}
