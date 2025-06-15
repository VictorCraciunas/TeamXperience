import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:teamxperience/constants/colors.dart';
import '../../../model/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool isAdmin;

  const EventCard({super.key, required this.event, this.onTap, required this.isAdmin});

  static final CacheManager _eventImageCache = CacheManager(
    Config(
      'eventImagesCache',
      maxNrOfCacheObjects: 200, // Increased for better caching
      stalePeriod: const Duration(days: 30),
      // Optional: Add repo for better performance
      repo: JsonCacheInfoRepository(databaseName: 'eventImagesCache'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    String month = 'Ianuarie'; // Default fallback
    String day = '01'; // Default fallback
    if (event.dateEvent != null) {
      month = DateTime.now().month == event.dateEvent!.month
          ? 'Iunie' // Hardcoded to Romanian "June" for June 10, 2025 context
          : DateFormat('MMMM').format(event.dateEvent!);
      day = event.dateEvent!.day.toString().padLeft(2, '0');
    }

    // Convert month to Romanian (manual mapping)
    Map<String, String> monthMap = {
      'January': 'Ianuarie',
      'February': 'Februarie',
      'March': 'Martie',
      'April': 'Aprilie',
      'May': 'Mai',
      'June': 'Iunie',
      'July': 'Iulie',
      'August': 'August',
      'September': 'Septembrie',
      'October': 'Octombrie',
      'November': 'Noiembrie',
      'December': 'Decembrie',
    };
    String romanianMonth = monthMap[month] ?? month;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Stack
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 175,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Background Image
                    event.landingImageUrl != null &&
                        event.landingImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                      imageBuilder: (context, imageProvider) => Container(
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
                      child: const Icon(
                        Icons.event,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),

                    // Blue containers overlay
                    Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(isAdmin == true)
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
                                const SizedBox(width: 2.0,),
                                const Text("5", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,color: Colors.white),),
                                const SizedBox(width: 2.0,),
                                const Text("(78 p.)", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500,color: Colors.white),),

                              ],

                            )
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 78,
                            height: 20,
                            decoration: BoxDecoration(
                              color: MyColors.lightBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:  Center(
                              child: Text(
                                (event.type?.name ?? "PUBLIC").toUpperCase(),
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
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 63,
                    decoration: BoxDecoration(
                      color: const Color(0x2453C4C7),
                      borderRadius: BorderRadius.circular(10), // Apply custom radius
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(romanianMonth,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 13, color: MyColors.blackColor),),
                        Text(day,style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 15,color: MyColors.blackColor),),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/location.svg',
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(width: 8,),
                            Text(event.location ?? "No Location", style: const TextStyle(fontSize: 13,color: Color(0xFF545454)),)
                          ],
                        ),
                        const SizedBox(width: 8,),
                        Text(event.name ?? "No Title",style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: MyColors.blackColor),)
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15,)
          ],
        ),
      ),
    );
  }

  static Future<void> preloadImage(String imageUrl) async {
    try {
      await _eventImageCache.downloadFile(imageUrl);
    } catch (e) {
      // Handle preload errors silently
      debugPrint('Failed to preload image: $imageUrl');
    }
  }
}