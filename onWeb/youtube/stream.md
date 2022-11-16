# [Dart 언어 Stream 알아보기(Dart 비동기 프로그래밍)](https://beomseok95.tistory.com/308)
by 봄석 2019. 11. 25.

Dart 언어의 Stream에 대하여 알아보겠습니다.

## Stream 이란??
스트림은 데이터나 이벤트가 들어오는 통로입니다.

앱을 만들다 보면 데이터를 처리할 일이 많은데, 어느 타이밍에 데이터가 들어올지 확실히 알기 어렵습니다. 

스트림은 이와 같은 비동기 작업을 할 때 주로 쓰인다.

예컨대 네트워크에서 데이터를 받아서 UI에 보여주는 상황을 생각해보면,

언제 네트워크에서 데이터를 다 받을지 알기 어렵습니다. 신호가 약한 와이파이를 쓸 수도 있고, 빵빵한 통신을 쓰고 있을 수도 있다.

이런 문제를 스트림은 데이터를 만드는 곳과 소비하는 곳을 따로 둬서 이 문제를 해결할 수 있습니다.

스트림이란 데이터의 추가나 변경이 일어나면 이를 관찰하던데서 처리하는 방법입니다. (옵서버 패턴입니다)

## Future와 다른 점은?
Dart의 비동기 프로그래밍은 Future 및 Stream 클래스로 주로 처리합니다.

Future는  즉시 완료되지 않는 계산을 나타냅니다. 일반 함수가 결과를 반환하는 경우 비동기 함수는 Future를 반환하며 결과에 포함됩니다. 결과가 준비되면 Future에 알려주는 것입니다.

스트림은 일련의 비동기 이벤트입니다. 

요청 시 다음 이벤트를 받는 대신 스트림이 준비되면 이벤트가 있음을 알려주는 비동기 Iterable과 같습니다.

## 스트림 이벤트 수신
스트림은 여러 가지 방법으로 만들 수 있습니다.

비동기 for 루프 (일반적으로 await for라고 함 )는 for 루프 반복과 같은 스트림 이벤트를 반복합니다. 

Iterable을 통해. 예를 들면 다음과 같습니다.

```dart
Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (var value in stream) {
    sum += value;
  }
  return sum;
}
```

이 코드는 단순히 정수 이벤트 스트림의 각 이벤트를 수신하여 더한 다음 합계를 반환합니다. 
루프 본문이 끝나면 다음 이벤트가 도착하거나 스트림이 완료될 때까지 기능이 일시 중지됩니다.

이 함수 async에는 await for 루프를 사용할 때 필요한 키워드가 표시되어 있습니다.

아래의 예는 async*함수를 사용하여 간단한 정수 스트림을 생성하여 이전 코드를 테스트합니다.

```dart
Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (var value in stream) {
    sum += value;
  }
  return sum;
}

Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    yield i;
  }
}

main() async {
  var stream = countStream(10);
  var sum = await sumStream(stream);
  print(sum); // 55
}
```

## 오류 이벤트
스트림은 더 이상 이벤트가 없을 때 수행되며, 

이벤트를 수신하는 코드는 새 이벤트가 도착했다는 알림을 받는 것처럼 이를 알립니다. 

Await for 루프를 사용하여 이벤트를 읽을 때 스트림이 완료되면 루프가 중지됩니다.

어떤 경우에는 스트림이 완료되기 전에 오류가 발생합니다.

원격 서버에서 파일을 가져오는 중에 네트워크에 장애가 발생했거나

이벤트를 생성하는 코드에 버그가 있을 수 있지만 누군가가 알아야 합니다.

스트림은 데이터 이벤트를 전달하는 것처럼 오류 이벤트를 전달할 수도 있습니다. 

대부분의 스트림은 첫 번째 오류 후에 중지되지만 둘 이상의 오류를 전달하는 스트림과 오류 이벤트 후에 더 많은 데이터를 전달하는 스트림을 가질 수 있습니다. 이 문서에서는 최대 하나의 오류를 발생시키는 스트림 만 설명합니다.

await for를 사용하여 스트림을 읽을 때 루프 문에 의해 오류가 발생합니다. 

이것도 루프를 종료합니다. try-catch를 사용하여 오류를 잡을 수 있습니다.

아래 예제는 루프 반복기가 4 일 때 오류를 발생시킵니다

```dart
import 'dart:async';

Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  try {
    await for (var value in stream) {
      sum += value;
    }
  } catch (e) {
    return -1;
  }
  return sum;
}

Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    if (i == 4) {
      throw new Exception('Intentional exception');
    } else {
      yield i;
    }
  }
}

main() async {
  var stream = countStream(10);
  var sum = await sumStream(stream);
  print(sum); // -1
}
```

## 스트림 작업
Stream 클래스에는 Iterable의 메서드와 유사하게 스트림에서 

일반적인 작업을 수행할 수 있는 여러 가지 도우미 메서드가 포함되어 있습니다.  

예를 들어 lastWhere() Stream API를 사용하여 스트림에서 마지막 양의 정수를 찾을 수 있습니다.

```dart
Future<int> lastPositive(Stream<int> stream) => stream.lastWhere((x) => x >= 0);
```

## 두 종류의 스트림
두 종류의 스트림이 있습니다.

### 단일 구독 스트림(Single subscription streams)
가장 일반적인 종류의 스트림에는 더 큰 전체의 일부인 일련의 이벤트가 포함됩니다. 

이벤트는 올바른 순서로 누락 없이 전달되어야 합니다. 

파일을 읽거나 웹 요청을 받을 때 얻는 스트림입니다.

이러한 스트림은 한 번만들을 수 있습니다. 

나중에 다시 듣는 것은 초기 이벤트가 누락되었음을 의미할 수 있으며 나머지 스트림은 의미가 없습니다. 

청취를 시작하면 데이터가 페치 되어 청크로 제공됩니다.

### 방송 스트림(Broadcas streams)
다른 종류의 스트림은 한 번에 하나씩 처리할 수 있는 개별 메시지를 위한 것입니다. 

이러한 종류의 스트림은 예를 들어 브라우저에서 마우스 이벤트에 사용될 수 있습니다.

언제든지 이러한 스트림 청취를 시작할 수 있으며 청취하는 동안 발생하는 이벤트가 발생합니다. 

둘 이상의 리스너가 동시에 들을 수 있으며, 이전 구독을 취소한 후 나중에 다시들을 수 있습니다.

## 스트림을 처리하는 메서드
Stream <T>의 다음 메서드는 스트림을 처리하고 결과를 리턴합니다.

```dart
Future<T> get first;
Future<bool> get isEmpty;
Future<T> get last;
Future<int> get length;
Future<T> get single;
Future<bool> any(bool Function(T element) test);
Future<bool> contains(Object needle);
Future<E> drain<E>([E futureValue]);
Future<T> elementAt(int index);
Future<bool> every(bool Function(T element) test);
Future<T> firstWhere(bool Function(T element) test, {T Function() orElse});
Future<S> fold<S>(S initialValue, S Function(S previous, T element) combine);
Future forEach(void Function(T element) action);
Future<String> join([String separator = ""]);
Future<T> lastWhere(bool Function(T element) test, {T Function() orElse});
Future pipe(StreamConsumer<T> streamConsumer);
Future<T> reduce(T Function(T previous, T element) combine);
Future<T> singleWhere(bool Function(T element) test, {T Function() orElse});
Future<List<T>> toList();
Future<Set<T>> toSet();
```

이러한 모든 기능은 제외 drain()하고 pipe()에 유사한 기능입니다.

await for 루프가 있는 async함수를 사용하거나 다른 방법 중 하나를 사용하여 쉽게 작성할 수 있습니다.

예를 들어 일부 구현은 다음과 같습니다.

```dart
Future<bool> contains(Object needle) async {
  await for (var event in this) {
    if (event == needle) return true;
  }
  return false;
}

Future forEach(void Function(T element) action) async {
  await for (var event in this) {
    action(event);
  }
}

Future<List<T>> toList() async {
  final result = <T>[];
  await this.forEach(result.add);
  return result;
}

Future<String> join([String separator = ""]) async =>
    (await this.toList()).join(separator);
```

## 스트림을 수정하는 메서드
Stream의 다음 메서드는 원래 스트림을 기반으로 새 스트림을 반환합니다. 

각각은 누군가가 원본을 듣기 전에 새로운 스트림을 들을 때까지 기다립니다.

```dart
Stream<R> cast<R>();
Stream<S> expand<S>(Iterable<S> Function(T element) convert);
Stream<S> map<S>(S Function(T event) convert);
Stream<T> skip(int count);
Stream<T> skipWhile(bool Function(T element) test);
Stream<T> take(int count);
Stream<T> takeWhile(bool Function(T element) test);
Stream<T> where(bool Function(T event) test);
```

앞의 방법은 Iterable을 다른 iterable로 변환하는 Iterable의 유사한 방법에 해당합니다. 

이들 모두 async는 await for 루프가 있는 함수를 사용하여 쉽게 작성할 수 있습니다.

```dart
Stream<E> asyncExpand<E>(Stream<E> Function(T event) convert);
Stream<E> asyncMap<E>(FutureOr<E> Function(T event) convert);
Stream<T> distinct([bool Function(T previous, T next) equals]);
```

asyncExpand()및 asyncMap()기능과 유사 expand()하고 map()있지만, 그 기능의 인수가 비동기 함수가 될 수 있습니다. 이 distinct()함수는에 존재하지 않지만 Iterable가질 수 있습니다.

```dart
Stream<T> handleError(Function onError, {bool test(error)});
Stream<T> timeout(Duration timeLimit,
    {void Function(EventSink<T> sink) onTimeout});
Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer);
```

마지막 세 가지 기능이 더 특별합니다. 여기에는 await for 루프가 수행할 수 없는오류 처리가 포함됩니다.

루프에 도달하는 첫 번째 오류는 루프와 스트림에서 구독을 종료합니다. 

그로부터 회복되지 않습니다. await for 루프 handleError()에서 사용하기 전에 스트림에서 오류를 제거하는데 사용할 수 있습니다.

### transform () 함수

이 transform()기능은 오류 처리만을 위한 것이 아닙니다. 스트림에 대해보다 일반화된 "맵"입니다.

map에는 들어오는 각 이벤트마다 하나의 값이 필요합니다. 

그러나 특히 I / O 스트림의 경우 출력 이벤트를 생성하기 위해 여러 개의 수신 이벤트가 필요할 수 있습니다.

StreamTransformer는 그와 함께 작업할 수 있습니다. 예를 들어 Utf8Decoder 와 같은 디코더는 변환기입니다. 

변환기에는 하나의 함수 bind ()만 있으면 함수로 쉽게 구현할 수 있습니다 async.

```dart
Stream<S> mapLogErrors<S, T>(
  Stream<T> stream,
  S Function(T event) convert,
) async* {
  var streamWithoutErrors = stream.handleError((e) => log(e));
  await for (var event in streamWithoutErrors) {
    yield convert(event);
  }
}
```

### 파일 읽기 및 디코딩

다음 코드는 파일을 읽고 스트림에서 두 가지 변환을 실행합니다. 먼저 UTF8에서 데이터를 변환 한 다음  LineSplitter를 통해 실행합니다.  해시 태그로 시작하는 행을 제외한 모든 행이 인쇄됩니다 #.

```dart
Future<void> read(List<String> args) async {
  var file = File(args[0]);
  var lines = utf8.decoder
      .bind(file.openRead())
      .transform(LineSplitter());
  await for (var line in lines) {
    if (!line.startsWith('#')) print(line);
  }
}
```

### listen () 메서드

Stream의 마지막 방법은 listen()입니다.

StreamSubscription<T> listen(void Function(T event) onData,
    {Function onError, void Function() onDone, bool cancelOnError});

새 Stream유형 을 만들려면 Stream 클래스를 확장 하고 listen()메서드를 구현하면 됩니다.

다른 모든 메서드는 작동하기 위해 Stream호출 listen()합니다.

이 listen()방법을 사용하면 스트림 청취를 시작할 수 있습니다.

 그렇게 할 때까지 스트림은 보고 싶은 이벤트를 설명하는 비활성 객체입니다. 

수신하면 활성 스트림 생성 이벤트를 나타내는 StreamSubscription 객체가 반환됩니다.

이것은 Iterable객체의 수집 방법과 유사 하지만 반복자는 실제 반복을 수행하는 방법과 유사합니다.

스트림 구독을 사용하면 구독을 일시 중지하고 일시 중지 후 다시 시작한 후 완전히 취소할 수 있습니다. 각 데이터 이벤트 또는 오류 이벤트와 스트림이 닫힐 때 콜백을 호출하도록 설정할 수 있습니다.

## Example

### ex1) stream생성, listen

```dart
void ex1() {
   var stream = Stream.periodic(Duration(seconds: 1), (x) => x).take(10); 
   // 1. 스트림 만들기 - 1초마다 데이터를 1개씩 만듭니다, 10개 까지만.
  stream.listen(print); // 2. 이벤트 처리
}
```

### ex2)  Stream.fromIterable, Stream.periodic, Stream.fromFuture

```dart
Future<String> getData() async {
  await Future.delayed(Duration(seconds: 5)); // 5초간 대기
  print("Fetched Data");
  return "5second later data";
}

void ex2() {
  Stream.fromIterable([1, 2, 3, 4, 5])
      .listen((int x) => print('iterable : ${x}')); //일반적인 데이터를 다룰때

  Stream.periodic(Duration(seconds: 1), (x) => x)
      .take(5)
      .listen((x) => print('take : $x'));

  Stream.fromFuture(getData()).listen((x) => print('from future : $x'));
}

/// 반복적인 작업을 하고 싶다면 Stream.periodic()
/// 비동기 처리를 한다면 Stream.fromFuture().
```


### ex3) Stream.frist , Stream.last , Stream.isEmpty, Stream.length , then
```dart
  var stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  stream.first.then((value) => print("stream.first:$value"));
  stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  stream.last.then((value) =>print("stream.last:$value"));
  stream = Stream.fromIterable([1,2,3,4,5]);
  stream.isEmpty.then((value) => print("stream.isEmpty:$value"));
  stream = Stream.fromIterable([10,20,30,40,50,60]);
  stream.length.then((value) => print("stream.length:$value"));
```

### ex4) map, transform
```dart
void transformer() {
  //Stream sink는 스트림 이벤트를 받아들이는 것이다.
  var transformer = StreamTransformer.fromHandlers(handleData: (value, sink) {
    sink.add("First : $value");
    sink.add("Second : $value");
  });
  var stream = Stream.fromIterable(["Good", 1, 2, 3, 4, 5]);
  stream.transform(transformer).listen((value) => print("listen : $value"));
}

void map() {
  var streamMap = Stream.periodic(Duration(milliseconds: 200), (x) => x)
      .take(3)
      .map((x) => x + 10);

  streamMap.listen(print);
}
```

### ex5) async* , yeild
```dart
Stream<int> createStream(List<int> numbers) async* {
  // async*는 yield를 쓴다는 의미다.
  for (var number in numbers) {
    yield number; // yield는 스트림 (비동기제너레이터)를 생성합니다.
  }
}

main() {
  var numStream = createStream([1, 3, 5, 7, 9]); // 스트림을 만듭니다.
  numStream.listen((int number) => print(number)); // 스트림으로부터 데이터를 받아서 출력 합니다.
}
```

async*와 yield가 어떤 뜻인지 알아보자.

async* : async*는 제너레이터를 만든단 뜻입니다. 제너레이터는 게으르게(lazily) 데이터 연산을 할 때 쓰인다. 게으르다는 건 미리 연산을 다 하는 게 아니라, 요청이 있을 때까지는 연산하는 걸 미루어 두었다가 필요할 때 처리하는 걸 뜻합니다.

.
yield : return이랑 유사합니다.  return은 한번 리턴하면 함수가 종료되지만, yield는 열린 채로 있어서 필요할 때 다른 연산을 할 수 있다.

### ex6) StreamSubscription , cancel()
```dart
main() {
  var streamIter = Stream.fromIterable([10, 20, 30, 40, 50]);
  StreamSubscription subscription =
      streamIter.listen((int number) => print(number));

  subscription.cancel(); // 연결 해제
}
```

### ex7) onData, onError, onDone 외부에 정의
```dart
 var stream = Stream.periodic(Duration(milliseconds: 200), (x) => x);
var subscription = stream.listen(null);
subscription.onData((value) => print("listen: $value"));
subscription.onError((err) => print("error: $err"));
subscription.onDone(() => print("done"));
```

Subscription은 새로운 이벤트가 생기거나, 에러가 생기면, StreamSubscription에서 이를 처리합니다. 뿐만 아니라 StreamSubscription은 이벤트 소스와의 연결도 끊어버릴 수 있습니다.

### ex8) listen 내부에  onData, onDone , onError 정의
```dart
  var stream = Stream.periodic(Duration(milliseconds: 200), (x) => x).take(10);
  var subscription = stream.listen((x) => print, onDone: () {
    print("on done");
  }, onError: (e, s) {
    print("on error");
  });
```

### ex9) StreamController.broadcast
```dart
var sc = StreamController.broadcast(); //
var broadcastStream = sc.stream;
var subscription = broadcastStream.listen(
    (value) => print("listen: $value"),
    onError: (err) => print("error: $err"),
    onDone: () => print("done"));
```
broadcast는 여러 번 리슨 할 경우 각각 데이터를 받아서 처리합니다. 

### ex10) Stream.controller
```dart
 final StreamController ctrl = StreamController();
  final StreamSubscription subscription =
      ctrl.stream.listen((data) => print(data)); // 데이터가 더해질때마다 print 한다.

  ctrl.add(10);
  ctrl.add(200);
  ctrl.add(300);

  ctrl.close();
  //final StreamSubscription subscription2 = ctrl.stream.listen((data) => print(data));
  // 에러발생! listen을 여러번 불가능합니다. 스트림을 브로드캐스트로 바꾸면 가능합니다..
//  ctrl.add(950); // 위에서 컨트롤러가 닫혔기에 출력되지 않습니다.
```
스트림을 매번 열었다가(listen) 닫는 것은 (cancel) 일일이 비효율적입니다.

여러 스트림을 관리하기 위해 StreamContoller를 사용합니다.

### ex11) Common Stream methods(take, skip, takeWhile, skipWhile, where)
take, skip, takeWhile, skipWhile, where 사용 예제입니다.
```dart
main() {
  final sc = StreamController.broadcast();
  final broadcastStream = sc.stream;

  broadcastStream
      .where((value) => value % 2 == 0) // divisible by 2
      .listen((value) => print("where: $value"));
  // where: 2
  // where: 4

  broadcastStream
      .take(3) // takes only the first three elements
      .listen((value) => print("take: $value"));
  // take: 1
  // take: 2
  // take: 3

  broadcastStream
      .skip(3) // skips the first three elements
      .listen((value) => print("skip: $value"));
  // skip: 4
  // skip: 5

  broadcastStream
      .takeWhile((value) => value < 3) // take while true
      .listen((value) => print("takeWhile: $value"));
  // takeWhile: 1
  // takeWhile: 2

  broadcastStream
      .skipWhile((value) => value < 3) // skip while true
      .listen((value) => print("skipWhile: $value"));
  // skipWhile: 3
  // skipWhile: 4
  // skipWhile: 5

  sc.add(1);
  sc.add(2);
  sc.add(3);
  sc.add(4);
  sc.add(5);
}
```

### ex12) Validating stream data ( any, every , contains)
any, every , contains를 통해 스트림 검증 예제입니다.
```dart
main() {
  final sc = StreamController.broadcast();
  final broadcastStream = sc.stream;
  broadcastStream
      .any((value) => value < 5)
      .then((result) => print("Any less than 5?: $result")); // true

  broadcastStream
      .every((value) => value < 5)
      .then((result) => print("All less than 5?: $result")); // false

  broadcastStream
      .contains(4)
      .then((result) => print("Contains 4?: $result")); // true

  sc.addStream(asynchronousNaturalsTo(5));
}

Stream<int> asynchronousNaturalsTo(int n) async* {
  int k = 0;
  while (k < n) yield k++;
}
```

### ex13) Single value streams
> 단일 값 스트림 예제

단일 값이 아니라면  Bad state: Too many elements 에러를 보게 됩니다.
```dart
main() {
  final sc = StreamController.broadcast();
  final broadcastStream = sc.stream;

  broadcastStream
      .singleWhere((value) => value < 1) // there is only one value less than 2
      .then((value) => print("single value: $value"));
  // outputs: single value: 1

  broadcastStream
      .single // will fail - there is more than one value in the stream
      .then((value) => print("single value: $value"))
      .catchError((err) => print("Expected Error: $err"));

  sc.addStream(asynchronousNaturalsTo(6));
}

Stream<int> asynchronousNaturalsTo(int n) async* {
  int k = 1;
  while (k < n) yield k++;
}
```

## Reference
http://dartdoc.takyam.com/docs/tutorials/streams/

