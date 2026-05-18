import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/album_model.dart';
import '../../data/models/memory_model.dart';
import '../../data/services/memory_service.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final MemoryService _memoryService = MemoryService();
  final ImagePicker _imagePicker = ImagePicker();

  List<AlbumModel> _albums = [];
  List<MemoryPhotoModel> _photos = [];
  final Map<String, Uint8List> _photoBytes = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _lightboxOpen = false;
  Uint8List? _lightboxBytes;
  String _lightboxCaption = '';

  List<MemoryPhotoModel> get _recentPhotos {
    final photos = [..._photos];
    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  List<String> get _photosWithoutAlbum {
    return _photos
        .where((photo) => photo.albumId == null || photo.albumId!.isEmpty)
        .map((photo) => photo.id)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    setState(() => _isLoading = true);
    final library = await _memoryService.loadLibrary();
    final decrypted = <String, Uint8List>{};
    for (final photo in library.photos) {
      final bytes = await _memoryService.decryptPhoto(photo);
      if (bytes != null) {
        decrypted[photo.id] = bytes;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _albums = library.albums;
      _photos = library.photos;
      _photoBytes
        ..clear()
        ..addAll(decrypted);
      _isLoading = false;
    });
  }

  Future<void> _uploadPhotos() async {
    try {
      final picked = await _imagePicker.pickMultiImage(
        imageQuality: 88,
        maxWidth: 2200,
      );
      if (picked.isEmpty) {
        return;
      }

      setState(() => _isSaving = true);
      await _memoryService.addEncryptedPhotos(
        picked.map((photo) => File(photo.path)).toList(),
      );
      await _loadLibrary();
    } catch (error) {
      _showSnack(_friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _createAlbum() async {
    final photoIds = _photosWithoutAlbum;
    if (photoIds.isEmpty) {
      _showSnack('Add new photos before creating another album.');
      return;
    }

    final title = await _askAlbumTitle();
    if (title == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _memoryService.createAlbum(title: title, photoIds: photoIds);
      await _loadLibrary();
    } catch (error) {
      _showSnack(_friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<String?> _askAlbumTitle() async {
    final controller = TextEditingController();
    try {
      return showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Album'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Album name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final title = controller.text.trim();
                  Navigator.pop(context, title.isEmpty ? 'New Album' : title);
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  void _openLightbox(MemoryPhotoModel photo) {
    final bytes = _photoBytes[photo.id];
    if (bytes == null) {
      _showSnack('Could not decrypt this photo.');
      return;
    }

    setState(() {
      _lightboxBytes = bytes;
      _lightboxCaption = photo.originalName;
      _lightboxOpen = true;
    });
  }

  void _closeLightbox() {
    setState(() {
      _lightboxOpen = false;
      _lightboxBytes = null;
      _lightboxCaption = '';
    });
  }

  void _pushAlbumDetail(AlbumModel album) {
    final photos = _photos.where((photo) => album.photoIds.contains(photo.id)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AlbumDetailScreen(
          album: album,
          photos: photos,
          photoBytes: _photoBytes,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              _Header(isSaving: _isSaving),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.blue),
                      )
                    : _photos.isEmpty
                        ? _EmptyPhotosState(onUpload: _uploadPhotos)
                        : _buildLibraryBody(),
              ),
            ],
          ),
          if (_lightboxOpen && _lightboxBytes != null) _buildLightbox(),
        ],
      ),
    );
  }

  Widget _buildLibraryBody() {
    final heroPhoto = _recentPhotos.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OnThisDayCard(
            photo: heroPhoto,
            bytes: _photoBytes[heroPhoto.id],
            onTap: () => _openLightbox(heroPhoto),
          ),
          if (_albums.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle('Albums'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
              ),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                final cover = _coverPhoto(album);
                return _AlbumCard(
                  album: album,
                  coverBytes: cover == null ? null : _photoBytes[cover.id],
                  onTap: () => _pushAlbumDetail(album),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          const _SectionTitle('Recent'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: _recentPhotos.length,
            itemBuilder: (context, index) {
              final photo = _recentPhotos[index];
              return _PhotoTile(
                bytes: _photoBytes[photo.id],
                onTap: () => _openLightbox(photo),
              );
            },
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            label: _isSaving ? 'Encrypting...' : 'Upload Photos',
            icon: Icons.add,
            onTap: _isSaving ? null : _uploadPhotos,
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            label: 'Create Album',
            icon: Icons.photo_album_outlined,
            onTap: _isSaving ? null : _createAlbum,
          ),
        ],
      ),
    );
  }

  MemoryPhotoModel? _coverPhoto(AlbumModel album) {
    for (final id in album.photoIds) {
      for (final photo in _photos) {
        if (photo.id == id) {
          return photo;
        }
      }
    }

    return null;
  }

  Widget _buildLightbox() {
    return GestureDetector(
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
                    child: Image.memory(
                      _lightboxBytes!,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _lightboxCaption,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap anywhere to close',
                    style: TextStyle(fontSize: 11, color: Color(0x66FFFFFF)),
                  ),
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
    );
  }
}

class _Header extends StatelessWidget {
  final bool isSaving;

  const _Header({required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Album',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isSaving ? 'Encrypting' : 'Encrypted',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

class _EmptyPhotosState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyPhotosState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, size: 42, color: AppColors.g400),
            const SizedBox(height: 12),
            const Text(
              'There are no photos',
              style: TextStyle(
                color: AppColors.g900,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload photos to create encrypted albums.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.g500,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: _PrimaryButton(
                label: 'Upload Photos',
                icon: Icons.add,
                onTap: onUpload,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnThisDayCard extends StatelessWidget {
  final MemoryPhotoModel photo;
  final Uint8List? bytes;
  final VoidCallback onTap;

  const _OnThisDayCard({
    required this.photo,
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 174,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _MemoryImage(bytes: bytes)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 18,
              left: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ON THIS DAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '3 years ago today',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final Uint8List? coverBytes;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.album,
    required this.coverBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.g200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _MemoryImage(bytes: coverBytes),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.g900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.photoIds.length} photos',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.g400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: _MemoryImage(bytes: bytes),
      ),
    );
  }
}

class _MemoryImage extends StatelessWidget {
  final Uint8List? bytes;

  const _MemoryImage({required this.bytes});

  @override
  Widget build(BuildContext context) {
    if (bytes == null) {
      return Container(
        color: AppColors.g100,
        child: const Icon(Icons.lock_outline, color: AppColors.g400, size: 20),
      );
    }

    return Image.memory(
      bytes!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, color: Colors.white, size: 21),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppColors.g400,
        letterSpacing: 0,
      ),
    );
  }
}

class _AlbumDetailScreen extends StatefulWidget {
  final AlbumModel album;
  final List<MemoryPhotoModel> photos;
  final Map<String, Uint8List> photoBytes;

  const _AlbumDetailScreen({
    required this.album,
    required this.photos,
    required this.photoBytes,
  });

  @override
  State<_AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<_AlbumDetailScreen> {
  Uint8List? _lightboxBytes;
  String _lightboxCaption = '';

  void _openPhoto(MemoryPhotoModel photo) {
    final bytes = widget.photoBytes[photo.id];
    if (bytes == null) {
      return;
    }

    setState(() {
      _lightboxBytes = bytes;
      _lightboxCaption = photo.originalName;
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 16, 14),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        ),
                        Expanded(
                          child: Text(
                            widget.album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${widget.photos.length} photos',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: widget.photos.isEmpty
                    ? const Center(child: Text('There are no photos'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemCount: widget.photos.length,
                        itemBuilder: (context, index) {
                          final photo = widget.photos[index];
                          return _PhotoTile(
                            bytes: widget.photoBytes[photo.id],
                            onTap: () => _openPhoto(photo),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_lightboxBytes != null)
            GestureDetector(
              onTap: () => setState(() => _lightboxBytes = null),
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _lightboxBytes!,
                          fit: BoxFit.contain,
                          width: MediaQuery.of(context).size.width * 0.9,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _lightboxCaption,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
