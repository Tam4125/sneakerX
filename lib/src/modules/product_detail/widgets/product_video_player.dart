import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProductVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLocalAsset; // True nếu là file trong máy, False nếu là link mạng

  const ProductVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.isLocalAsset = false,
  }) : super(key: key);

  @override
  State<ProductVideoPlayer> createState() => _ProductVideoPlayerState();
}

class _ProductVideoPlayerState extends State<ProductVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra xem video là link mạng hay file trong assets
    if (widget.isLocalAsset) {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    }

    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
      _controller.setLooping(true); // Lặp lại video
      _controller.setVolume(0.0);   // Tắt tiếng mặc định (giống Shopee)
      _controller.play();           // Tự động chạy
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return GestureDetector(
      onTap: () {
        // Bấm vào để bật/tắt tiếng
        setState(() {
          _controller.value.volume == 0.0
              ? _controller.setVolume(1.0)
              : _controller.setVolume(0.0);
        });
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          VideoPlayer(_controller),
          // Icon loa (Mute/Unmute)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              _controller.value.volume == 0.0 ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}