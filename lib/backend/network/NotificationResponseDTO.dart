class NotificationDTOResponse{
  final bool success;
  final String message ;

  NotificationDTOResponse({required this.success, required this.message});

  factory NotificationDTOResponse.fromJson(Map<String, dynamic> json) {
    return NotificationDTOResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}