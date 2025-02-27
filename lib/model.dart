// Should all be immutable classes and no logic!
// No side effects allowed!

import 'package:flutter/material.dart';

@immutable
abstract class Model {
  const Model();

  static Model getInitialModel() {
    return RetrievingFileListModel();
  }
}

@immutable
class RetrievingFileListModel extends Model {}

@immutable
class NoteListViewModel extends Model {
  final List<String> files;

  const NoteListViewModel(this.files);
}

@immutable
class SignOutInProgressModel extends Model {}
