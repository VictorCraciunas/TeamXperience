import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/widgets/my_button.dart';

import '../../constants/routes.dart';
import '../../utils/calendar_helper.dart';
import '../../utils/link_util.dart';

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

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 317,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
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
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                progressIndicatorBuilder: (context, url, progress) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(value: progress.progress),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 50,
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x0021305C),
                    Color(0x8021305C),
                    Color(0xCC21305C),
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
                        color: const Color(0x90FFFFFF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: SvgPicture.asset(
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
                        color: const Color(0x90FFFFFF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: SvgPicture.asset(
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
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MyPaddings.appHorizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category and date container
                        Container(
                          width: 205,
                          height: 24,
                          decoration: BoxDecoration(
                            color: MyColors.transparentLightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/images/folder-search.svg',
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF0B2F63),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                stire.category?.name ?? 'No Category',
                                // Now using NewsCategory name
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0B2F63),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgPicture.asset(
                                'assets/images/punct.svg',
                                height: 3,
                                width: 3,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF0B2F63),
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                CalendarHelper.formatDate(
                                  stire.publicationDate,
                                ),
                                // Now using NewsCategory name
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0B2F63),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Am publicat fotografiile de la evenimentul ${stire.title ?? 'Untitled'}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 19,
                            color: MyColors.blackColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          stire.description ?? "No description",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (stire.buttonText != null)
                          MyButton(
                            buttonText: stire.buttonText ?? "Vezi galeria foto",
                            textColor: MyColors.blackColor,
                            buttonOnTap: () {
                              _linkUtil.launchURL(stire.buttonLink, context);
                            },
                            withBorder: false,
                            buttonColor: MyColors.transparentLightBlue,
                            buttonTextSize: 15,
                            fontWeight: FontWeight.w400,
                          ),

                        const SizedBox(height: 30),
                        if (isAdmin == true)
                          MyButton(
                            buttonText: "Editeaza",
                            textColor: Colors.white,
                            buttonOnTap: () {
                              _navigateToEditStire(stire);
                            },
                            withBorder: false,
                            buttonTextSize: 16,
                            fontWeight: FontWeight.w600,
                            gradient: MyColors.myGradient,
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
