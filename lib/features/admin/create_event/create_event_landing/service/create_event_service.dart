
import '../../../../../backend/repo/component_repo.dart';
import '../../../../../backend/repo/event_repo.dart';
import '../../../../../enums/event_type.dart';
import '../../../../../model/event.dart';

class CreateEventService {
  ComponentRepo componentRepo = ComponentRepo();
  EventRepo eventRepo = EventRepo();

  Future<Event> createEvent(
      String eventId,
    String name,
    DateTime startTime,
    DateTime deadlineEnrollment,
    String location,
    String description,
    int nrMissions,
    EventType type,
    String landingImageUrl,
    String taskBackgroundImageUrl,
    String startCode,
  ) async {
    Event event = Event(
      eventId: eventId,
      name: name,
      startTime: startTime,
      deadlineEnrollment: deadlineEnrollment,
      location: location,
      description: description,
      nrMissions: nrMissions,
      type: type,
      landingImageUrl: landingImageUrl,
      taskBackgroundImageUrl: taskBackgroundImageUrl,
      startCode: startCode,
    );

    eventRepo.createEvent(event);
    return event;
  }

  Future<String> getEventId() async {
    return eventRepo.getNewEventId();
  }
}
