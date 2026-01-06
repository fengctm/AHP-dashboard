import 'dart:async';
import 'dart:typed_data';

enum MediaPlaybackState {
  none,
  playing,
  paused,
  stopped,
  buffering,
}

enum MediaRepeatMode {
  none,
  one,
  all,
}

enum MediaShuffleMode {
  off,
  on,
}

class MediaState {
  final String? title;
  final String? artist;
  final String? album;
  final MediaPlaybackState playbackState;
  final MediaRepeatMode repeatMode;
  final MediaShuffleMode shuffleMode;
  final int? position;
  final int? duration;
  final Uri? artworkUri;
  final Uint8List? artworkBytes; // 封面图字节数据
  final String? lyrics;

  const MediaState({
    this.title,
    this.artist,
    this.album,
    required this.playbackState,
    required this.repeatMode,
    required this.shuffleMode,
    this.position,
    this.duration,
    this.artworkUri,
    this.artworkBytes,
    this.lyrics,
  });
}

abstract class IMediaController {
  Stream<MediaState> get mediaStateStream;

  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  Future<void> playPause();

  Future<void> next();

  Future<void> previous();

  Future<void> stop();

  Future<void> seekTo(int position);

  Future<void> setVolume(double volume);

  Future<void> setRepeatMode(MediaRepeatMode mode);

  Future<void> setShuffleMode(MediaShuffleMode mode);

  Future<void> dispose();
}
