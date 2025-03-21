const titlePostfixSeparator = "~~";

bool isMarkdownFile(String path) {
  return path.endsWith(".md");
}

String getTitleFromPath(String path) {
  String title = "";
  if (path.endsWith(".txt")) {
    title = path.substring(0, path.length - 4);
  } else if (path.endsWith(".md")) {
    title = path.substring(0, path.length - 3);
  } else {
    throw "unknown file type";
  }

  int separatorIndex = title.lastIndexOf(titlePostfixSeparator);
  if (separatorIndex >= 0) {
    title = title.substring(0, separatorIndex);
  }

  title = decodePathFileSystemFriendly(title);

  return title;
}

String generatePathFromTitleText(String title, bool ensureUnique) {
  String postfix = "";
  if (ensureUnique) {
    var date = DateTime.now();
    int n = date.millisecondsSinceEpoch;
    postfix = titlePostfixSeparator + n.toString();
  }
  return "${encodePathFileSystemFriendly(title)}$postfix.txt";
}

String generatePathFromTitleMd(String title, bool ensureUnique) {
  String postfix = "";
  if (ensureUnique) {
    var date = DateTime.now();
    int n = date.millisecondsSinceEpoch;
    postfix = titlePostfixSeparator + n.toString();
  }
  return "${encodePathFileSystemFriendly(title)}$postfix.md";
}

String encodePathFileSystemFriendly(String path) {
  path = path.replaceAll("/", "(sl)");
  path = path.replaceAll("?", "(qst)");
  path = path.replaceAll("<", "(lt)");
  path = path.replaceAll(">", "(gt)");
  path = path.replaceAll("\\", "(bsl)");
  path = path.replaceAll(":", "(col)");
  path = path.replaceAll("*", "(star)");
  path = path.replaceAll("|", "(pipe)");
  path = path.replaceAll("\"", "(dqt)");
  path = path.replaceAll("^", "(crt)");
  path = path.replaceAll("%", "(pct)");

  if (path.startsWith(".")) {
    path = "_$path";
  }

  return path;
}

String decodePathFileSystemFriendly(String path) {
  path = path.replaceAll("(sl)", "/");
  path = path.replaceAll("(qst)", "?");
  path = path.replaceAll("(lt)", "<");
  path = path.replaceAll("(gt)", ">");
  path = path.replaceAll("(bsl)", "\\");
  path = path.replaceAll("(col)", ":");
  path = path.replaceAll("(star)", "*");
  path = path.replaceAll("(pipe)", "|");
  path = path.replaceAll("(dqt)", "\"");
  path = path.replaceAll("(crt)", "^");
  path = path.replaceAll("(pct)", "%");
  return path;
}
