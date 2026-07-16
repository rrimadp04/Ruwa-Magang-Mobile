import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

const _blue = Color(0xFF0757D8);

class SelfieCameraScreen extends StatefulWidget {
  const SelfieCameraScreen({super.key});

  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
  CameraController? _controller;
  XFile? _captured;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front)
          .toList();
      final camera = front.isNotEmpty ? front.first : cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'Kamera tidak dapat diakses. Pastikan izin kamera telah diberikan.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || controller.value.isTakingPicture) return;
    try {
      final photo = await controller.takePicture();
      if (mounted) {
        setState(() => _captured = photo);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil foto. Coba lagi.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Ambil Foto Selfie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(child: _body()),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: _captured == null
                ? FilledButton(
                    onPressed: _loading ? null : _capture,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _blue,
                      shape: const CircleBorder(),
                      fixedSize: const Size(76, 76),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 34),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _captured = null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: const Text('Ulang Foto'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, _captured),
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: const Text('Gunakan Foto'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }
    if (_captured != null) {
      return FutureBuilder<Uint8List>(
        future: _captured!.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.memory(snapshot.data!, fit: BoxFit.contain),
            ),
          );
        },
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CameraPreview(_controller!),
    );
  }
}
