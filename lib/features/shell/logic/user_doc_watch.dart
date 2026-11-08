import 'dart:async';

import 'package:teamxperience/model/user.dart';

/// Follows the player's document while the shell is open, so Home's XP and
/// stats change when a game's results arrive, Profil opened or not.
class UserDocWatch {
  UserDocWatch(Stream<AppUser?> stream, void Function(AppUser fresh) onFresh) {
    _subscription = stream.listen(
      (fresh) {
        if (fresh != null) onFresh(fresh);
      },
      // A failed read only leaves the numbers as they were.
      onError: (Object _) {},
    );
  }

  late final StreamSubscription<AppUser?> _subscription;

  void cancel() => _subscription.cancel();
}
