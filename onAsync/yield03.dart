Iterable<int> getRange(int start, int finish) sync* {
  if (start <= finish) {
    yield start;
    yield* getRange(start + 1, finish);
  }
}

void main() {
  getRange(1, 3).forEach(print);
}
