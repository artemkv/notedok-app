import 'package:flutter/material.dart';

// Key to this implementation is to remember that
// - preloadContent simply initiates a download
// - getContent is the one that waits and unpacks the result
// And once the result is unpacked, we either store the value or,
// if we receive an error, we forget it

// TODO: next step is to test with actual errors

@immutable
class PreloadResult<T> {
  final bool hasResult;
  // Can only be looked at many times
  final T? value;
  // Can only be looked at once, and then either convert to result or be removed
  final Future<T>? pendingRetrieve;

  const PreloadResult(this.hasResult, this.value, this.pendingRetrieve);
}

class Preloader {
  Map<String, PreloadResult<String>> _results =
      <String, PreloadResult<String>>{};

  preloadContent(String fileName, Future<String> Function() retrieve) {
    if (_results.containsKey(fileName)) {
      return;
    }

    var pendingRetrieve = retrieve();
    _results[fileName] = PreloadResult(false, null, pendingRetrieve);
  }

  Future<String> getContent(
    String fileName,
    Future<String> Function() retrieve,
  ) async {
    if (_results.containsKey(fileName)) {
      PreloadResult<String> result = _results[fileName]!;
      if (result.hasResult) {
        return Future.value(result.value);
      } else {
        return _completePendingRetrieve(fileName, result.pendingRetrieve!);
      }
    }

    var pendingRetrieve = retrieve();
    _results[fileName] = PreloadResult(false, null, pendingRetrieve);
    return _completePendingRetrieve(fileName, pendingRetrieve);
  }

  dropPreload(String fileName) {
    _results.remove(fileName);
  }

  clean() {
    _results = <String, PreloadResult<String>>{};
  }

  Future<String> _completePendingRetrieve(
    String fileName,
    Future<String> pendingRetrieve,
  ) async {
    try {
      String content = await pendingRetrieve;
      _results[fileName] = PreloadResult(true, content, null);
      return Future.value(content);
    } catch (err) {
      _results.remove(fileName);
      return Future.error(err);
    }
  }
}
