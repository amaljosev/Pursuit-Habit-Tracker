import 'dart:math';

int getRandomInt(int max) {
  if (max < 0) {
    return 1;
  }
  final random = Random();
  return 0 + random.nextInt(max - 0 + 1);
}
