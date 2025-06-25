import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkUtil {
  Future<void> launchURL(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      // Show a message if URL is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No link available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Ensure URL has a scheme (http/https)
    String formattedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }

    final Uri uri = Uri.parse(formattedUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser
        );
      } else {
        // Show error message if URL cannot be launched
        if (context.mounted) { // Use context.mounted instead of just mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the link'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors
      if (context.mounted) { // Use context.mounted instead of just mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}