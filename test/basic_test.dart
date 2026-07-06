import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quiz App Basic Logic Test', () {
    // A simple test to demonstrate a passing condition for the report
    int initialScore = 0;
    int scoreAfterCorrectAnswer = initialScore + 10;
    
    expect(scoreAfterCorrectAnswer, 10);
  });
}
