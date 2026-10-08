import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWithHeaders extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? errorWidget;

  const NetworkImageWithHeaders({
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      httpHeaders: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/91.0.4472.120 Mobile Safari/537.36',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        'Referer': 'https://sys.harvestcollege.co.uk/',
        'Origin': 'https://sys.harvestcollege.co.uk',
      },
      placeholder: (context, url) => Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            height: height,
            width: width,
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40)),
          ),
      fit: fit,
    );
  }
}
