import 'dart:async';
import 'package:async/async.dart' as async;
import 'eventlist.dart';
import 'listchangeevent.dart';

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