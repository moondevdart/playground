import 'dart:async';

Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;

  await for (var value in stream) {
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
Stream<int> countStream(int to) async* {
  // async*는 yield를 쓴다는 의미다.
  print('매개변수 to :  ${to}');
  //yield는 계속 to의 갯수만큼 1번씩 함수를 리턴한다.
  for (int i = 1; i <= to; i++) {
    yield i;
    print('countStream의 yield');
  }
  for (int i = 1; i <= to; i++) {
    print('그냥 for문? ${i}');
  }
}

main() async {
  var stream = countStream(10);
  var sum = await sumStream(stream);
  print('총합 >>>>>>>>>>>>>>>>>> ${sum}');
}
