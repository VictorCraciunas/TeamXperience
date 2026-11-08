import 'package:teamxperience/service/event_service/upload_images.dart';

import '../../backend/repo/event_repo.dart';
import '../../exceptions/events_exceptions.dart';
import '../../model/event.dart';
import '../../model/user.dart';
import 'event_status_changes.dart';

class EventService {
  final EventRepo _eventRepo = EventRepo();
  final UploadImagesHelper _uploadImagesHelper = UploadImagesHelper();

  Future<List<Event>> getAllEvents() async {
    try {
      return await _eventRepo.getAllEvents();
    } catch (e) {
      throw EventServiceException('Failed to load events: $e');
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      // Upload images if needed
      event = await _uploadImagesHelper.uploadEventImages(event);

      // Update in repository
      await _eventRepo.createEvent(event);

      return event;
    } catch (e) {
      throw EventServiceException('Failed to update event: $e');
    }
  }

  /// Saves [event] as a draft, however little is filled in. Gives it an id the
  /// first time, uploads any local images and stamps the time.
  Future<Event> saveDraft(Event event, {int? wizardStep}) async {
    try {
      if (event.eventId.isEmpty) {
        event.eventId = await _eventRepo.getNewEventId();
      }
      event = asDraft(event, now: DateTime.now(), wizardStep: wizardStep);
      event = await _uploadImagesHelper.uploadEventImages(event);
      await _eventRepo.createEvent(event);
      return event;
    } catch (e) {
      throw EventServiceException('Failed to save draft: $e');
    }
  }

  /// Publishes [event]. Throws [EventNotPublishableException] if it is not
  /// complete; nothing is saved in that case.
  Future<Event> publishEvent(Event event) async {
    final ready = asPublished(event, now: DateTime.now());

    try {
      if (ready.eventId.isEmpty) {
        ready.eventId = await _eventRepo.getNewEventId();
      }
      final uploaded = await _uploadImagesHelper.uploadEventImages(ready);
      await _eventRepo.createEvent(uploaded);
      return uploaded;
    } catch (e) {
      throw EventServiceException('Failed to publish event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventRepo.deleteEvent(eventId);
    } catch (e) {
      throw EventServiceException('Failed to delete event: $e');
    }
  }

  Future<void> stopEvent(String eventId) async {
    try {
      await _eventRepo.stopEvent(eventId);
    } catch (e) {
      throw EventServiceException('Failed to stop event: $e');
    }
  }

  Stream<Event> streamEvent(String eventId) {
    return _eventRepo.streamEvent(eventId);
  }


  List<Event> registeredEventsFromUser(List<Event> allEvents, AppUser user){
    List<Event> registeredEvents = [];

    ///create a map for faster look
    Map<String, Event> eventMap = {
      for (Event event in allEvents) event.eventId: event
    };

    for(String eventId in user.registeredEventIds){
      Event? event = eventMap[eventId];
      if(event != null){
        registeredEvents.add(event);
      }
    }

    return registeredEvents;
  }


}