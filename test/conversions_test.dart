import 'package:flutter_test/flutter_test.dart';
import 'package:notedok/conversions.dart';

void main() {
  // Title from path

  test('get title from path', () {
    var title = getTitleFromPath("Hello, World.txt");
    expect(title, "Hello, World");
  });

  test('get title from unique path', () {
    var title = getTitleFromPath("Hello, World~~3465786348.txt");
    expect(title, "Hello, World");
  });

  test('get title from unique path with double sepatator', () {
    var title = getTitleFromPath("Hello~~World~~3465786348.txt");
    expect(title, "Hello~~World");
  });

  test('get title decode chars', () {
    var title = getTitleFromPath(
      "Hello, World (sl)(qst)(lt)(gt)(bsl)(col)(star)(pipe)(dqt)(crt)(pct)~~3465786348.txt",
    );
    expect(title, "Hello, World /?<>\\:*|\"^%");
  });

  test('get title from minimal path', () {
    var title = getTitleFromPath(".txt");
    expect(title, "");
  });

  test('get title from short path', () {
    var title = getTitleFromPath("1.txt");
    expect(title, "1");
  });

  // Path from title

  test('generate path from title', () {
    var path = generatePathFromTitle("Hello, World", false);
    expect(path, "Hello, World.txt");
  });

  test('generate unique path from title', () {
    var path = generatePathFromTitle("Hello, World", true);
    expect(path.startsWith("Hello, World~~"), true);
    expect(path.endsWith(".txt"), true);
  });

  test('generate unique path from empty title', () {
    var path = generatePathFromTitle("", true);
    expect(path.startsWith("~~"), true);
    expect(path.endsWith(".txt"), true);
  });

  test('generate path from empty title encode chars', () {
    var path = generatePathFromTitle("Hello, World /?<>\\:*|\"^%", false);
    expect(
      path,
      "Hello, World (sl)(qst)(lt)(gt)(bsl)(col)(star)(pipe)(dqt)(crt)(pct).txt",
    );
  });
}
