// Should all be immutable classes and no logic!
// No side effects allowed!

import 'package:flutter/material.dart';
import 'package:notedok/domain.dart';

@immutable
abstract class Model {
  const Model();

  static Model getInitialModel() {
    return RetrievingFileListModel();
  }
}

@immutable
class SignOutInProgressModel extends Model {}

@immutable
class RetrievingFileListModel extends Model {}

@immutable
class NoteListModel extends Model {
  final List<NoteListItem> items;

  const NoteListModel(this.items);
}

@immutable
class NoteListItem {
  const NoteListItem();
}

@immutable
class NoteListItemNote extends NoteListItem {
  final Note note;

  const NoteListItemNote(this.note);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemNote && note == other.note;
  }

  @override
  int get hashCode => note.hashCode;
}

@immutable
class NotePageViewModel extends Model {
  final List<String> files;
  final int currentFileIdx;
  final Note note;

  const NotePageViewModel(this.files, this.currentFileIdx, this.note);
}

@immutable
class NoteLoadingModel extends Model {
  final List<String> files;
  final int currentFileIdx;

  const NoteLoadingModel(this.files, this.currentFileIdx);
}
