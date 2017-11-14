import 'dart:async';
import 'eventlist.dart';
import 'listchangeevent.dart';

class SortedEventList<T> implements EventList<T> {

  List<int> _indexList = new List<int>();

  EventList<T> _source;

  operator [](int i) => _source[_indexList[i]];

  Stream<ListChangeEvent<T>> onChange;

  Comparator<T> _comp;

  SortedEventList(this._source, this._comp) {

    onChange = _source.onChange.map((ListChangeEvent<T> e){

      // re-sort
      // TODO: this could be done more efficiently
      _sort();

      // detect the translated index for the sorted item (even if it didnt' move).
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