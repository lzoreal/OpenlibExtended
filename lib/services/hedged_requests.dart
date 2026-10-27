// Dart imports:
import 'dart:async';

/// Runs up to [window] attempts with [stagger] between launches and
/// resolves with the first non-null result.
///
/// Detail pages used to try mirrors strictly one after another, so one
/// dead mirror cost the page its full connect timeout before the next
/// was even asked. Launching a second mirror shortly after the first
/// keeps the page bound to the fastest usable mirror instead.
Future<T?> hedgeFirst<T>(
  List<Future<T?> Function()> attempts, {
  Duration stagger = const Duration(milliseconds: 600),
  int window = 2,
}) {
  if (attempts.isEmpty) return Future<T?>.value(null);

  final completer = Completer<T?>();
  final pendingTimers = <Timer>[];
  final launched = attempts.take(window).toList();
  var remaining = launched.length;

  void settle(T? value) {
    remaining--;
    if (completer.isCompleted) return;
    if (value != null) {
      completer.complete(value);
      return;
    }
    if (remaining == 0) completer.complete(null);
  }

  for (var index = 0; index < launched.length; index++) {
    final attempt = launched[index];
    void run() {
      Future<T?> future;
      try {
        future = attempt();
      } catch (_) {
        settle(null);
        return;
      }
      future.then<void>(settle, onError: (Object _) => settle(null));
    }

    if (index == 0) {
      run();
    } else {
      pendingTimers.add(Timer(stagger * index, run));
    }
  }

  return completer.future.whenComplete(() {
    for (final timer in pendingTimers) {
      timer.cancel();
    }
  });
}
