import 'package:flutter/material.dart';
import 'package:notedok/commands.dart';
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
  if (message is RetrieveFileListSuccess) {
    return ModelAndCommand.justModel(NoteListViewModel(message.files));
  }
  if (message is SignOutRequested) {
    return ModelAndCommand(SignOutInProgressModel(), SignOut());
  }

  return ModelAndCommand.justModel(model);
}
