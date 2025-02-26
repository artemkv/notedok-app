// Should all be immutable classes and no logic!
// No side effects allowed!

import 'package:flutter/material.dart';

@immutable
abstract class Model {
  const Model();

  static Model getInitialModel() {
    return UserSignedInModel();
  }
}

@immutable
class UserSignedInModel extends Model {}
