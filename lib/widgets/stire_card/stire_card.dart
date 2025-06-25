import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:intl/intl.dart';

class StireCard extends StatelessWidget {
  final Stire stire;
  final VoidCallback? onTap;
  final bool isAdmin;
  final bool showBadge;

  StireCard({
    super.key,
    required this.stire,
    this.onTap,
    required this.isAdmin,
    required this.showBadge
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          children: [
            // Background Image
            stire.principalImage != null && stire.principalImage!.isNotEmpty
                ? CachedNetworkImage(
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              imageUrl: stire.principalImage!,
              fit: BoxFit.cover,
              cacheManager: ImageHelper.eventImageCache,
            )
                : Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.article,
                size: 50,
                color: Colors.grey,
              ),
            ),

            // Dark overlay for better text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 220 * 0.50, // 1/3 of the card height
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Blue containers overlay (right side only like EventImage)
            if(showBadge == true)
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Type badge
                  Container(
                    width: 78,
                    height: 20,
                    decoration: BoxDecoration(
                      color: MyColors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        (stire.type?.name ?? "PUBLIC").toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text overlay at bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Am publicat fotografiile de la evenimentul ${stire.title ?? 'Untitled'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      height: 1.2,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/calendar.svg',
                        height: 12,
                        width: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Evenimente - ${_formatDate(stire.publicationDate)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateFormat('dd MMM yyyy').format(date);
  }
}