import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/networkimage-withheaders.dart';

class DynamicCertificateImage extends StatefulWidget {
  final String imageUrl;
  final String fallbackAsset;
  final double height;

  const DynamicCertificateImage({
    super.key,
    required this.imageUrl,
    this.fallbackAsset = 'assets/images/harvest-cert.png',
    this.height = 220,
  });

  @override
  State<DynamicCertificateImage> createState() =>
      _DynamicCertificateImageState();
}

class _DynamicCertificateImageState extends State<DynamicCertificateImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 1.04, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DynamicCertificateImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _fallback() {
    return Image.asset(
      widget.fallbackAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: widget.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = widget.imageUrl.isNotEmpty;

    return ClipRect(
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: SizedBox(
            width: double.infinity,
            height: widget.height,
            child: hasNetworkImage
                ? NetworkImageWithHeaders(
                    url: widget.imageUrl,
                    width: double.infinity,
                    height: widget.height,
                    fit: BoxFit.cover,
                    errorWidget: _fallback(),
                  )
                : _fallback(),
          ),
        ),
      ),
    );
  }
}
