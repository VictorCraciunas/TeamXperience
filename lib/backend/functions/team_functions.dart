import 'package:cloud_functions/cloud_functions.dart';

/// The team callables, one method each. No logic: it sends the input and
/// returns the decoded answer. Failures surface as `FirebaseFunctionsException`.
class TeamFunctions {
  TeamFunctions({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> checkTeamName({
    required String eventId,
    required String name,
  }) {
    return _call('checkTeamName', {'eventId': eventId, 'name': name});
  }

  Future<Map<String, dynamic>> createCrew({required String name}) {
    return _call('createCrew', {'name': name});
  }

  Future<Map<String, dynamic>> registerTeam({
    required String eventId,
    required String name,
    required int size,
    required String phone,
    required bool rulesAccepted,
    required bool photoConsent,
    String? crewId,
  }) {
    return _call('registerTeam', {
      'eventId': eventId,
      'name': name,
      'size': size,
      'phone': phone,
      'rulesAccepted': rulesAccepted,
      'photoConsent': photoConsent,
      if (crewId != null) 'crewId': crewId,
    });
  }

  Future<Map<String, dynamic>> previewInvite({required String code}) {
    return _call('previewInvite', {'code': code});
  }

  Future<Map<String, dynamic>> joinTeam({required String code}) {
    return _call('joinTeam', {'code': code});
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> input,
  ) async {
    final result = await _functions.httpsCallable(name).call<Object?>(input);
    final data = result.data;
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}
