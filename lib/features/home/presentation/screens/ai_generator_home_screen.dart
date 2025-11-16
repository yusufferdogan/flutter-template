import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/ai_generator/category_filter_chips.dart';
import '../widgets/ai_generator/community_image_grid.dart';
import '../widgets/ai_generator/image_generator_card.dart';
import '../widgets/ai_generator/style_card.dart';
import '../widgets/ai_generator/template_card.dart';

class AIGeneratorHomeScreen extends StatefulWidget {
  const AIGeneratorHomeScreen({super.key});

  @override
  State<AIGeneratorHomeScreen> createState() => _AIGeneratorHomeScreenState();
}

class _AIGeneratorHomeScreenState extends State<AIGeneratorHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<HomeBloc>().add(const LoadTrendingStyles());
    context.read<HomeBloc>().add(const LoadTemplates());
    context.read<HomeBloc>().add(const LoadCommunityImages());
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(const RefreshHome());
    // Wait for data to load
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1825), Color(0xFF0F0E17)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Artifex AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: Colors.white,
                          onPressed: () {
                            // Navigate to notifications
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Image Generator Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ImageGeneratorCard(
                      onGenerateTap: () {
                        // TODO: Navigate to prompt screen
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // Try Trend Styles Section
                _buildSectionHeader('Try Trend Styles', onSeeAllTap: () {
                  // TODO: Navigate to all styles
                }),

                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.isLoadingStyles) {
                      return SliverToBoxAdapter(
                        child: _buildStylesShimmer(),
                      );
                    }

                    if (state.trendingStyles.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState('No trending styles available'),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 110.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: state.trendingStyles.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            final style = state.trendingStyles[index];
                            return StyleCard(
                              style: style,
                              onTap: () {
                                // TODO: Navigate to prompt with style
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // Image Template Section
                _buildSectionHeader('Image Template', onSeeAllTap: () {
                  // TODO: Navigate to all templates
                }),

                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.isLoadingTemplates) {
                      return SliverToBoxAdapter(
                        child: _buildTemplatesShimmer(),
                      );
                    }

                    if (state.templates.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState('No templates available'),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: 151.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: state.templates.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            final template = state.templates[index];
                            return TemplateCard(
                              template: template,
                              onTap: () {
                                // TODO: Navigate to prompt with template
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                // Get Inspired from Community Section
                _buildSectionHeader('Get Inspired from Community'),

                SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                // Category Filter Chips
                SliverToBoxAdapter(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      return CategoryFilterChips(
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (category) {
                          context
                              .read<HomeBloc>()
                              .add(FilterCommunityImages(category));
                        },
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                // Community Images Grid
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.isLoadingCommunity &&
                        state.communityImages.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildCommunityShimmer(),
                      );
                    }

                    if (state.communityImages.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState('No community images available'),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: CommunityImageGrid(
                        images: state.communityImages,
                        onImageTap: (image) {
                          // TODO: Navigate to image detail
                        },
                        onLoadMore: () {
                          context.read<HomeBloc>().add(
                                const LoadCommunityImages(loadMore: true),
                              );
                        },
                        isLoadingMore: state.isLoadingMore,
                        hasMore: state.hasMoreCommunityImages,
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAllTap}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onSeeAllTap != null)
              TextButton(
                onPressed: onSeeAllTap,
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: const Color(0xFF7C3AED),
                    fontSize: 14.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylesShimmer() {
    return SizedBox(
      height: 110.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return Container(
            width: 70.w,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplatesShimmer() {
    return SizedBox(
      height: 151.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 3,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return Container(
            width: 118.w,
            height: 151.h,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommunityShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
