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

  forEach(void f(T element));

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

  @override
  forEach(void f(T Element)) {
    _list.forEach(f);
  }

  StreamController<ListChangeEvent<T>> _controller = new StreamController<ListChangeEvent<T>>();

  Stream<ListChangeEvent<T>> onChange;

  int get length => _list.length;
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

  @override
  forEach(void f(T Element)) {
    _a.forEach(f);
    _b.forEach(f);
  }
}

class SortedEventList<T> implements EventList<T> {

  List<int> _indexList = new List<int>();

  EventList<T> _source;

  operator [](int i) => _source[_indexList[i]];

  Stream<ListChangeEvent<T>> onChange;

  Comparator<T> _comp;

  SortedEventList(this._source, this._comp) {

    onChange = _source.onChange.map((ListChangeEvent<T> e){
      int x = 0;
      int newIndex = 0;
      _indexList.forEach((int i) {
        if (i == e.index ) {
          newIndex = x;
        }
        x += 1;
      });
      return new ListChangeEvent(e.added, newIndex, e.item);
    });

    // Initialize as unsorted
    int index = 0;
    _source.forEach((e) {
      _indexList[index] = index;
      index += 1;
    });

    _sort();
  }

  int get length => _source.length;

  forEach(void f(T element)) {
    _source.forEach(f);
  }

  _sort() {
    _indexList.sort((int a, int b) {
      return _comp(_source[a], _source[b]);
    });
  }

}

