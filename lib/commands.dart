import 'package:flutter/material.dart';
import 'package:notedok/messages.dart';

// This is the only place where side-effects are allowed!

@immutable
abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return InitializeApp();
  }
}

@immutable
class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

@immutable
class InitializeApp implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}
