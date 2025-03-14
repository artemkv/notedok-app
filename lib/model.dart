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
class FileListRetrievedModel extends Model {
  final List<String> files;
  final List<String> unprocessedFiles;

  const FileListRetrievedModel(this.files, this.unprocessedFiles);
}

@immutable
class NoteListViewModel extends Model {
  final List<String> files;
  final List<String> unprocessedFiles;
  final List<NoteListItem> items;

  const NoteListViewModel(this.files, this.unprocessedFiles, this.items);
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
class NoteListItemLoadMoreTrigger extends NoteListItem {
  @override
  bool operator ==(Object other) {
    return other is NoteListItemLoadMoreTrigger;
  }

  @override
  int get hashCode => 1;
}

@immutable
class NoteListItemLoadingMore extends NoteListItem {
  @override
  bool operator ==(Object other) {
    return other is NoteListItemLoadingMore;
  }

  @override
  int get hashCode => 1;
}

@immutable
class NoteListItemRetryLoadMore extends NoteListItem {
  final String reason;

  const NoteListItemRetryLoadMore(this.reason);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemLoadMoreTrigger;
  }

  @override
  int get hashCode => 1;
}

@immutable
class NotePageViewModel extends Model {
  final List<String> files;
  final int currentFileIdx;
  final Note note;

  const NotePageViewModel(this.files, this.currentFileIdx, this.note);
}

@immutable
class NotePageViewNoteLoadingModel extends Model {
  final List<String> files;
  final int currentFileIdx;

  const NotePageViewNoteLoadingModel(this.files, this.currentFileIdx);
}

@immutable
class NoteEditorModel extends Model {
  final String title;
  final String text;
  final bool isNew;

  const NoteEditorModel(this.title, this.text, this.isNew);
}

@immutable
class SavingNewNoteModel extends Model {}

@immutable
class SavingNoteModel extends Model {}
