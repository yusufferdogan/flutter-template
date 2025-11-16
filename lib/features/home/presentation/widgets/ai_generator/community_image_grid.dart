import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../domain/entities/community_image.dart';

class CommunityImageGrid extends StatefulWidget {
  final List<CommunityImage> images;
  final Function(CommunityImage) onImageTap;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const CommunityImageGrid({
    super.key,
    required this.images,
    required this.onImageTap,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  State<CommunityImageGrid> createState() => _CommunityImageGridState();
}

class _CommunityImageGridState extends State<CommunityImageGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!widget.isLoadingMore && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.images.length + (widget.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.images.length) {
          return _buildShimmerPlaceholder();
        }

        final image = widget.images[index];
        return GestureDetector(
          onTap: () => widget.onImageTap(image),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildShimmerPlaceholder(),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
