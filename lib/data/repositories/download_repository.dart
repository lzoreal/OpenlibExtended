// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:openlib/data/services/download_manager.dart';

class DownloadRepository {
  DownloadRepository({DownloadManager? manager})
      : _manager = manager ?? DownloadManager();

  final DownloadManager _manager;

  Stream<Map<String, DownloadTask>> get updates => _manager.downloadsStream;

  Map<String, DownloadTask> get active => _manager.activeDownloads;

  Future<void> initialize() => _manager.initialize();

  void setLocale(Locale locale) => _manager.setLocale(locale);

  Future<void> add(DownloadTask task) => _manager.addDownload(task);

  Future<void> addWithMirrorUrl(DownloadTask task, String mirrorUrl) =>
      _manager.addDownloadWithMirrorUrl(task, mirrorUrl);

  Future<void> pause(String taskId) => _manager.pauseDownload(taskId);

  Future<void> resume(String taskId) => _manager.resumeDownload(taskId);

  Future<void> pauseAll() => _manager.pauseAll();

  Future<void> resumeAll() => _manager.resumeAll();

  Future<void> resumeInterrupted() => _manager.resumeInterruptedDownloads();

  Future<void> retry(String taskId) => _manager.retryDownload(taskId);

  Future<void> restartWithMirrors(String taskId, List<String> mirrors) =>
      _manager.restartDownloadWithMirrors(taskId, mirrors);

  Future<void> retryKeepingPartial(String taskId) =>
      _manager.retryDownloadKeepingPartial(taskId);

  void cancel(String taskId) => _manager.cancelDownload(taskId);

  void remove(String taskId) => _manager.removeDownload(taskId);
}
