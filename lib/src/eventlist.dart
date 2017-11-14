import 'dart:async';
import 'listchangeevent.dart';

abstract class EventList<T> {

  Stream<ListChangeEvent<T>> onChange;
  operator [](int i);
  int get length;

  forEach(void f(T element));

}
