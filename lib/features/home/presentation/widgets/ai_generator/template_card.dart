import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../domain/entities/template.dart';

class TemplateCard extends StatelessWidget {
  final Template template;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: CachedNetworkImage(
          imageUrl: template.previewImageUrl,
          width: 118.w,
          height: 151.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              width: 118.w,
              height: 151.h,
              color: Colors.grey[800],
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 118.w,
            height: 151.h,
            color: Colors.grey[800],
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
