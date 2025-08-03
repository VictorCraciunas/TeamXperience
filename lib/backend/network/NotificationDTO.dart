class NotificationDTO{
  final String title;
  final String description;

  NotificationDTO({required this.title, required this.description});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };

}