Iterable<int> getRange(int start, int finish) sync* {
  for (int i = start; i <= finish; i++) {
    yield i; //yield키워드는 각 반복에서 값을 반환한다.
  }
}

void main() {
  getRange(1, 3).forEach(print);
}
