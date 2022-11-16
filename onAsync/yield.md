# [[Flutter] 플러터 async*/ yield / yield* 키워드](https://devmg.tistory.com/180)

플러터 Flutter 2021. 4. 25. 18:20

주로 bloc패턴에서 많이 사용 된다.
async* : async*는 제너레이터를 만든단 뜻. 제너레이터는 게으르게(lazily) 데이터 연산을 할 때 쓰인다. 게으르다는 건 미리 연산을 다 하는 게 아니라, 요청이 있을때까지는 연산 하는 걸 미루어 두었다가 필요할 때 처리하는 걸 뜻한다.
yield : return이랑 유사하다. return은 한번 리턴하면 함수가 종료되지만, yield는 종료되지 않는다. yield는 열린 채로 있어서 필요할 때 다른 연산을 할 수 있다.
yield Iterable 또는 Stream에서 값을 반환한다.
yield* Iterable 또는 Stream 함수를 재귀 적으로 호출하는 데 사용된다.
아래는 기본적인 예제

<컴파일 가능한 웹사이트>

dartpad.dev/embed-inline.html?id=15d5ef986238c97dbc14&ga_id=receiving_stream_events


```dart
import 'dart:async';

Future<int> sumStream(Stream<int> stream) async {
  
  var sum = 0;
  
  await for (var value in stream){
    print('sumStream >>>>>>>>>>>>>>>>  $value');
    sum += value;
  }

  return sum;
}

//비동기
//async*와 yield 키워드를 이용해서 비동기 함수로 만든다.
//이 함수는 for문을 이용해서 1부터 int형 매개변수 to로 전달받은 숫자까지 반복한다.
// return은 한 번 반환하면 함수가 끝나지만 yield는 반환 후에도 계속 함수를 유지한다.
// 이렇게 받은 yield값을 인자로 sumStream() 함수를 호출하면 이 값이 전달될 때마다 
// sum 변수에 누적해서 반환해준다.
Stream<int> countStream(int to) async* { // async*는 yield를 쓴다는 의미다.
  print('매개변수 to :  ${to}');
  //yield는 계속 to의 갯수만큼 1번씩 함수를 리턴한다.
  for (int i = 1; i <= to; i++){
    yield i;
    print('countStream의 yield');
  }  
  for (int i = 1; i <= to; i++){
    print('그냥 for문? ${i}');
  }
}

main() async {
  
  var stream = countStream(10);
  var sum = await sumStream(stream);  
  print('총합 >>>>>>>>>>>>>>>>>> ${sum}');
  
}
``` 

참고 사이트 software-creator.tistory.com/9

## 형태 1

다음은에서 start에서 finish 까지 계산하는 Iterable리턴하는 함수다.

```dart
Iterable<int> getRange(int start, int finish) sync* {
  for (int i = start; i <= finish; i++) {
    yield i; //yield키워드는 각 반복에서 값을 반환한다.
  }
}

void main() {
  getRange(1,3).forEach(print);
}
```

## 형태 2
이제 위의 함수를 재귀함수로 재구성 해보자. 외부에서는 여전히 이전과 동일한 작업을 수행한다.

```dart
//이것은 작동하지만 읽기가 어렵고 루프 때문에 그다지 효율적이지 않다.
Iterable<int> getRange(int start, int finish) sync* {
  if (start <= finish) {
    yield start;
    for (final val in getRange(start + 1, finish)) {
      yield val;
    }
  }
}

void main() {
  getRange(1,3).forEach(print);
}
```

## 형태 3
yield*( "yield star"라고 하기도함)로 바꿔보자

```dart
Iterable<int> getRange(int start, int finish) sync* {
  if (start <= finish) {
    yield start;
    yield* getRange(start + 1, finish);
  }
}

void main() {
  getRange(1,3).forEach(print);
}
```

여전히 재귀 적이지만 이제 더 읽기 쉽고 더 효율적이다.

<참조>
stackoverflow.com/questions/55776041/what-does-yield-keyword-do-in-flutter/55776106
stackoverflow.com/questions/57492517/difference-between-yield-and-yield-in-dart
flutteragency.com/what-is-yield-keyword-in-flutter/


# [[Dart] - async(async*) , yield(yield*)]((https://funncy.github.io/programming/2020/09/04/async-yield/))
04 Sep 2020 in Programming on Programming, Dart, Async, Yield, Async*, Yield*


보통 async는 비동기 함수에 붙는다.
그런데 코드를 보다 보면 async*을 확인 할 수 있다.
둘의 차이는 무엇일까?

## async
보통 Future와 같이 비동기 데이터가 들어올때 then 구문 보다 async/await 구문을 많이 쓴다.

```dart
void test() async {
	await Future.delayed(Duration(milliseconds: 1000));
	print("async/await");
}
```
⇒ 1초 후에 프린트 문이 동작한다 (await 대기)

## async*
async 와 똑같이 비동기지만 차이점은 Stream을 반환한다는 거다.

그래서 yield로 데이터를 반환할 수 있다. (Generator를 만든다)

```dart
Stream<int> foo() async* {
  for (int i = 0; i < 42; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}
```
⇒ 1 초마다 데이터를 내뱉는다. return이 아니라 yield로 데이터를 중간 중간 반환한다.

## yield
이제 yield에 대해서 알아보기 전에 먼저 Generators에 대해서 알아보자.
Generator는 Lazily Produce가 필요한 경우 사용한다고 공식 문서에 나와있다.
lazily Produce는 말그대로 중간 중간에 계속 데이터를 반환하는걸 말한다.
그리고 2가지 종류가 있다.
하나씩 예시를 봐보자

### Synchronous
```dart
Iterable<int> naturalsTo(int n) sync* {
  int k = 0;
  while (k < n) yield k++;
}
```

Iterable 객체를 반환하며 동기로 돌아간다.

### Asynchronous
```dart
Stream<int> asynchronousNaturalsTo(int n) async* {
  int k = 0;
  while (k < n) yield k++;
}
```

Stream 객체를 반환하며 비동기로 돌아간다.

## yield*
여기서 yield*의 다른점을 알아보자.

위와 같이 Generator를 만들어 동작 시킬 때 재귀 형식으로 반환하면 효율적일 때가 있다.

그때 사용한다.

```dart
Iterable<int> naturalsDownFrom(int n) sync* {
  if (n > 0) {
    yield n;
    yield* naturalsDownFrom(n - 1);
  }
}
```
이러면 yield 이후에 yield*에서 재귀로 다시 시작한다.


# [[Dart] Stream : async*, yield](https://nomad-programmer.tistory.com/258)
scii 2020. 10. 10. 19:58

아래의 코드를 보자.

```dart
// async*는 yield를 쓴다는 의미이다.
Stream<int> createStream(List<int> numbers) async* {
  for (int number in numbers) {
    // yield는 제너레이터를 만든다는 뜻이다.
    yield number;
  }
}

void main() {
  // 스트림 생성
  var numStream = createStream([1, 2, 3, 4, 5]);

  numStream.listen((int number) => print(number));
}
```

```
/* 결과

1
2
3
4
5

*/
```

스트림을 만드려면 async*와 yield를 써야 한다. 즉, 스트림 형식을 반환할때는 async* 키워드를 붙여야 한다.

async* : async*는 제너레이터를 만든다는 뜻이다. 제너레이터는 게으르게(lazily) 데이터 연산을 할 때 쓰인다. 게으르다는 것은 미리 연산을 다 하는 것이 아니라, 요청이 있을 때까지는 연산 하는 것을 미루어 두었다가 필요할 때 처리하는 것을 뜻한다.
yield : return이랑 유사하다. return은 한번 반환하면 함수가 종료되지만, yield는 열린 채로 존재하며 요청할 때 연산한다.