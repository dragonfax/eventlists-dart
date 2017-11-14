import 'dart:async';
import 'eventlist.dart';
import 'listchangeevent.dart';

typedef bool ListFilter<T>(T e);

// TODO FilterList should really listen to objects as well. as thats what the filter is based on.
//      SortedList  should do this as well.
class FilteredEventList<T> implements EventList<T> {

  EventList<T> _source;

  ListFilter<T> _filter;

  // cache the filter results.
  List<int> _indexList = new List<int>();

  Stream<ListChangeEvent<T>> onChange;

  FilteredEventList(this._source, this._filter) {

    onChange = _source.onChange.takeWhile((ListChangeEvent<T> e) {
      return _indexList.contains(e.index);
    }).map((ListChangeEvent<T> e) {

      // TODO: could be more efficient
      _updateFilter();

      // find the new index
      int newIndex = 0;
      for ( int i = 0; i < _indexList.length; i++ ) {
        if ( e.index == _indexList[i] ) {
          newIndex = i;
        }
      }

      return new ListChangeEvent(e.added,newIndex,e.item);
    });

    _updateFilter();
  }

  _updateFilter() {
    _indexList.clear();
    for (var i = 0; i < _source.length; i++ ) {
      if ( _filter(_source[i]) ) {
        _indexList.add(i);
      }
    }
  }

  operator [](int i ) => _source[_indexList[i]];

  @override
  forEach(void f(T e)) {
    _indexList.forEach((int i) {
      f(_source[i]);
    });
  }

  int get length => _indexList.length;

}
