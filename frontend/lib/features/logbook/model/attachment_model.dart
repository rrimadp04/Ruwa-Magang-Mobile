import 'dart:typed_data';

class AttachmentModel {
  const AttachmentModel({
    required this.name,
    this.url = '',
    this.bytes,
    this.isPhoto = true,
  });

  final String name;
  final String url;
  final Uint8List? bytes;
  final bool isPhoto;

  bool get hasLocalBytes => bytes != null && bytes!.isNotEmpty;
  bool get hasNetworkUrl => url.isNotEmpty;
}
