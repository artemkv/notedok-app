// Should all be immutable classes and no logic!

import 'package:flutter/material.dart';
import 'package:notedok/domain.dart';

@immutable
abstract class Message {}

@immutable
class SignOutRequested implements Message {}

@immutable
class SearchSubmitted implements Message {
  final String searchString;

  const SearchSubmitted(this.searchString);
}

@immutable
class RetrieveFileListSuccess implements Message {
  final List<String> files;

  const RetrieveFileListSuccess(this.files);
}

@immutable
class RetrieveFileListFailure implements Message {
  final String searchString;
  final String reason;

  const RetrieveFileListFailure(this.searchString, this.reason);
}

@immutable
class FileListReloadRequested implements Message {
  final String searchString;

  const FileListReloadRequested(this.searchString);
}

@immutable
class NoteListViewFirstBatchLoaded implements Message {
  final List<Note> notes;

  const NoteListViewFirstBatchLoaded(this.notes);
}

@immutable
class NoteListViewFirstBatchLoadFailed implements Message {
  final List<String> filesToLoad;
  final List<String> filesToPreload;
  final String reason;

  const NoteListViewFirstBatchLoadFailed(
    this.filesToLoad,
    this.filesToPreload,
    this.reason,
  );
}

@immutable
class NoteListViewFirstBatchReloadRequested implements Message {
  final List<String> filesToLoad;
  final List<String> filesToPreload;

  const NoteListViewFirstBatchReloadRequested(
    this.filesToLoad,
    this.filesToPreload,
  );
}

@immutable
class NoteListViewNextBatchRequested implements Message {}

@immutable
class NoteListViewNextBatchLoaded implements Message {
  final List<Note> notes;

  const NoteListViewNextBatchLoaded(this.notes);
}

@immutable
class NoteListViewNextBatchLoadFailed implements Message {
  final List<String> filesToLoad;
  final List<String> filesToPreload;
  final String reason;

  const NoteListViewNextBatchLoadFailed(
    this.filesToLoad,
    this.filesToPreload,
    this.reason,
  );
}

@immutable
class NoteListViewNextBatchReloadRequested implements Message {
  final List<String> filesToLoad;
  final List<String> filesToPreload;

  const NoteListViewNextBatchReloadRequested(
    this.filesToLoad,
    this.filesToPreload,
  );
}

@immutable
class NoteListViewReloadRequested implements Message {}

@immutable
class NoteListViewMoveToPageView implements Message {
  final Note note;
  final int noteIdx;

  const NoteListViewMoveToPageView(this.note, this.noteIdx);
}

@immutable
class NotePageViewMoveToListView implements Message {}

@immutable
class NotePageViewMovedToNote implements Message {
  final int noteIdx;

  const NotePageViewMovedToNote(this.noteIdx);
}

@immutable
class NotePageViewNoteContentLoaded implements Message {
  final String fileName;
  final String text;

  const NotePageViewNoteContentLoaded(this.fileName, this.text);
}

@immutable
class NotePageViewNoteContentLoadingFailed implements Message {
  final String reason;

  const NotePageViewNoteContentLoadingFailed(this.reason);
}

@immutable
class NotePageViewReloadNoteContentRequested implements Message {}

@immutable
class CreateNewNoteRequested implements Message {}

@immutable
class NewNoteCreationCanceled implements Message {}

@immutable
class SaveNewNoteRequested implements Message {
  final String title;
  final String text;

  const SaveNewNoteRequested(this.title, this.text);
}

@immutable
class NewNoteSaved implements Message {}

@immutable
class SavingNewNoteFailed implements Message {
  final String title;
  final String text;
  final String reason;

  const SavingNewNoteFailed(this.title, this.text, this.reason);
}

@immutable
class SaveNewNoteRetryRequested implements Message {
  final String title;
  final String text;

  const SaveNewNoteRetryRequested(this.title, this.text);
}

@immutable
class SavingNewNoteWithUniquePathFailed implements Message {
  final String path;
  final String text;
  final String reason;

  const SavingNewNoteWithUniquePathFailed(this.path, this.text, this.reason);
}

@immutable
class SavingNewNoteWithUniquePathRetryRequested implements Message {
  final String path;
  final String text;

  const SavingNewNoteWithUniquePathRetryRequested(this.path, this.text);
}

@immutable
class EditNoteRequested implements Message {
  final Note note;

  const EditNoteRequested(this.note);
}

@immutable
class NoteEditingCanceled implements Message {}

@immutable
class SaveNoteRequested implements Message {
  final String title;
  final String text;
  final String oldTitle;
  final String oldText;

  const SaveNoteRequested(this.title, this.text, this.oldTitle, this.oldText);
}

@immutable
class NoteSaved implements Message {
  final Note note;

  const NoteSaved(this.note);
}

@immutable
class SavingNoteFailed implements Message {
  final String reason;

  const SavingNoteFailed(this.reason);
}
