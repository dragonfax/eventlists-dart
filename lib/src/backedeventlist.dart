import 'dart:async';
import 'eventlist.dart';
import 'listchangeevent.dart';

class BackedEventList<T> implements EventList<T> {

  BackedEventList() {
    onChange = _controller.stream;
  }

  List<T> _list = new List<T>();

  // get
  operator [](int i) => _list[i];

  // set
  operator []=(int i, T value) {
    _list[i] = value;
    _controller.add(new ListChangeEvent<T>(value != null,i,value));
  }

  @override
  forEach(void f(T Element)) {
    _list.forEach(f);
  }

  StreamController<ListChangeEvent<T>> _controller = new StreamController<ListChangeEvent<T>>();

  Stream<ListChangeEvent<T>> onChange;

  int get length => _list.length;
}

