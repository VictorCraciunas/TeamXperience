import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../model/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child:
                    event.landingImageUrl != null &&
                            event.landingImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: event.landingImageUrl!,
                          fit: BoxFit.cover,
                      cacheManager: _eventImageCache,
                        )
                        : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.event,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    event.name ?? 'Untitled Event',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // // Event Description
                  // if (event.description != null && event.description!.isNotEmpty)
                  //   Text(
                  //     event.description!,
                  //     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //       color: Colors.grey[600],
                  //     ),
                  //     maxLines: 3,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  //
                  // const SizedBox(height: 12),
                  //
                  // // Event Info Row
                  // Row(
                  //   children: [
                  //     // Date
                  //     if (event.dateEvent != null) ...[
                  //       Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  //       const SizedBox(width: 4),
                  //       Text(
                  //         _formatDate(event.dateEvent!),
                  //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //           color: Colors.grey[600],
                  //         ),
                  //       ),
                  //       const SizedBox(width: 16),
                  //     ],
                  //
                  //     // Location
                  //     if (event.location != null && event.location!.isNotEmpty) ...[
                  //       Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  //       const SizedBox(width: 4),
                  //       Expanded(
                  //         child: Text(
                  //           event.location!,
                  //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //             color: Colors.grey[600],
                  //           ),
                  //           overflow: TextOverflow.ellipsis,
                  //         ),
                  //       ),
                  //     ],
                  //   ],
                  // ),
                  //
                  // const SizedBox(height: 8),

                  // Missions Count
                  // Row(
                  //   children: [
                  //     Icon(Icons.task_alt, size: 16, color: Colors.grey[600]),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '${event.nrMissions} missions',
                  //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //         color: Colors.grey[600],
                  //       ),
                  //     ),
                  //
                  //     const Spacer(),
                  //
                  //     // Event Type Badge
                  //     if (event.type != null)
                  //       Container(
                  //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //         decoration: BoxDecoration(
                  //           color: _getTypeColor(event.type!),
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: Text(
                  //           event.type!.name.toUpperCase(),
                  //           style: const TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 10,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //       ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
