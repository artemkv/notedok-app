import 'dart:math';

var whitespace = RegExp(r'^\s$');
var newline = RegExp(r'^\n$');
const quote = "&quot;";

class WikiToHtmlFormatter {
  String _char = "";
  String _text = "";
  int _pos = -1;
  bool _listOpened = false;

  String format(String wiki) {
    // Normalize line ends
    List<String> strings = wiki.split("\\r\\n|\\n|\\r");
    _text = "${strings.join("\n")}\n";

    // Length has to be re-calculated every time, because it can change
    for (_pos = 0; _pos < _text.length; _pos++) {
      _char = getCharAt(_text, _pos);

      if (_char == "*") {
        tryWrap("*", "<b>", "</b>");
        tryUl("*");
      } else if (_char == "_") {
        tryWrap("_", "<i>", "</i>");
      } else if (_char == "-") {
        tryWrap("--", "<del>", "</del>");
        tryUl("-");
      } else if (_char == "+") {
        tryWrap("++", "<u>", "</u>");
      } else if (_char == "^") {
        tryWrap("^", "<sup>", "</sup>");
      } else if (_char == "~") {
        tryWrap("~", "<sub>", "</sub>");
      } else if (_char == "{") {
        _tryEscaped();
        _tryCode();
      } else if (_char == "[") {
        _tryAnchor();
      } else if (_char == "!") {
        tryHeader("!");
      } else if (_char == "h") {
        tryNumberedHeader();
      }
    }

    return _text;
  }

  void tryWrap(String formattingString, String openingTag, String closingTag) {
    // Start of the formatting
    if (jsSubstr(_text, _pos, formattingString.length) == formattingString) {
      String nextChar = getCharAt(_text, _pos + formattingString.length);
      // The formatting string is immediately followed by the word
      if (nextChar != getCharAt(formattingString, 0) &&
          !whitespace.hasMatch(nextChar) &&
          !newline.hasMatch(nextChar)) {
        // There is a closing character
        int closingTagPos = _text.indexOf(formattingString, _pos + 1);
        if (closingTagPos > 0 &&
            _text.indexOf("\n", _pos + 1) > closingTagPos) {
          // The closing character is before "<" on the same line
          if (_text.indexOf("<", _pos + 1) == -1 ||
              _text.indexOf("<", _pos + 1) > closingTagPos) {
            _text =
                jsSubstring3(_text, 0, _pos) +
                openingTag +
                jsSubstring3(
                  _text,
                  _pos + formattingString.length,
                  closingTagPos,
                ) +
                closingTag +
                jsSubstring2(_text, closingTagPos + formattingString.length);
            _pos = _pos + openingTag.length - formattingString.length;
          }
        }
      }
    }
  }

  void _tryEscaped() {
    String openingEscapeTag = "{$quote";
    String closingEscapeTag = "$quote}";

    // Start of the escaped formatting
    if (jsSubstr(_text, _pos, openingEscapeTag.length) == openingEscapeTag) {
      // End of escaping formatting
      int closingEscapeTagPos = _text.indexOf(closingEscapeTag, _pos + 1);
      if (closingEscapeTagPos < 0) {
        closingEscapeTagPos = _text.length;
      }
      _text =
          jsSubstring3(_text, 0, _pos) +
          jsSubstring3(
            _text,
            _pos + openingEscapeTag.length,
            closingEscapeTagPos,
          ) +
          jsSubstring2(_text, closingEscapeTagPos + closingEscapeTag.length);
      _pos =
          closingEscapeTagPos -
          openingEscapeTag.length -
          1; //-1 char back from the removed closing tag
    }
  }

  void _tryAnchor() {
    String nextChar = getCharAt(_text, _pos + 1);

    // The link opening bracket is immediately followed by the link
    if (nextChar != "[" &&
        !whitespace.hasMatch(nextChar) &&
        !newline.hasMatch(nextChar)) {
      // There is a closing bracket
      int closingBracketPos = _text.indexOf("]", _pos + 1);
      if (closingBracketPos > 0 &&
          _text.indexOf("\n", _pos + 1) > closingBracketPos) {
        // The closing character is before "<" on the same line
        if (_text.indexOf("<", _pos + 1) == -1 ||
            _text.indexOf("<", _pos + 1) > closingBracketPos) {
          String href = jsSubstring3(_text, _pos + 1, closingBracketPos);
          String link = "<a href='$href' target='_blank'>$href</a>";
          _text =
              jsSubstring3(_text, 0, _pos) +
              link +
              jsSubstring2(_text, closingBracketPos + 1);
          _pos =
              closingBracketPos +
              link.length -
              href.length -
              2; // 1 removed char, 1 char back from the closing bracket
        }
      }
    }
  }

  void _tryCode() {
    String codeTag = "{code}";

    // Start of the code block
    if (jsSubstr(_text, _pos, codeTag.length) == codeTag) {
      // End of the code block
      int closingTagPos = _text.indexOf(codeTag, _pos + 1);
      if (closingTagPos < 0) {
        closingTagPos = _text.length;
      }
      String codeBlock = jsSubstring3(
        _text,
        _pos + codeTag.length,
        closingTagPos,
      );
      String codeBlockFormatted = "<pre class='codeblock'>$codeBlock</pre>";
      _text =
          jsSubstring3(_text, 0, _pos) +
          codeBlockFormatted +
          jsSubstring2(_text, closingTagPos + codeTag.length);
      _pos =
          closingTagPos +
          codeBlockFormatted.length -
          codeBlock.length -
          codeTag.length -
          1; // 1 char back from the removed closing tag
    }
  }

  void tryUl(String formattingString) {
    String liTag = "$formattingString ";

    // Start of the text or the line
    if (_pos == 0 || getCharAt(_text, _pos - 1) == "\n") {
      // Start of the list item
      if (jsSubstr(_text, _pos, liTag.length) == liTag) {
        // End of escaping formatting
        int eolPos = _text.indexOf("\n", _pos + 1);
        if (eolPos < 0) {
          eolPos = _text.length;
        }

        String liText = jsSubstring3(_text, _pos + 2, eolPos);
        String wrappedLiText = "<li>$liText</li>";

        if (!_listOpened) {
          wrappedLiText = "<ul>$wrappedLiText";
          _listOpened = true;
        }

        if (jsSubstr(_text, eolPos + 1, liTag.length) != liTag) {
          wrappedLiText = "$wrappedLiText</ul>";
          _listOpened = false;
        }

        _text =
            jsSubstring3(_text, 0, _pos) +
            wrappedLiText +
            jsSubstring2(_text, eolPos);
      }
    }
  }

  void tryHeader(String formattingString) {
    String hTag = " ";
    for (int i = 0; i < 6; i++) {
      hTag = formattingString + hTag;

      // Start of the text or the line
      if (_pos == 0 || getCharAt(_text, _pos - 1) == "\n") {
        // Start of the header
        if (jsSubstr(_text, _pos, hTag.length) == hTag) {
          // End of escaping formatting
          int eolPos = _text.indexOf("\n", _pos + 1);
          if (eolPos < 0) {
            eolPos = _text.length;
          }

          String hText = jsSubstring3(_text, _pos + hTag.length, eolPos);
          var headerLevel = i + 1;
          String wrappedHText = "<h$headerLevel>$hText</h$headerLevel>";

          _text =
              jsSubstring3(_text, 0, _pos) +
              wrappedHText +
              jsSubstring2(_text, eolPos);
        }
      }
    }
  }

  void tryNumberedHeader() {
    for (int i = 0; i < 6; i++) {
      var headerLevel = i + 1;
      String hTag = "h$headerLevel. ";

      // Start of the text or the line
      if (_pos == 0 || getCharAt(_text, _pos - 1) == "\n") {
        // Start of the header
        if (jsSubstr(_text, _pos, hTag.length) == hTag) {
          // End of escaping formatting
          int eolPos = _text.indexOf("\n", _pos + 1);
          if (eolPos < 0) {
            eolPos = _text.length;
          }

          String hText = jsSubstring3(_text, _pos + hTag.length, eolPos);
          String wrappedHText = "<h$headerLevel>$hText</h$headerLevel>";

          _text =
              jsSubstring3(_text, 0, _pos) +
              wrappedHText +
              jsSubstring2(_text, eolPos);
        }
      }
    }
  }
}

String jsSubstr(String text, int start, int length) {
  if (start < 0 || start >= text.length) {
    return "";
  }
  return text.substring(start, min(start + length, text.length));
}

String jsSubstring2(String text, int start) {
  return jsSubstring3(text, start, text.length);
}

String jsSubstring3(String text, int start, int end) {
  if (start < 0 || start >= text.length) {
    return "";
  }
  return text.substring(start, min(end, text.length));
}

String getCharAt(String text, int start) {
  return jsSubstr(text, start, 1);
}
