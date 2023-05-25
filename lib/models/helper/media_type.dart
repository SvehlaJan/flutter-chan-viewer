enum MediaType {
  NONE,
  IMAGE,
  GIF,
  WEBM,
}

extension MediaTypeExtension on MediaType {
  bool isImage() => this == MediaType.IMAGE;

  bool isGif() => this == MediaType.GIF;

  bool isImageOrGif() => isImage() || isGif();

  bool isWebm() => this == MediaType.WEBM;

  bool hasMedia() => this != MediaType.NONE;
}
