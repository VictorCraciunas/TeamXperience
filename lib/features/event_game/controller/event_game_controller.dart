import 'package:flutter/cupertino.dart';
import 'package:teamxperience/model/event.dart';

class EventGameController{
  late Event event;
  late ImageProvider background;
  late BuildContext context;

  EventGameController(this.event,this.context){
    _initializeBackground();

  }

  void _initializeBackground() async{
    if (event.taskBackgroundImageUrl != null && event.taskBackgroundImageUrl!.isNotEmpty) {
      if (_isUrl(event.taskBackgroundImageUrl!)) {
        background = NetworkImage(event.taskBackgroundImageUrl!);
      } else {
        // Assuming it's a local file path
        background = AssetImage(event.taskBackgroundImageUrl!);
        // Or use FileImage if it's a file system path:
        // background = FileImage(File(event.taskBackgroundImageUrl!));
      }
    } else {
      // Fallback to a default background
      background = const AssetImage('assets/images/default_background.png');
    }
     precacheImage(background, context);

  }
  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

}