import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/enums/stire_type.dart';
import 'package:teamxperience/model/stire.dart';
import 'package:teamxperience/utils/image_helper.dart';
import 'package:intl/intl.dart';

import 'package:teamxperience/utils/calendar_helper.dart';

class StireCard extends StatelessWidget {
  final Stire stire;
  final VoidCallback? onTap;
  final bool isAdmin;
  final bool showBadge;

  const StireCard({
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
              height: 220 * 0.70, // 1/3 of the card height
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x0021305C),
                      Color(0xCC21305C),
                      Color(0xFF21305C),
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
                      color: stire.type == StireType.PUBLICA ? MyColors.lightBlue : const Color(0xFF0B2F63),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        (stire.type?.displayName ?? "PUBLICA").toUpperCase(),
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
                    '${stire.title ?? 'Untitled'}',
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
                        'assets/images/folder-search.svg',
                        height: 10,
                        width: 10,
                        colorFilter: const ColorFilter.mode(
                          Colors.white70,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stire.category?.name ?? 'Necategorizat',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/images/punct.svg',
                        height: 2,
                        width: 2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CalendarHelper.formatDate(stire.publicationDate),
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

}