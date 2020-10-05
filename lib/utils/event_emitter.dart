class Listener {
  final String eventName;
  final void Function([Object]) callback;

  Listener(this.eventName, this.callback);
}

class EventEmitter {
  final _listeners = <Listener>[];

  void addListener(String eventName, void Function([Object]) callback) {
    this._listeners.add(Listener(eventName, callback));
  }

  void removeListener(String eventName, void Function([Object]) callback) {
    this._listeners.removeWhere((l) => l.eventName == eventName && l.callback == callback);
  }

  void removeAllListeners([String eventName]) {
    this._listeners.removeWhere((l) => eventName == null || l.eventName == eventName);
  }

  void emit(String eventName, [Object data]) {
    this._listeners.where((l) => l.eventName == eventName).forEach((l) => l.callback(data));
  }
}
