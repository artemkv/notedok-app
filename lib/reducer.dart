import 'package:flutter/material.dart';
import 'package:notedok/commands.dart';
import 'package:notedok/conversions.dart';
import 'package:notedok/domain.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/model.dart';

@immutable
class ModelAndCommand {
  final Model model;
  final Command command;

  const ModelAndCommand(this.model, this.command);
  ModelAndCommand.justModel(Model model) : this(model, Command.none());
}

// reduce must be a pure function!

const int noteBatchSize = 5;

ModelAndCommand reduce(Model model, Message message) {
  if (message is SignOutRequested) {
    return ModelAndCommand(SignOutInProgressModel(), SignOut());
  }

  if (message is SearchSubmitted) {
    return ModelAndCommand(
      RetrievingFileListModel(message.searchString),
      RetrieveFileList(message.searchString),
    );
  }

  if (message is RetrieveFileListSuccess) {
    if (model is RetrievingFileListModel) {
      return ModelAndCommand(
        FileListRetrievedModel(
          model.searchString,
          message.files,
          message.files.skip(noteBatchSize).toList(),
        ),
        NoteListLoadFirstBatch(
          message.files.take(noteBatchSize).toList(),
          message.files.skip(noteBatchSize).take(noteBatchSize).toList(),
        ),
      );
    }
  }
  if (message is RetrieveFileListFailure) {
    return ModelAndCommand.justModel(
      FileListRetrievalFailedModel(message.searchString, message.reason),
    );
  }
  if (message is FileListReloadRequested) {
    return ModelAndCommand(
      RetrievingFileListModel(message.searchString),
      RetrieveFileList(message.searchString),
    );
  }
  if (message is NoteListViewFirstBatchLoaded) {
    if (model is FileListRetrievedModel) {
      var listItems =
          message.notes
              .map((note) => NoteListItemNote(note) as NoteListItem)
              .toList();
      if (model.unprocessedFiles.isNotEmpty) {
        listItems.add(NoteListItemLoadMoreTrigger());
      }
      return ModelAndCommand.justModel(
        NoteListViewModel(
          model.searchString,
          model.files,
          model.unprocessedFiles,
          listItems,
        ),
      );
    }
  }
  if (message is NoteListViewNextBatchRequested) {
    if (model is NoteListViewModel) {
      var updatedItems = <NoteListItem>[];
      updatedItems.addAll(
        model.items.getRange(0, model.items.length - 1),
      ); // old items except the spinner
      updatedItems.add(NoteListItemLoadingMore());

      return ModelAndCommand(
        NoteListViewModel(
          model.searchString,
          model.files,
          model.unprocessedFiles.skip(noteBatchSize).toList(),
          updatedItems,
        ),
        NoteListLoadNextBatch(
          model.unprocessedFiles.take(noteBatchSize).toList(),
          model.unprocessedFiles
              .skip(noteBatchSize)
              .take(noteBatchSize)
              .toList(),
        ),
      );
    }
  }
  if (message is NoteListViewNextBatchLoaded) {
    if (model is NoteListViewModel) {
      var listItems =
          message.notes
              .map((note) => NoteListItemNote(note) as NoteListItem)
              .toList();

      var updatedItems = <NoteListItem>[];
      updatedItems.addAll(
        model.items.getRange(0, model.items.length - 1),
      ); // old items except the spinner
      updatedItems.addAll(listItems);
      if (model.unprocessedFiles.isNotEmpty) {
        updatedItems.add(NoteListItemLoadMoreTrigger());
      }

      return ModelAndCommand.justModel(
        NoteListViewModel(
          model.searchString,
          model.files,
          model.unprocessedFiles,
          updatedItems,
        ),
      );
    }
  }
  if (message is NoteListViewReloadRequested) {
    if (model is NoteListViewModel) {
      return ModelAndCommand(
        RetrievingFileListModel(model.searchString),
        RetrieveFileList(model.searchString),
      );
    }
  }

  if (message is NoteListViewMoveToPageView) {
    if (model is NoteListViewModel) {
      return ModelAndCommand(
        NotePageViewModel(
          model.searchString,
          model.files,
          message.noteIdx,
          message.note,
        ),
        PreloadNoteContent(model.files, message.noteIdx),
      );
    }
  }
  if (message is NotePageViewMoveToListView) {
    if (model is NotePageViewModel) {
      return ModelAndCommand(
        RetrievingFileListModel(model.searchString),
        RetrieveFileList(model.searchString),
      );
    }
  }

  if (message is NotePageViewMovedToNote) {
    if (model is NotePageViewModel) {
      return ModelAndCommand(
        NotePageViewNoteLoadingModel(
          model.searchString,
          model.files,
          message.noteIdx,
        ),
        CommandList([
          LoadNoteContent(model.files[message.noteIdx]),
          PreloadNoteContent(model.files, message.noteIdx),
        ]),
      );
    }
  }
  if (message is NotePageViewNoteContentLoaded) {
    if (model is NotePageViewNoteLoadingModel) {
      if (model.files[model.currentFileIdx] == message.fileName) {
        return ModelAndCommand.justModel(
          NotePageViewModel(
            model.searchString,
            model.files,
            model.currentFileIdx,
            Note(
              message.fileName,
              getTitleFromPath(message.fileName),
              message.text,
            ),
          ),
        );
      }
    }
  }

  if (message is CreateNewNoteRequested) {
    if (model is NoteListViewModel) {
      return ModelAndCommand.justModel(
        NoteEditorModel(
          "",
          "",
          "",
          true,
          model.saveState(),
          NotePageViewSavedState.empty(),
        ),
      );
    }
  }
  if (message is NewNoteCreationCanceled) {
    if (model is NoteEditorModel) {
      return ModelAndCommand.justModel(
        NoteListViewModel.restore(model.listViewSavedState),
      );
    }
  }
  if (message is SaveNewNoteRequested) {
    return ModelAndCommand(
      SavingNewNoteModel(),
      SaveNewNote(message.title, message.text),
    );
  }
  if (message is NewNoteSaved) {
    return ModelAndCommand(RetrievingFileListModel(""), RetrieveFileList(""));
  }

  if (message is EditNoteRequested) {
    if (model is NotePageViewModel) {
      return ModelAndCommand.justModel(
        NoteEditorModel(
          message.note.fileName,
          message.note.title,
          message.note.text,
          false,
          NoteListViewSavedState.empty(),
          model.saveState(),
        ),
      );
    }
  }
  if (message is NoteEditingCanceled) {
    if (model is NoteEditorModel) {
      return ModelAndCommand.justModel(
        NotePageViewModel.restore(model.pageViewSavedState),
      );
    }
  }
  if (message is SaveNoteRequested) {
    if (model is NoteEditorModel) {
      return ModelAndCommand(
        SavingNoteModel(model.pageViewSavedState),
        CommandList([
          InvalidatePreloadedContent(model.fileName),
          SaveNote(
            model.fileName,
            message.title,
            message.text,
            message.oldTitle,
            message.oldText,
          ),
        ]),
      );
    }
  }
  if (message is NoteSaved) {
    if (model is SavingNoteModel) {
      // TODO: if title was updated, the file list contains incorrect entry
      return ModelAndCommand.justModel(
        NotePageViewModel(
          model.pageViewSavedState.searchString,
          model.pageViewSavedState.files,
          model.pageViewSavedState.currentFileIdx,
          message.note,
        ),
      );
    }
  }

  return ModelAndCommand.justModel(model);
}
