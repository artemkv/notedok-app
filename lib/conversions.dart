const titlePostfixSeparator = "~~";

String getTitleFromPath(String path) {
  String title = path.substring(0, path.length - 4);

  int separatorIndex = title.lastIndexOf(titlePostfixSeparator);
  if (separatorIndex >= 0) {
    title = title.substring(0, separatorIndex);
  }

  title = decodePathFileSystemFriendly(title);

  return title;
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
