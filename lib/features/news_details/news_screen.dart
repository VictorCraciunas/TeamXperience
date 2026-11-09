import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:teamxperience/ui/components/misc/app_svg_icon.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';

import '../../constants/routes.dart';
import '../../utils/calendar_helper.dart';
import '../../utils/link_util.dart';
import 'fullscreen_image_viewer.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  late bool isAdmin;
  late Stire stire;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      stire = arguments['stire'] as Stire;
      isAdmin = arguments['isAdmin'] as bool? ?? false;

      _initialized = true;
    }
  }

  void _navigateToEditStire(Stire stire) {
    Navigator.pushNamed(
      context,
      Routes.createNews,
      arguments: {'stire': stire},
    );
  }

  final LinkUtil _linkUtil = LinkUtil();

  List<String> _getAllImages(Stire stire) {
    List<String> allImages = [];

    // Add principal image first if it exists
    if (stire.principalImage != null && stire.principalImage!.isNotEmpty) {
      allImages.add(stire.principalImage!);
    }

    // Add secondary images
    if (stire.secondaryImages != null && stire.secondaryImages!.isNotEmpty) {
      allImages.addAll(stire.secondaryImages!);
    }

    return allImages;
  }

  void _openFullscreen(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => FullscreenImageViewer(
              images: images,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 317,
        width: double.infinity,
        color: context.colors.inset,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            color: context.colors.muted,
            size: 50,
          ),
        ),
      );
    }

    return SizedBox(
      height: 317,
      width: double.infinity,
      child: Stack(
        children: [
          // Image carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openFullscreen(images, index),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  progressIndicatorBuilder:
                      (context, url, progress) => Container(
                        color: context.colors.inset,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: context.colors.inset,
                        child: Center(
                          child: Icon(
                            Icons.error_outline,
                            color: context.colors.muted,
                            size: 50,
                          ),
                        ),
                      ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 317 * 0.3,
            // 40% of the carousel height
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.navy.withValues(alpha: 0),
                    context.colors.navy.withValues(alpha: .5),
                    context.colors.navy.withValues(alpha: .8),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: context.colors.panel.withValues(alpha: .56),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: AppSvgIcon(
                        'assets/images/back_icon.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: context.colors.panel.withValues(alpha: .56),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: AppSvgIcon(
                        'assets/images/download.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dots indicator overlay - positioned at bottom
          if (images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildDotsIndicator(images.length),
            ),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int imageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        imageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: _currentImageIndex == index ? 34.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color:
                _currentImageIndex == index
                    ? context.colors.onNavy
                    : context.colors.onNavy.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: [
              BoxShadow(
                color: context.colors.liveCard.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> allImages = _getAllImages(stire);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image carousel - Fixed height
            _buildImageCarousel(allImages),

            // Content area - Overlapping with negative margin
            Transform.translate(
              offset: const Offset(0, -30),
              // Move up by 30 pixels to create overlay
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.panel,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category and date container
                        Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: context.colors.iconButtonBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/images/folder-search.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  context.colors.text,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  stire.category?.name ?? 'No Category',
                                  // Now using NewsCategory name
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.colors.text,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'assets/images/punct.svg',
                                height: 3,
                                width: 3,
                                colorFilter: ColorFilter.mode(
                                  context.colors.text,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                CalendarHelper.formatDate(
                                  stire.publicationDate,
                                ),
                                // Now using NewsCategory name
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          stire.title ?? 'Fara titlu',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 21,
                            color: context.colors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          stire.description ?? "No description",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: context.colors.text,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (stire.buttonText != null)
                          AppButton(
                            label: stire.buttonText ?? "Vezi galeria foto",
                            onPressed: () {
                              _linkUtil.launchURL(stire.buttonLink, context);
                            },
                          ),

                        const SizedBox(height: 30),
                        if (isAdmin == true)
                          AppButton(
                            label: "Editează",
                            onPressed: () {
                              _navigateToEditStire(stire);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
