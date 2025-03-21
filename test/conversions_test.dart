import 'package:flutter_test/flutter_test.dart';
import 'package:notedok/conversions.dart';

void main() {
  // Title from path, text

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

  // Title from path, markdown

  test('get title from path, md', () {
    var title = getTitleFromPath("Hello, World.md");
    expect(title, "Hello, World");
  });

  test('get title from unique path, md', () {
    var title = getTitleFromPath("Hello, World~~3465786348.md");
    expect(title, "Hello, World");
  });

  test('get title from unique path with double sepatator, md', () {
    var title = getTitleFromPath("Hello~~World~~3465786348.md");
    expect(title, "Hello~~World");
  });

  test('get title decode chars, md', () {
    var title = getTitleFromPath(
      "Hello, World (sl)(qst)(lt)(gt)(bsl)(col)(star)(pipe)(dqt)(crt)(pct)~~3465786348.md",
    );
    expect(title, "Hello, World /?<>\\:*|\"^%");
  });

  test('get title from minimal path, md', () {
    var title = getTitleFromPath(".md");
    expect(title, "");
  });

  test('get title from short path, md', () {
    var title = getTitleFromPath("1.md");
    expect(title, "1");
  });

  // Path from title, text

  test('generate path from title', () {
    var path = generatePathFromTitleText("Hello, World", false);
    expect(path, "Hello, World.txt");
  });

  test('generate unique path from title', () {
    var path = generatePathFromTitleText("Hello, World", true);
    expect(path.startsWith("Hello, World~~"), true);
    expect(path.endsWith(".txt"), true);
  });

  test('generate unique path from empty title', () {
    var path = generatePathFromTitleText("", true);
    expect(path.startsWith("~~"), true);
    expect(path.endsWith(".txt"), true);
  });

  test('generate path from empty title encode chars', () {
    var path = generatePathFromTitleText("Hello, World /?<>\\:*|\"^%", false);
    expect(
      path,
      "Hello, World (sl)(qst)(lt)(gt)(bsl)(col)(star)(pipe)(dqt)(crt)(pct).txt",
    );
  });

  // Path from title, markdown

  test('generate path from title, md', () {
    var path = generatePathFromTitleMd("Hello, World", false);
    expect(path, "Hello, World.md");
  });

  test('generate unique path from title, md', () {
    var path = generatePathFromTitleMd("Hello, World", true);
    expect(path.startsWith("Hello, World~~"), true);
    expect(path.endsWith(".md"), true);
  });

  test('generate unique path from empty title, md', () {
    var path = generatePathFromTitleMd("", true);
    expect(path.startsWith("~~"), true);
    expect(path.endsWith(".md"), true);
  });

  test('generate path from empty title encode chars, md', () {
    var path = generatePathFromTitleMd("Hello, World /?<>\\:*|\"^%", false);
    expect(
      path,
      "Hello, World (sl)(qst)(lt)(gt)(bsl)(col)(star)(pipe)(dqt)(crt)(pct).md",
    );
  });
}
