// Dart imports:
import 'dart:async';

/// Coalesces bursts: the first value after a quiet period passes through
/// immediately, later values are held, and only the latest one is emitted
/// when the window closes. Progress UI needs a steady rate, not one event
/// per network chunk; the trailing flush keeps the final state accurate.
Stream<T> throttleLatest<T>(Stream<T> source, Duration interval) {
  late StreamController<T> controller;
  StreamSubscription<T>? subscription;
  Timer? window;
  T? pending;
  bool hasPending = false;
  bool sourceDone = false;

  void close() {
    if (!controller.isClosed) controller.close();
  }

  void flush() {
    window = null;
    if (hasPending) {
      hasPending = false;
      controller.add(pending as T);
      pending = null;
    }
    if (sourceDone) close();
  }

  controller = StreamController<T>(
    onListen: () {
      subscription = source.listen(
        (value) {
          if (window == null) {
            controller.add(value);
            window = Timer(interval, flush);
          } else {
            pending = value;
            hasPending = true;
          }
        },
        onError: controller.addError,
        onDone: () {
          sourceDone = true;
          if (window == null) close();
        },
      );
    },
    onCancel: () async {
      window?.cancel();
      window = null;
      await subscription?.cancel();
      close();
    },
  );
  return controller.stream;
}
