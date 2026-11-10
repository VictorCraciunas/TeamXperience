import 'dart:async';

/// The longest start-up waits for the logo, in case the animation never
/// plays (a missing asset): the intro itself takes under two seconds.
const introGateMax = Duration(seconds: 4);

/// Done when [intro] is, or after [introGateMax], whichever comes first.
Future<void> introGate(Future<void> intro) => intro.timeout(introGateMax, onTimeout: () {});
