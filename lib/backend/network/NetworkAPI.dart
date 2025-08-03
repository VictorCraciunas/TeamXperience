import 'dart:convert';

import 'package:teamxperience/backend/network/NotificationDTO.dart';
import 'package:teamxperience/backend/network/NotificationResponseDTO.dart';
import 'package:http/http.dart' as http;

class NetworkAPI{

  static Future<NotificationDTOResponse> sendNotification(NotificationDTO notificationDTO) async{
    String url = "https://sendnotification-calsp5xwla-uc.a.run.app";

    try{
      final response = await http.post(Uri.parse(url),headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },body: jsonEncode(notificationDTO.toJson()));

      if(response.statusCode == 200){
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return NotificationDTOResponse.fromJson(responseData);
      }
      else{
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return NotificationDTOResponse(success: false, message: responseData['message'] as String);
      }
    }catch(e){
      return NotificationDTOResponse(success: false, message: e.toString());
    }

  }


}