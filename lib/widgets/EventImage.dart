import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/colors.dart';
import '../model/event.dart';

class EventImage extends StatelessWidget {
  const EventImage({
    super.key,
    required this.event,
    required CacheManager eventImageCache,
    required this.isAdmin,
    required this.height,
  }) : _eventImageCache = eventImageCache;

  final Event event;
  final CacheManager _eventImageCache;
  final bool isAdmin;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          event.landingImageUrl != null && event.landingImageUrl!.isNotEmpty
              ? CachedNetworkImage(
                imageBuilder:
                    (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                imageUrl: event.landingImageUrl!,
                fit: BoxFit.cover,
                cacheManager: _eventImageCache,
              )
              : Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.event, size: 50, color: Colors.grey),
              ),

          // Blue containers overlay
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isAdmin == true)
                  Container(
                    width: 78,
                    height: 20,
                    decoration: BoxDecoration(
                      color: MyColors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/user-group.svg',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 2.0),
                        const Text(
                          "5",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        const Text(
                          "(78 p.)",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  width: 78,
                  height: 20,
                  decoration: BoxDecoration(
                    color: MyColors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      (event.type?.name ?? "GRATUIT").toUpperCase(),
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
        ],
      ),
    );
  }
}
