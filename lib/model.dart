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
class NoteListViewLoadingFirstBatchFailedModel extends Model {
  final String searchString;
  final List<String> files;
  final List<String> unprocessedFiles;
  final List<String> filesToLoad;
  final List<String> filesToPreload;
  final String reason;

  const NoteListViewLoadingFirstBatchFailedModel(
    this.searchString,
    this.files,
    this.unprocessedFiles,
    this.filesToLoad,
    this.filesToPreload,
    this.reason,
  );
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
class NoteListItemDeletingNote extends NoteListItem {
  final Note note;

  const NoteListItemDeletingNote(this.note);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemDeletingNote && note == other.note;
  }

  @override
  int get hashCode => note.hashCode;
}

@immutable
class NoteListItemDeletedNote extends NoteListItem {
  final Note note;

  const NoteListItemDeletedNote(this.note);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemDeletedNote && note == other.note;
  }

  @override
  int get hashCode => note.hashCode;
}

@immutable
class NoteListItemRetryDeletingNote extends NoteListItem {
  final Note note;
  final String reason;

  const NoteListItemRetryDeletingNote(this.note, this.reason);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemRetryDeletingNote && note == other.note;
  }

  @override
  int get hashCode => note.hashCode;
}

@immutable
class NoteListItemRestoringNote extends NoteListItem {
  final Note note;

  const NoteListItemRestoringNote(this.note);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemRestoringNote && note == other.note;
  }

  @override
  int get hashCode => note.hashCode;
}

@immutable
class NoteListItemRetryRestoringNote extends NoteListItem {
  final Note note;
  final String reason;

  const NoteListItemRetryRestoringNote(this.note, this.reason);

  @override
  bool operator ==(Object other) {
    return other is NoteListItemRetryRestoringNote && note == other.note;
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
  final List<String> filesToLoad;
  final List<String> filesToPreload;
  final String reason;

  const NoteListItemRetryLoadMore(
    this.filesToLoad,
    this.filesToPreload,
    this.reason,
  );

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
class NotePageViewLoadingNoteContentFailedModel extends Model {
  final String searchString;
  final List<String> files;
  final int currentFileIdx;
  final String reason;

  const NotePageViewLoadingNoteContentFailedModel(
    this.searchString,
    this.files,
    this.currentFileIdx,
    this.reason,
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
class SavingNewNoteFailedModel implements Model {
  final String title;
  final String text;
  final String reason;

  const SavingNewNoteFailedModel(this.title, this.text, this.reason);
}

@immutable
class SavingNewNoteWithUniquePathFailedModel implements Model {
  final String path;
  final String text;
  final String reason;

  const SavingNewNoteWithUniquePathFailedModel(
    this.path,
    this.text,
    this.reason,
  );
}

@immutable
class SavingNoteModel extends Model {
  final NotePageViewSavedState pageViewSavedState;

  const SavingNoteModel(this.pageViewSavedState);
}

@immutable
class SavingNoteFailedModel implements Model {
  final NotePageViewSavedState pageViewSavedState;
  final String path;
  final String title;
  final String text;
  final String oldTitle;
  final String oldText;
  final String reason;

  const SavingNoteFailedModel(
    this.pageViewSavedState,
    this.path,
    this.title,
    this.text,
    this.oldTitle,
    this.oldText,
    this.reason,
  );
}

@immutable
class RenamingNoteFailedModel implements Model {
  final NotePageViewSavedState pageViewSavedState;
  final String path;
  final String newPath;
  final String title;
  final String text;
  final String reason;

  const RenamingNoteFailedModel(
    this.pageViewSavedState,
    this.path,
    this.newPath,
    this.title,
    this.text,
    this.reason,
  );
}

@immutable
class RenamingNoteWithUniquePathFailedModel implements Model {
  final NotePageViewSavedState pageViewSavedState;
  final String path;
  final String newPath;
  final String title;
  final String text;
  final String reason;

  const RenamingNoteWithUniquePathFailedModel(
    this.pageViewSavedState,
    this.path,
    this.newPath,
    this.title,
    this.text,
    this.reason,
  );
}

@immutable
class AppSettingsModel extends Model {}

@immutable
class AccountDeletionConfirmationStateModel extends Model {
  final String text;

  const AccountDeletionConfirmationStateModel(this.text);
}

@immutable
class DeletingAccountModel implements Model {}

@immutable
class DeletingAccountFailedModel extends Model {
  final String reason;

  const DeletingAccountFailedModel(this.reason);
}
