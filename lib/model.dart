// Should all be immutable classes and no logic!
// No side effects allowed!

import 'package:flutter/material.dart';
import 'package:notedok/domain.dart';

@immutable
abstract class Model {
  const Model();

  static Model getInitialModel() {
    return RetrievingFileListModel("");
  }
}

@immutable
class SignOutInProgressModel extends Model {}

@immutable
class RetrievingFileListModel extends Model {
  final String searchString;

  const RetrievingFileListModel(this.searchString);
}

@immutable
class FileListRetrievedModel extends Model {
  final String searchString;
  final List<String> files;
  final List<String> unprocessedFiles;

  const FileListRetrievedModel(
    this.searchString,
    this.files,
    this.unprocessedFiles,
  );
}

@immutable
class FileListRetrievalFailedModel extends Model {
  final String searchString;
  final String reason;

  const FileListRetrievalFailedModel(this.searchString, this.reason);
}

@immutable
class NoteListViewModel extends Model {
  final String searchString;
  final List<String> files;
  final List<String> unprocessedFiles;
  final List<NoteListItem> items;

  const NoteListViewModel(
    this.searchString,
    this.files,
    this.unprocessedFiles,
    this.items,
  );

  NoteListViewModel.restore(NoteListViewSavedState state)
    : searchString = state.searchString,
      files = state.files,
      unprocessedFiles = state.unprocessedFiles,
      items = state.items;

  NoteListViewSavedState saveState() {
    return NoteListViewSavedState(searchString, files, unprocessedFiles, items);
  }
}

@immutable
class NoteListViewSavedState {
  final String searchString;
  final List<String> files;
  final List<String> unprocessedFiles;
  final List<NoteListItem> items;

  const NoteListViewSavedState(
    this.searchString,
    this.files,
    this.unprocessedFiles,
    this.items,
  );

  NoteListViewSavedState.empty()
    : searchString = "",
      files = [],
      unprocessedFiles = [],
      items = [];
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
  final String searchString;
  final List<String> files;
  final int currentFileIdx;
  final Note note;

  const NotePageViewModel(
    this.searchString,
    this.files,
    this.currentFileIdx,
    this.note,
  );

  NotePageViewModel.restore(NotePageViewSavedState state)
    : searchString = state.searchString,
      files = state.files,
      currentFileIdx = state.currentFileIdx,
      note = state.note;

  NotePageViewSavedState saveState() {
    return NotePageViewSavedState(searchString, files, currentFileIdx, note);
  }
}

@immutable
class NotePageViewSavedState {
  final String searchString;
  final List<String> files;
  final int currentFileIdx;
  final Note note;

  const NotePageViewSavedState(
    this.searchString,
    this.files,
    this.currentFileIdx,
    this.note,
  );

  NotePageViewSavedState.empty()
    : searchString = "",
      files = [],
      currentFileIdx = 0,
      note = Note.empty();
}

@immutable
class NotePageViewNoteLoadingModel extends Model {
  final String searchString;
  final List<String> files;
  final int currentFileIdx;

  const NotePageViewNoteLoadingModel(
    this.searchString,
    this.files,
    this.currentFileIdx,
  );
}

@immutable
class NoteEditorModel extends Model {
  final String fileName;
  final String title;
  final String text;
  final bool isNew;
  final NoteListViewSavedState listViewSavedState;
  final NotePageViewSavedState pageViewSavedState;

  const NoteEditorModel(
    this.fileName,
    this.title,
    this.text,
    this.isNew,
    this.listViewSavedState,
    this.pageViewSavedState,
  );
}

@immutable
class SavingNewNoteModel extends Model {}

@immutable
class SavingNoteModel extends Model {
  final NotePageViewSavedState pageViewSavedState;

  const SavingNoteModel(this.pageViewSavedState);
}
