package com.example.ahp_dashboard

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.io.ByteArrayOutputStream
import java.util.Base64

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"
    private var mediaSessionManager: MediaSessionManager? = null
    private val activeControllers = mutableMapOf<String, MediaController>()

    companion object {
        const val ACTION_MEDIA_STATE = "com.example.ahp_dashboard.MEDIA_STATE"
        const val EXTRA_MEDIA_DATA = "media_data"
        
        // 存储当前实例的引用
        @Volatile
        private var instance: NotificationListener? = null
        
        // 获取当前实例
        fun getInstance(): NotificationListener? {
            val currentInstance = instance
            if (currentInstance == null) {
                Log.w("NotificationListener", "getInstance() 被调用但实例为空")
                Log.w("NotificationListener", "服务可能未启动或权限未授予")
            }
            return currentInstance
        }
        
        // Check if notification listener permission is granted
        fun isPermissionGranted(context: Context): Boolean {
            val packageName = context.packageName
            val flat = android.provider.Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            )
            val isGranted = flat != null && flat.contains(packageName)
            Log.d("NotificationListener", "权限检查结果: $isGranted")
            return isGranted
        }
        
        /**
         * 请求系统重新绑定 NotificationListenerService
         * 这会触发服务的重启
         */
        fun requestRebind(context: Context) {
            try {
                Log.d("NotificationListener", "请求重新绑定 NotificationListener 服务")
                val componentName = ComponentName(context, NotificationListener::class.java)
                NotificationListenerService.requestRebind(componentName)
                Log.d("NotificationListener", "已发送重新绑定请求")
            } catch (e: Exception) {
                Log.e("NotificationListener", "请求重新绑定失败", e)
            }
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "通知监听器已连接")
        Log.d(TAG, "即将设置媒体会话监听器，延迟500ms")
        
        // 延迟一点时间确保服务完全准备好
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            Log.d(TAG, "延迟时间已到，开始调用 setupMediaSessionListener()")
            try {
                setupMediaSessionListener()
                Log.d(TAG, "setupMediaSessionListener() 调用完成")
            } catch (e: Exception) {
                Log.e(TAG, "setupMediaSessionListener() 调用失败", e)
            }
        }, 500)
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "通知监听器 onCreate 已调用")
        
        // 保存当前实例
        instance = this
        Log.d(TAG, "通知监听器实例已保存: ${instance != null}")
        
        // Initialize MediaSessionManager
        mediaSessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        Log.d(TAG, "媒体会话管理器已初始化")
    }

    private fun setupMediaSessionListener() {
        try {
            Log.d(TAG, "setupMediaSessionListener() 开始执行")
            Log.d(TAG, "mediaSessionManager 是否为null: ${mediaSessionManager == null}")
            
            val componentName = ComponentName(this, NotificationListener::class.java)
            Log.d(TAG, "ComponentName 创建完成: $componentName")
            
            val controllers = mediaSessionManager?.getActiveSessions(componentName) ?: emptyList()
            Log.d(TAG, "getActiveSessions() 调用完成")
            
            Log.d(TAG, "找到 ${controllers.size} 个活跃媒体会话")
            
            if (controllers.isEmpty()) {
                Log.w(TAG, "未找到活跃媒体会话。请确保有音乐应用正在播放。")
            }
            
            for (controller in controllers) {
                val packageName = controller.packageName
                Log.d(TAG, "注册来自 $packageName 的媒体会话")
                activeControllers[packageName] = controller
                registerMediaCallback(controller)
                
                // Send initial state
                sendMediaState(controller)
            }
            
            // Listen for new media sessions
            mediaSessionManager?.addOnActiveSessionsChangedListener(
                { controllers ->
                    Log.d(TAG, "活跃会话已变化: ${controllers?.size ?: 0} 个会话")
                    updateActiveSessions(controllers ?: emptyList())
                },
                componentName
            )
            
            Log.d(TAG, "媒体会话监听器设置完成")
        } catch (e: SecurityException) {
            Log.e(TAG, "安全异常: 未授予通知监听权限", e)
        } catch (e: Exception) {
            Log.e(TAG, "设置媒体会话监听器时出错", e)
        }
    }

    private fun updateActiveSessions(controllers: List<MediaController>) {
        // Remove old controllers
        val newPackages = controllers.map { it.packageName }.toSet()
        val oldPackages = activeControllers.keys.toSet()
        val removedPackages = oldPackages - newPackages
        
        removedPackages.forEach { pkg ->
            activeControllers[pkg]?.unregisterCallback(callbacks[pkg]!!)
            activeControllers.remove(pkg)
            callbacks.remove(pkg)
        }
        
        // Add new controllers
        for (controller in controllers) {
            val packageName = controller.packageName
            if (!activeControllers.containsKey(packageName)) {
                activeControllers[packageName] = controller
                registerMediaCallback(controller)
            }
            sendMediaState(controller)
        }
    }

    private val callbacks = mutableMapOf<String, MediaController.Callback>()

    private fun registerMediaCallback(controller: MediaController) {
        val callback = object : MediaController.Callback() {
            override fun onMetadataChanged(metadata: MediaMetadata?) {
                Log.d(TAG, "${controller.packageName} 的元数据已变化")
                sendMediaState(controller)
            }

            override fun onPlaybackStateChanged(state: PlaybackState?) {
                Log.d(TAG, "${controller.packageName} 的播放状态已变化: ${state?.state}")
                sendMediaState(controller)
            }
        }
        
        callbacks[controller.packageName] = callback
        controller.registerCallback(callback)
    }

    // 存储当前活跃的控制器（用于媒体控制）
    private var currentActiveController: MediaController? = null
    // 缓存最后的媒体信息，用于暂停时仍然显示
    private var lastMediaData: Map<String, Any?>? = null
    
    private fun sendMediaState(controller: MediaController) {
        try {
            val metadata = controller.metadata
            val playbackState = controller.playbackState
            
            // 更新当前活跃的控制器（播放或暂停状态都保持跟踪）
            if (playbackState != null && 
                (playbackState.state == PlaybackState.STATE_PLAYING || 
                 playbackState.state == PlaybackState.STATE_PAUSED)) {
                currentActiveController = controller
            }
            
            // 如果 metadata 为空但有缓存，使用缓存数据更新播放状态
            if (metadata == null) {
                if (lastMediaData != null && playbackState != null) {
                    // 更新播放状态但保留其他信息
                    val updatedData = lastMediaData!!.toMutableMap()
                    updatedData["isPlaying"] = playbackState.state == PlaybackState.STATE_PLAYING
                    updatedData["position"] = playbackState.position
                    
                    Log.d(TAG, "使用缓存元数据更新播放状态: ${updatedData["title"]} (${if (playbackState.state == PlaybackState.STATE_PLAYING) "播放中" else "已暂停"})")
                    
                    // Broadcast to Flutter
                    val intent = Intent(ACTION_MEDIA_STATE)
                    intent.putExtra(EXTRA_MEDIA_DATA, HashMap(updatedData))
                    sendBroadcast(intent)
                } else {
                    Log.d(TAG, "${controller.packageName} 无元数据且无缓存")
                }
                return
            }
            
            val title = metadata.getString(MediaMetadata.METADATA_KEY_TITLE) ?: ""
            val artist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: ""
            val album = metadata.getString(MediaMetadata.METADATA_KEY_ALBUM) ?: ""
            val duration = metadata.getLong(MediaMetadata.METADATA_KEY_DURATION)
            val artwork = metadata.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)
            
            val isPlaying = playbackState?.state == PlaybackState.STATE_PLAYING
            val position = playbackState?.position ?: 0L
            
            // Convert artwork to base64 if available
            var artworkBase64: String? = null
            if (artwork != null) {
                try {
                    val stream = ByteArrayOutputStream()
                    artwork.compress(Bitmap.CompressFormat.JPEG, 85, stream)
                    val bytes = stream.toByteArray()
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        artworkBase64 = Base64.getEncoder().encodeToString(bytes)
                    } else {
                        artworkBase64 = android.util.Base64.encodeToString(bytes, android.util.Base64.NO_WRAP)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "编码封面图失败", e)
                }
            }
            
            val mediaData = mapOf(
                "packageName" to controller.packageName,
                "title" to title,
                "artist" to artist,
                "album" to album,
                "duration" to duration,
                "position" to position,
                "isPlaying" to isPlaying,
                "artworkBase64" to artworkBase64
            )
            
            // 缓存媒体数据，以便在 metadata 为空时使用
            lastMediaData = mediaData
            
            Log.d(TAG, "发送媒体状态: $title - $artist (${if (isPlaying) "播放中" else "已暂停"})")
            
            // Broadcast to Flutter
            val intent = Intent(ACTION_MEDIA_STATE)
            intent.putExtra(EXTRA_MEDIA_DATA, HashMap(mediaData))
            sendBroadcast(intent)
            
        } catch (e: Exception) {
            Log.e(TAG, "发送媒体状态失败", e)
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        // Keep the existing notification logging if needed
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Keep the existing notification logging if needed
    }

    // 媒体控制方法
    fun performMediaAction(action: String): Boolean {
        Log.d(TAG, "执行媒体操作: $action")
        Log.d(TAG, "当前活跃控制器: ${currentActiveController?.packageName}")
        Log.d(TAG, "活跃控制器总数: ${activeControllers.size}")
        
        val controller = currentActiveController ?: activeControllers.values.firstOrNull()
        if (controller == null) {
            Log.w(TAG, "没有活跃媒体控制器来执行操作: $action")
            return false
        }
        
        Log.d(TAG, "使用来自 ${controller.packageName} 的控制器")
        
        return try {
            when (action) {
                "play" -> {
                    controller.transportControls.play()
                    Log.d(TAG, "已发送播放指令")
                    true
                }
                "pause" -> {
                    controller.transportControls.pause()
                    Log.d(TAG, "已发送暂停指令")
                    true
                }
                "playPause" -> {
                    val isPlaying = controller.playbackState?.state == PlaybackState.STATE_PLAYING
                    if (isPlaying) {
                        controller.transportControls.pause()
                        Log.d(TAG, "已发送暂停指令（之前正在播放）")
                    } else {
                        controller.transportControls.play()
                        Log.d(TAG, "已发送播放指令（之前已暂停）")
                    }
                    true
                }
                "next" -> {
                    controller.transportControls.skipToNext()
                    Log.d(TAG, "已发送下一曲指令")
                    true
                }
                "previous" -> {
                    controller.transportControls.skipToPrevious()
                    Log.d(TAG, "已发送上一曲指令")
                    true
                }
                "stop" -> {
                    controller.transportControls.stop()
                    Log.d(TAG, "已发送停止指令")
                    true
                }
                else -> {
                    Log.w(TAG, "未知的媒体操作: $action")
                    false
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "执行媒体操作失败: $action", e)
            false
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "通知监听器已销毁")
        
        currentActiveController = null
        lastMediaData = null
        instance = null
        
        // Unregister all callbacks
        activeControllers.forEach { (pkg, controller) ->
            callbacks[pkg]?.let { controller.unregisterCallback(it) }
        }
        activeControllers.clear()
        callbacks.clear()
    }
}
