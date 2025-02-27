// Should all be immutable classes and no logic!

import 'package:flutter/material.dart';

@immutable
abstract class Message {}

@immutable
class RetrieveFileListSuccess implements Message {
  final List<String> files;

  const RetrieveFileListSuccess(this.files);
}
