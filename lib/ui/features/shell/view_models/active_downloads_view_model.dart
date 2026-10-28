// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:openlib/app/di.dart';
import 'package:openlib/data/repositories/download_repository.dart';
import 'package:openlib/data/services/download_manager.dart';
import 'package:openlib/data/services/stream_throttle.dart';

/// Owns the in-flight download list shown by the home and search banners.
class ActiveDownloadsViewModel extends ChangeNotifier {
  ActiveDownloadsViewModel({required DownloadRepository downloads})
      : _downloads = downloads {
    // Seed from the manager so a page opened mid-download does not wait
    // for the next progress tick.
    _tasks = downloads.active.values.toList(growable: false);
    _subscription = throttleLatest(
      downloads.updates,
      const Duration(milliseconds: 100),
    ).listen(_onTasks);
  }

  factory ActiveDownloadsViewModel.fromDi() => ActiveDownloadsViewModel(
        downloads: getIt<DownloadRepository>(),
      );

  final DownloadRepository _downloads;

  StreamSubscription<Map<String, DownloadTask>>? _subscription;
  List<DownloadTask> _tasks = const [];
  bool _disposed = false;

  List<DownloadTask> get tasks => _tasks;

  Future<void> pause(String taskId) => _downloads.pause(taskId);

  Future<void> resume(String taskId) => _downloads.resume(taskId);

  void cancel(String taskId) => _downloads.cancel(taskId);

  Future<void> retry(String taskId) => _downloads.retry(taskId);

  Future<void> retryKeepingPartial(String taskId) =>
      _downloads.retryKeepingPartial(taskId);

  Future<void> restartWithMirrors(String taskId, List<String> mirrors) =>
      _downloads.restartWithMirrors(taskId, mirrors);

  void _onTasks(Map<String, DownloadTask> tasks) {
    _tasks = tasks.values.toList(growable: false);
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
