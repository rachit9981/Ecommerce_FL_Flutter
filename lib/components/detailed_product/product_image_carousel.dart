import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaItem {
  final String url;
  final String type; // 'image' or 'video'
  final String? thumbnailUrl; // For videos, this can be a preview image

  MediaItem({
    required this.url,
    required this.type,
    this.thumbnailUrl,
  });
}

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final List<String> videos;
  final String heroTag;

  const ProductImageCarousel({
    Key? key,
    required this.images,
    this.videos = const [],
    required this.heroTag,
  }) : super(key: key);

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<MediaItem> _mediaItems;
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeMediaItems();
    _initializeVideoControllers();
  }
  void _initializeMediaItems() {
    _mediaItems = [];
    
    print('Initializing media items...');
    print('Images: ${widget.images}');
    print('Videos: ${widget.videos}');
    
    // Add images
    for (String imageUrl in widget.images) {
      _mediaItems.add(MediaItem(url: imageUrl, type: 'image'));
    }
    
    // Add videos after images
    for (String videoUrl in widget.videos) {
      print('Adding video: $videoUrl');
      _mediaItems.add(MediaItem(
        url: videoUrl, 
        type: 'video',
        thumbnailUrl: videoUrl, // In real app, you'd have actual thumbnail
      ));
    }
    
    print('Total media items: ${_mediaItems.length}');
  }
  void _initializeVideoControllers() {
    print('Initializing video controllers for ${_mediaItems.length} media items');
    
    for (final mediaItem in _mediaItems) {
      if (mediaItem.type == 'video') {
        print('Initializing video: ${mediaItem.url}');
        
        try {
          // Validate URL first
          final uri = Uri.parse(mediaItem.url);
          print('Parsed URI: $uri');
          
          final controller = VideoPlayerController.networkUrl(uri);
          _videoControllers[mediaItem.url] = controller;
          
          controller.initialize().then((_) {
            print('Video initialized successfully: ${mediaItem.url}');
            print('Video duration: ${controller.value.duration}');
            print('Video size: ${controller.value.size}');
            if (mounted) setState(() {});
          }).catchError((error) {
            print('Error initializing video: $error');
            print('Video URL: ${mediaItem.url}');
            print('Error type: ${error.runtimeType}');
            // Remove failed controller
            _videoControllers.remove(mediaItem.url);
            if (mounted) setState(() {});
          });
        } catch (e) {
          print('Error parsing video URL: $e');
          print('Invalid video URL: ${mediaItem.url}');
        }
      }
    }
  }
  @override
  void dispose() {
    _pageController.dispose();
    // Pause and dispose all video controllers
    for (final controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
      controller.dispose();
    }
    super.dispose();
  }

  void _onThumbnailTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override  @override
  Widget build(BuildContext context) {
    if (_mediaItems.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main carousel
        Container(
          height: 300,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _mediaItems.length,              onPageChanged: (index) {
                setState(() {
                  // Pause all videos first
                  for (final controller in _videoControllers.values) {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    }
                  }
                  
                  _currentIndex = index;
                  
                  // If the new page is a video, you can optionally auto-play it
                  // (commented out to avoid auto-play, user can manually play)
                  // final currentMedia = _mediaItems[index];
                  // if (currentMedia.type == 'video') {
                  //   final controller = _videoControllers[currentMedia.url];
                  //   if (controller != null && controller.value.isInitialized) {
                  //     controller.play();
                  //   }
                  // }
                });
              },
              itemBuilder: (context, index) {
                final mediaItem = _mediaItems[index];
                Widget mediaWidget;

                if (mediaItem.type == 'video') {
                  mediaWidget = _buildVideoWidget(mediaItem);
                } else {
                  mediaWidget = _buildImageWidget(mediaItem, index);
                }

                return mediaWidget;
              },
            ),
          ),
        ),
        
        // Thumbnails row with better icons
        if (_mediaItems.length > 1)
          Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final mediaItem = _mediaItems[index];
                final isSelected = index == _currentIndex;
                
                return GestureDetector(
                  onTap: () => _onThumbnailTap(index),
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [                          // Thumbnail image
                          if (mediaItem.type == 'image')
                            Image.network(
                              mediaItem.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey.shade500,
                                  size: 24,
                                ),
                              ),
                            )
                          else
                            _buildVideoThumbnail(mediaItem),
                          
                          // Video overlay icon for better representation
                          if (mediaItem.type == 'video')
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          
                          // Selection overlay
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildImageWidget(MediaItem mediaItem, int index) {
    Widget imageWidget = Image.network(
      mediaItem.url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(
            Icons.broken_image,
            size: 80,
            color: Colors.grey,
          ),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );

    if (index == 0 && widget.heroTag.isNotEmpty) {
      imageWidget = Hero(tag: widget.heroTag, child: imageWidget);
    }

    return imageWidget;
  }
  Widget _buildVideoWidget(MediaItem mediaItem) {
    final controller = _videoControllers[mediaItem.url];
    
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Loading gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black87,
                    Colors.grey.shade800,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            
            // Loading indicator
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Video label at bottom
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          
          // Video controls overlay
          _VideoControlsOverlay(
            controller: controller,
            videoUrl: mediaItem.url,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(MediaItem mediaItem) {
    final controller = _videoControllers[mediaItem.url];
    
    if (controller != null && controller.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Video frame as thumbnail
          VideoPlayer(controller),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Play icon
          const Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      );
    } else {
      // Fallback for uninitialized videos
      return Container(
        color: Colors.black87,
        child: const Icon(
          Icons.play_circle_filled,
          color: Colors.white,
          size: 32,
        ),
      );
    }
  }
}

// Custom video controls overlay widget
class _VideoControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final String videoUrl;

  const _VideoControlsOverlay({
    required this.controller,
    required this.videoUrl,
  });

  @override
  State<_VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<_VideoControlsOverlay> {
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Main play/pause button
            if (_showControls)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            
            // Video progress bar and info at bottom
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Theme.of(context).primaryColor,
                          bufferedColor: Colors.white.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Video info
                      Row(
                        children: [
                          const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Product Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Duration text
                          ValueListenableBuilder(
                            valueListenable: widget.controller,
                            builder: (context, value, child) {
                              final position = value.position;
                              final duration = value.duration;
                              return Text(
                                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
