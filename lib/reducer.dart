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

ModelAndCommand reduce(Model model, Message message) {
  if (message is SignOutRequested) {
    return ModelAndCommand(SignOutInProgressModel(), SignOut());
  }
  if (message is RetrieveFileListSuccess) {
    return ModelAndCommand(
      NoteLoadingModel(message.files, 0),
      LoadNoteContent(message.files[0]),
    );
  }
  if (message is MovedToNote) {
    if (model is NoteListViewModel) {
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
          NoteListViewModel(
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
