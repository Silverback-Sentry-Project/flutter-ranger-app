import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  bool _capturing = false;
  XFile? _lastCapture;

  Future<void> _capture() async {
    setState(() => _capturing = true);
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        imageQuality: 80,
      );
      if (photo != null) {
        _lastCapture = photo;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 80,
    );
    if (photo != null) {
      _lastCapture = photo;
    }
  }

  void _done() {
    if (_lastCapture != null) {
      context.pop([_lastCapture!.path]);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Photo'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(_lastCapture == null
                ? null
                : [_lastCapture!.path]),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_lastCapture != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(_lastCapture!.path),
                      height: 320,
                      width: 320,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                    ),
                  ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _capturing ? null : _capture,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(_capturing
                      ? 'Capturing...'
                      : _lastCapture == null
                          ? 'Take Photo'
                          : 'Retake'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(240, 52),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(240, 48),
                  ),
                ),
                const SizedBox(height: 24),
                if (_lastCapture != null)
                  ElevatedButton.icon(
                    onPressed: _done,
                    icon: const Icon(Icons.check),
                    label: const Text('Use Photo'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(240, 52),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}