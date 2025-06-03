
import '../../../../../backend/repo/event_repo.dart';
import '../../../../../enums/event_type.dart';
import '../../../../../model/event.dart';

class CreateEventService {
  EventRepo eventRepo = EventRepo();

  Event createEvent(
      String eventId,
    String name,
    DateTime startTime,
    DateTime deadlineEnrollment,
      DateTime startEnrollment,
    String location,
    String description,
    EventType type,
    String landingImageUrl,
    String taskBackgroundImageUrl,
    String startCode,
  )  {
    Event event = Event(
      eventId: eventId,
      name: name,
      dateEvent: startTime,
      dateDeadlineEnrollment: deadlineEnrollment,
      dateStartEnrollment: startEnrollment,
      location: location,
      description: description,
      type: type,
      landingImageUrl: landingImageUrl,
      taskBackgroundImageUrl: taskBackgroundImageUrl,
      startCode: startCode,
    );

    return event;
  }

  Future<String> getEventId() async {
    return eventRepo.getNewEventId();
  }
}
