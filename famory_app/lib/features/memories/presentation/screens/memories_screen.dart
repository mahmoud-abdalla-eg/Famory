import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class _Photo {
  final String thumbUrl;
  final String fullUrl;
  final String caption;
  _Photo({required this.thumbUrl, required this.fullUrl, required this.caption});
}

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  // Lightbox state
  bool _lightboxOpen = false;
  String _lightboxUrl = '';
  String _lightboxCaption = '';

  final List<_Photo> _recentPhotos = [
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1511895426328-dc8714191011?w=200&h=200&fit=crop&crop=faces', fullUrl: 'https://images.unsplash.com/photo-1511895426328-dc8714191011?w=600&h=600&fit=crop', caption: 'Family at the park'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&h=600&fit=crop', caption: 'Birthday celebration'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=600&h=600&fit=crop', caption: 'Summer vacation'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?w=600&h=600&fit=crop', caption: 'Autumn walk'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600&h=600&fit=crop', caption: 'Home cooking'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=600&h=600&fit=crop', caption: 'Weekend fun'),
  ];

  void _openLightbox(String url, String caption) {
    setState(() {
      _lightboxUrl = url;
      _lightboxCaption = caption;
      _lightboxOpen = true;
    });
  }

  void _closeLightbox() {
    setState(() => _lightboxOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Blue Header
              Container(
                color: AppColors.blue,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          children: [
                            Text('9:41', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Album', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text('🔒 AES-256', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // On This Day featured image
                      GestureDetector(
                        onTap: () => _openLightbox(
                          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&h=400&fit=crop',
                          '3 years ago today · Mountain trip',
                        ),
                        child: Container(
                          height: 140,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=140&fit=crop&crop=center',
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 14,
                                  left: 14,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ON THIS DAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
                                      Text('3 years ago today', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Albums section
                      const Text('ALBUMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.g400, letterSpacing: 0.6)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAlbumCard(
                              'Birthdays',
                              '47 photos',
                              'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=80&fit=crop&crop=center',
                              () => _pushAlbumDetail(context, 'Birthdays', '47 photos', _birthdayPhotos),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildAlbumCard(
                              'Vacations',
                              '134 photos',
                              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&h=80&fit=crop&crop=center',
                              () => _pushAlbumDetail(context, 'Vacations', '134 photos', _vacationPhotos),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Recent section
                      const Text('RECENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.g400, letterSpacing: 0.6)),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 3,
                          crossAxisSpacing: 3,
                        ),
                        itemCount: _recentPhotos.length,
                        itemBuilder: (ctx, i) {
                          final p = _recentPhotos[i];
                          return GestureDetector(
                            onTap: () => _openLightbox(p.fullUrl, p.caption),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(p.thumbUrl, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Upload button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('Upload Photos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Lightbox overlay
          if (_lightboxOpen)
            GestureDetector(
              onTap: _closeLightbox,
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _lightboxUrl,
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width * 0.9,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _lightboxCaption,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text('Tap anywhere to close', style: TextStyle(fontSize: 11, color: Color(0x66FFFFFF))),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 20,
                      child: GestureDetector(
                        onTap: _closeLightbox,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
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

  final List<_Photo> _birthdayPhotos = [
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=600&fit=crop', caption: "Emma's 7th birthday"),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1464349153735-7db50ed83c84?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1464349153735-7db50ed83c84?w=600&h=600&fit=crop', caption: 'Liam turns 6!'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600&h=600&fit=crop', caption: 'Birthday cake'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1543258103-a62bdc069871?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1543258103-a62bdc069871?w=600&h=600&fit=crop', caption: "Sarah's surprise party"),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1587668178277-295251f900ce?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1587668178277-295251f900ce?w=600&h=600&fit=crop', caption: 'Family birthday dinner'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1535378917042-10a22c95931a?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1535378917042-10a22c95931a?w=600&h=600&fit=crop', caption: 'Happy birthday balloons'),
  ];

  final List<_Photo> _vacationPhotos = [
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=600&fit=crop', caption: 'Beach vacation'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&h=600&fit=crop', caption: 'Mountain hiking'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=600&h=600&fit=crop', caption: 'Lake day'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600&h=600&fit=crop', caption: 'Forest trail'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=600&h=600&fit=crop', caption: 'Sunset view'),
    _Photo(thumbUrl: 'https://images.unsplash.com/photo-1488085061387-422e29b40080?w=200&h=200&fit=crop', fullUrl: 'https://images.unsplash.com/photo-1488085061387-422e29b40080?w=600&h=600&fit=crop', caption: 'City trip'),
  ];

  void _pushAlbumDetail(BuildContext ctx, String title, String count, List<_Photo> photos) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => _AlbumDetailScreen(title: title, count: count, photos: photos)));
  }

  Widget _buildAlbumCard(String title, String count, String imgUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.g200),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imgUrl, width: double.infinity, height: 72, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.g800)),
                  const SizedBox(height: 1),
                  Text(count, style: const TextStyle(fontSize: 10, color: AppColors.g400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Album Detail Screen (Birthdays / Vacations)
class _AlbumDetailScreen extends StatefulWidget {
  final String title;
  final String count;
  final List<_Photo> photos;

  const _AlbumDetailScreen({required this.title, required this.count, required this.photos});

  @override
  State<_AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<_AlbumDetailScreen> {
  bool _lightboxOpen = false;
  String _lightboxUrl = '';
  String _lightboxCaption = '';

  void _openLightbox(String url, String caption) {
    setState(() {
      _lightboxUrl = url;
      _lightboxCaption = caption;
      _lightboxOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: AppColors.blue,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          children: [
                            Text('9:41', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                            const Spacer(),
                            Text(widget.count, style: const TextStyle(fontSize: 11, color: Colors.white60)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: widget.photos.length,
                    itemBuilder: (ctx, i) {
                      final p = widget.photos[i];
                      return GestureDetector(
                        onTap: () => _openLightbox(p.fullUrl, p.caption),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(p.thumbUrl, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Lightbox
          if (_lightboxOpen)
            GestureDetector(
              onTap: () => setState(() => _lightboxOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_lightboxUrl, fit: BoxFit.contain, width: MediaQuery.of(context).size.width * 0.9),
                          ),
                          const SizedBox(height: 14),
                          Text(_lightboxCaption, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 60, right: 20,
                      child: GestureDetector(
                        onTap: () => setState(() => _lightboxOpen = false),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
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
}
