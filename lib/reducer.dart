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
  /*if (message is AppInitializedNotSignedIn) {
    return ModelAndCommand.justModel(UserNotSignedInModel());
  }*/

  return ModelAndCommand.justModel(model);
}
