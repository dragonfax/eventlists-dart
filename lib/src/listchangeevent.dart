class ListChangeEvent<T> {

  int index;
  bool added; // else deleted
  T item;

  ListChangeEvent(this.added, this.index, this.item);

}
