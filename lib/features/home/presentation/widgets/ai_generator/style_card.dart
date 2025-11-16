import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../domain/entities/style.dart';

class StyleCard extends StatelessWidget {
  final Style style;
  final VoidCallback onTap;

  const StyleCard({
    super.key,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C28),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              child: CachedNetworkImage(
                imageUrl: style.previewImageUrl,
                width: 70.w,
                height: 70.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: Container(
                    width: 70.w,
                    height: 70.h,
                    color: Colors.grey[800],
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70.w,
                  height: 70.h,
                  color: Colors.grey[800],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                style.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
