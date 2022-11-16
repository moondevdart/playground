Iterable<int> getRange(int start, int finish) sync* {
  if (start <= finish) {
    yield start;
    for (final val in getRange(start + 1, finish)) {
      yield val;
    }
  }
}

void main() {
  getRange(1, 3).forEach(print);
}
