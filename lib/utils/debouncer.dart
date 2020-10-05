import 'dart:async';

class Debouncer {
  final Duration duration;
  Timer _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  call(Function action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
}
