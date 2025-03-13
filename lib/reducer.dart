import 'package:flutter/material.dart';
import 'package:notedok/commands.dart';
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

  if (message is RetrieveFileListSuccess) {
    return ModelAndCommand(
      FileListRetrievedModel(
        message.files,
        message.files.skip(noteBatchSize).toList(),
      ),
      NoteListLoadFirstBatch(message.files.take(noteBatchSize).toList()),
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
        NoteListViewModel(model.files, model.unprocessedFiles, listItems),
      );
    }
    return ModelAndCommand.justModel(model);
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
          model.files,
          model.unprocessedFiles.skip(noteBatchSize).toList(),
          updatedItems,
        ),
        NoteListLoadNextBatch(
          model.unprocessedFiles.take(noteBatchSize).toList(),
        ),
      );
    }
    return ModelAndCommand.justModel(model);
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
        NoteListViewModel(model.files, model.unprocessedFiles, updatedItems),
      );
    }
    return ModelAndCommand.justModel(model);
  }
  if (message is NoteListViewReloadRequested) {
    return ModelAndCommand(RetrievingFileListModel(), RetrieveFileList());
  }

  if (message is NoteListViewMoveToPageView) {
    if (model is NoteListViewModel) {
      return ModelAndCommand.justModel(
        NotePageViewModel(model.files, message.noteIdx, message.note),
      );
    }
    return ModelAndCommand.justModel(model);
  }
  if (message is NotePageViewMoveToListView) {
    return ModelAndCommand(RetrievingFileListModel(), RetrieveFileList());
  }

  if (message is NotePageViewMovedToNote) {
    if (model is NotePageViewModel) {
      return ModelAndCommand(
        NotePageViewNoteLoadingModel(model.files, message.noteIdx),
        LoadNoteContent(model.files[message.noteIdx]),
      );
    }
  }
  if (message is NotePageViewNoteContentLoaded) {
    if (model is NotePageViewNoteLoadingModel) {
      if (model.files[model.currentFileIdx] == message.fileName) {
        return ModelAndCommand.justModel(
          NotePageViewModel(
            model.files,
            model.currentFileIdx,
            Note(
              message.fileName,
              message.fileName,
              message.text,
            ), // TODO: filename to title
          ),
        );
      }
    }
  }

  return ModelAndCommand.justModel(model);
}
