import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:notedok/domain.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/parallel_executor.dart';
import 'package:notedok/services/session_api.dart';

// This is the only place where side-effects are allowed!

@immutable
abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return RetrieveFileList();
  }
}

@immutable
class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

@immutable
class SignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) async {
    killSession();
    await Amplify.Auth.signOut();
  }
}

@immutable
class RetrieveFileList implements Command {
  @override
  void execute(void Function(Message) dispatch) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (session.isSignedIn) {
      var idToken = session.userPoolTokensResult.value.idToken;
      await signIn(idToken.raw);

      // TODO: loop until retrieved all batches
      // TODO: make batch size 1000
      var json = await getFiles(100, "", () => Future.value(idToken.raw));
      var getFilesResponse = GetFilesResponse.fromJson(json);
      // TODO: sort
      var files = getFilesResponse.files.map((f) => f.fileName).toList();

      // TODO: handle errors
      dispatch(RetrieveFileListSuccess(files));
    }
  }
}

@immutable
class NoteListLoadFirstBatch implements Command {
  final List<String> files;

  const NoteListLoadFirstBatch(this.files);

  @override
  void execute(void Function(Message) dispatch) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (session.isSignedIn) {
      var idToken = session.userPoolTokensResult.value.idToken;

      try {
        List<Note> notes = await loadNotes(files, idToken.raw);
        dispatch(NoteListViewFirstBatchLoaded(notes));
      } catch (err) {
        // TODO: dispatch error
        safePrint(err);
      }
    }
  }
}

@immutable
class NoteListLoadNextBatch implements Command {
  final List<String> files;

  const NoteListLoadNextBatch(this.files);

  @override
  void execute(void Function(Message) dispatch) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (session.isSignedIn) {
      var idToken = session.userPoolTokensResult.value.idToken;

      try {
        List<Note> notes = await loadNotes(files, idToken.raw);
        dispatch(NoteListViewNextBatchLoaded(notes));
      } catch (err) {
        // TODO: dispatch error
        safePrint(err);
      }
    }
  }
}

Future<List<Note>> loadNotes(List<String> files, String idToken) async {
  List<Note> notes = [];
  final List<Future<String>> pendingRequests = [];
  for (var i = 0; i < files.length; i++) {
    String fileName = files[i];
    pendingRequests.add(getFile(fileName, () => Future.value(idToken)));
  }
  var results = await Future.wait(pendingRequests);
  for (var i = 0; i < files.length; i++) {
    String fileName = files[i];
    String text = results[i];
    var note = Note(
      fileName,
      fileName,
      text,
    ); // TODO: convert filename to title
    notes.add(note);
  }
  return notes;
}

@immutable
class LoadNoteContent implements Command {
  final String fileName;

  const LoadNoteContent(this.fileName);

  @override
  void execute(void Function(Message) dispatch) async {
    final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
    if (session.isSignedIn) {
      // TODO: where can I store this?
      var idToken = session.userPoolTokensResult.value.idToken;

      try {
        var text = await getFile(fileName, () => Future.value(idToken.raw));
        dispatch(NotePageViewNoteContentLoaded(fileName, text));
      } catch (err) {
        dispatch(NotePageViewNoteContentLoadingFailed()); // TODO: pass error
      }
    }
  }
}
