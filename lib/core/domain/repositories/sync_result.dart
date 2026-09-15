class SyncResult {
  final int succeeded;
  final int failed;
  const SyncResult({required this.succeeded, required this.failed});
}

const noSyncResult = SyncResult(succeeded: 0, failed: 0);