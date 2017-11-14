import 'dart:async';
import 'package:async/async.dart' as async;


class ListChangeEvent<T> {

  int index;
  bool added; // else deleted
  T item;

  ListChangeEvent(this.added, this.index, this.item);

}

abstract class EventList<T> {

  Stream<ListChangeEvent<T>> onChange;
  operator [](int i);
  int get length;

}

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
    _controller.add(new ListChangeEvent<T>(true,i,value));
  }

  StreamController<ListChangeEvent<T>> _controller = new StreamController<ListChangeEvent<T>>();

  Stream<ListChangeEvent<T>> onChange;

  int get length => _list.length;
}

class SortedEventList<T> {

}

class ConcatenatedEventList<T> implements EventList {

  EventList<T> _a;
  EventList<T> _b;
  async.StreamGroup<ListChangeEvent<T>> _sg;

  ConcatenatedEventList(this._a, this._b) {
    _sg = new async.StreamGroup.broadcast();
    _sg.add(_a.onChange);
    _sg.add(_b.onChange.map((ListChangeEvent<T> inEvent){
      return new ListChangeEvent(inEvent.added,inEvent.index + _a.length,inEvent.item);
    }));

    onChange = _sg.stream;
  }

  operator [](int i) {
    if ( i < _a.length ) {
      return _a[i];
    } else {
      return _b[i - _a.length ];
    }
  }

  int get length => _a.length + _b.length;

  Stream<ListChangeEvent<T>> onChange;
}
