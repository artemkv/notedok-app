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
      FileListRetrievedModel(message.files.skip(noteBatchSize).toList()),
      NoteListLoadFirstBatch(message.files.take(noteBatchSize).toList()),
    );
  }
  if (message is NoteListFirstBatchLoaded) {
    if (model is FileListRetrievedModel) {
      var listItems =
          message.notes
              .map((note) => NoteListItemNote(note) as NoteListItem)
              .toList();
      if (model.unprocessedFiles.isNotEmpty) {
        listItems.add(NoteListItemLoadMoreTrigger());
      }
      return ModelAndCommand.justModel(
        NoteListModel(listItems, model.unprocessedFiles),
      );
    }
    return ModelAndCommand.justModel(model);
  }
  if (message is NoteListNextBatchRequested) {
    if (model is NoteListModel) {
      var updatedItems = <NoteListItem>[];
      updatedItems.addAll(
        model.items.getRange(0, model.items.length - 1),
      ); // old items except the spinner
      updatedItems.add(NoteListItemLoadingMore());

      return ModelAndCommand(
        NoteListModel(
          updatedItems,
          model.unprocessedFiles.skip(noteBatchSize).toList(),
        ),
        NoteListLoadNextBatch(
          model.unprocessedFiles.take(noteBatchSize).toList(),
        ),
      );
    }
    return ModelAndCommand.justModel(model);
  }
  if (message is NoteListNextBatchLoaded) {
    if (model is NoteListModel) {
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
        NoteListModel(updatedItems, model.unprocessedFiles),
      );
    }
    return ModelAndCommand.justModel(model);
  }

  if (message is MovedToNote) {
    if (model is NotePageViewModel) {
      return ModelAndCommand(
        NoteLoadingModel(model.files, message.noteIdx),
        LoadNoteContent(model.files[message.noteIdx]),
      );
    }
  }
  if (message is NoteContentLoaded) {
    if (model is NoteLoadingModel) {
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
