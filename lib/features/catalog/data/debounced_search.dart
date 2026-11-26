import 'dart:async';

import '../../../core/constants/app_constants.dart';

class DebouncedSearch<T> {
  DebouncedSearch({
    this.delay = const Duration(
      milliseconds: AppConstants.searchDebounceMilliseconds,
    ),
  });

  final Duration delay;
  Timer? _timer;
  Completer<T?>? _pending;
  int _generation = 0;

  Future<T?> run(Future<T> Function() operation) {
    cancel();
    final completer = Completer<T?>();
    _pending = completer;
    final generation = ++_generation;
    _timer = Timer(delay, () async {
      try {
        final result = await operation();
        if (generation == _generation && !completer.isCompleted) {
          completer.complete(result);
        }
        if (_pending == completer) {
          _pending = null;
        }
      } catch (error, stackTrace) {
        if (generation == _generation && !completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        if (_pending == completer) {
          _pending = null;
        }
      }
    });
    return completer.future;
  }

  void cancel() {
    ++_generation;
    _timer?.cancel();
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.complete(null);
    }
    _pending = null;
  }

  void dispose() => cancel();
}
