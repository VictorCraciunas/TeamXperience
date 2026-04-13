class NotificationDTO{
  final String title;
  final String description;
  final String? eventId;

  NotificationDTO({required this.title, required this.description, this.eventId});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    if (eventId != null) 'eventId': eventId,
  };

}