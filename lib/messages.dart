// Should all be immutable classes and no logic!

import 'package:flutter/material.dart';

@immutable
abstract class Message {}

@immutable
class RetrieveFileListSuccess implements Message {
  final List<String> files;

  const RetrieveFileListSuccess(this.files);
}

@immutable
class SignOutRequested implements Message {}

@immutable
class MovedToNote implements Message {
  final int noteIdx;

  const MovedToNote(this.noteIdx);
}

@immutable
class NoteContentLoaded implements Message {
  final String fileName;
  final String text;

  const NoteContentLoaded(this.fileName, this.text);
}

@immutable
class NoteContentLoadedingFailed implements Message {
  const NoteContentLoadedingFailed();
}
