import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:notedok/conversions.dart';
import 'package:notedok/domain.dart';
import 'package:notedok/messages.dart';
import 'package:notedok/services/preloader.dart';
import 'package:notedok/services/rest_api.dart' show RestApiException;
import 'package:notedok/services/session_api.dart';

// This is the only place where side-effects are allowed!

Preloader preloader = Preloader();

GetFilesCachedResult? getFilesCachedResult;

clearAllCaches() {
  getFilesCachedResult = null;
}

@immutable
abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return RetrieveFileList("", true);
  }
}

@immutable
class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

@immutable
class CommandList implements Command {
  final List<Command> items;

  const CommandList(this.items);

  @override
  void execute(void Function(Message) dispatch) {
    for (var cmd in items) {
      cmd.execute(dispatch);
    }
  }
}

@immutable
class SignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) async {
    clearAllCaches();
    killSession();
    await Amplify.Auth.signOut();
  }
}

@immutable
class RetrieveFileList implements Command {
  final int pageSize = 1000;
  final String searchString;
  final bool forceReload;

  const RetrieveFileList(this.searchString, this.forceReload);

  @override
  void execute(void Function(Message) dispatch) async {
    preloader.clean();

    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;
        await signIn(idToken.raw);

        List<FileData> files = [];

        // Try cache first
        if (!forceReload &&
            getFilesCachedResult != null &&
            getFilesCachedResult!.searchString == searchString) {
          files = getFilesCachedResult!.files;
        } else {
          // Retrieve the first batch
          var json = await getFiles(
            pageSize,
            "",
            () => Future.value(idToken.raw),
          );
          var getFilesResponse = GetFilesResponse.fromJson(json);
          files.addAll(getFilesResponse.files);

          // Keep retrieving until all
          while (getFilesResponse.hasMore) {
            json = await getFiles(
              pageSize,
              getFilesResponse.nextContinuationToken,
              () => Future.value(idToken.raw),
            );
            getFilesResponse = GetFilesResponse.fromJson(json);
            files.addAll(getFilesResponse.files);
          }

          // Cache the results
          getFilesCachedResult = GetFilesCachedResult(searchString, files);
        }

        // Apply search string and sort by newest first
        var filesFiltered =
            files
                .where(
                  (f) => f.fileName.toLowerCase().contains(
                    searchString.toLowerCase(),
                  ),
                )
                .toList();
        filesFiltered.sort((a, b) => b.lastModified.compareTo(a.lastModified));

        dispatch(
          RetrieveFileListSuccess(
            filesFiltered.map((f) => f.fileName).toList(),
          ),
        );
      }
    } catch (err) {
      dispatch(RetrieveFileListFailure(searchString, err.toString()));
    }
  }
}

@immutable
class NoteListLoadFirstBatch implements Command {
  final List<String> filesToLoad;
  final List<String> filesToPreload;

  const NoteListLoadFirstBatch(this.filesToLoad, this.filesToPreload);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        List<Note> notes = await loadNotes(filesToLoad, idToken.raw);
        dispatch(NoteListViewFirstBatchLoaded(notes));

        try {
          preloadNotes(filesToPreload, idToken.raw);
        } catch (err) {
          // Ignore errors
        }
      }
    } catch (err) {
      dispatch(
        NoteListViewFirstBatchLoadFailed(
          filesToLoad,
          filesToPreload,
          err.toString(),
        ),
      );
    }
  }
}

@immutable
class NoteListLoadNextBatch implements Command {
  final List<String> filesToLoad;
  final List<String> filesToPreload;

  const NoteListLoadNextBatch(this.filesToLoad, this.filesToPreload);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        List<Note> notes = await loadNotes(filesToLoad, idToken.raw);
        dispatch(NoteListViewNextBatchLoaded(notes));

        try {
          preloadNotes(filesToPreload, idToken.raw);
        } catch (err) {
          // Ignore errors
        }
      }
    } catch (err) {
      dispatch(
        NoteListViewNextBatchLoadFailed(
          filesToLoad,
          filesToPreload,
          err.toString(),
        ),
      );
    }
  }
}

Future<List<Note>> loadNotes(List<String> files, String idToken) async {
  List<Note> notes = [];
  final List<Future<String>> pendingRequests = [];
  for (var i = 0; i < files.length; i++) {
    String fileName = files[i];
    pendingRequests.add(
      preloader.getContent(fileName, () {
        return getFile(fileName, () => Future.value(idToken));
      }),
    );
  }
  var results = await Future.wait(pendingRequests);
  for (var i = 0; i < files.length; i++) {
    String fileName = files[i];
    String text = results[i];
    var note = Note(fileName, getTitleFromPath(fileName), text);
    notes.add(note);
  }
  return notes;
}

void preloadNotes(List<String> files, String idToken) async {
  for (var i = 0; i < files.length; i++) {
    String fileName = files[i];
    preloader.preloadContent(fileName, () {
      return getFile(fileName, () => Future.value(idToken));
    });
  }
}

@immutable
class LoadNoteContent implements Command {
  final String fileName;

  const LoadNoteContent(this.fileName);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        var text = await preloader.getContent(fileName, () {
          return getFile(fileName, () => Future.value(idToken.raw));
        });
        dispatch(NotePageViewNoteContentLoaded(fileName, text));
      }
    } catch (err) {
      dispatch(NotePageViewNoteContentLoadingFailed(err.toString()));
    }
  }
}

@immutable
class PreloadNoteContent implements Command {
  final List<String> files;
  final int currentFileIdx;

  const PreloadNoteContent(this.files, this.currentFileIdx);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        if (currentFileIdx > 0) {
          preloader.preloadContent(files[currentFileIdx - 1], () {
            return getFile(
              files[currentFileIdx - 1],
              () => Future.value(idToken.raw),
            );
          });
        }
        if (currentFileIdx < files.length - 1) {
          preloader.preloadContent(files[currentFileIdx + 1], () {
            return getFile(
              files[currentFileIdx + 1],
              () => Future.value(idToken.raw),
            );
          });
        }
      }
    } catch (err) {
      // Ignore
    }
  }
}

@immutable
class InvalidatePreloadedContent implements Command {
  final String fileName;

  const InvalidatePreloadedContent(this.fileName);

  @override
  void execute(void Function(Message) dispatch) async {
    preloader.dropPreload(fileName);
  }
}

// New notes are created as .md
@immutable
class SaveNewNote implements Command {
  final String title;
  final String text;

  const SaveNewNote(this.title, this.text);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        String path;
        if (title.isEmpty) {
          path = generatePathFromTitleMd("", true);
        } else {
          path = generatePathFromTitleMd(title, false);
        }

        try {
          // Don't overwrite, in case not unique
          await postFile(path, text, () => Future.value(idToken.raw));
        } catch (err) {
          if (err is RestApiException && err.statusCode == 409) {
            // Regenerate path from title, this time enfocing uniqueness
            path = generatePathFromTitleMd(title, true);
            try {
              await putFile(path, text, () => Future.value(idToken.raw));
            } catch (err) {
              dispatch(
                SavingNewNoteWithUniquePathFailed(path, text, err.toString()),
              );
              return;
            }
          } else {
            dispatch(SavingNewNoteFailed(title, text, err.toString()));
            return;
          }
        }

        // Here we forget about the path, since we will re-load all notes anyway
        dispatch(NewNoteSaved());
      }
    } catch (err) {
      dispatch(SavingNewNoteFailed(title, text, err.toString()));
    }
  }
}

@immutable
class SaveNewNoteWithUniquePath implements Command {
  final String path;
  final String text;

  const SaveNewNoteWithUniquePath(this.path, this.text);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        await putFile(path, text, () => Future.value(idToken.raw));
        dispatch(NewNoteSaved());
      }
    } catch (err) {
      dispatch(SavingNewNoteWithUniquePathFailed(path, text, err.toString()));
    }
  }
}

// Saving existing note doesn't change the file format
// (.md is renamed to .md, .txt to .txt)
@immutable
class SaveNote implements Command {
  final String path;
  final String title;
  final String text;
  final String oldTitle;
  final String oldText;

  const SaveNote(this.path, this.title, this.text, this.oldTitle, this.oldText);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        // First save text
        await putFile(path, text, () => Future.value(idToken.raw));

        var isMarkdown = isMarkdownFile(path);

        // Now rename, if needed
        if (title != oldTitle) {
          // First time try with path derived from title
          // Unless title is empty, in which case we immediately ask for a unique one
          String newPath =
              isMarkdown
                  ? generatePathFromTitleMd(title, title.isEmpty)
                  : generatePathFromTitleText(title, title.isEmpty);

          try {
            await renameFile(path, newPath, () => Future.value(idToken.raw));
            dispatch(NoteSaved(Note(newPath, title, text)));
          } catch (err) {
            if (err is RestApiException && err.statusCode == 409) {
              // Regenerate path from title, this time focing uniqueness
              newPath =
                  isMarkdown
                      ? generatePathFromTitleMd(title, true)
                      : generatePathFromTitleText(title, true);
              try {
                await renameFile(
                  path,
                  newPath,
                  () => Future.value(idToken.raw),
                );
                dispatch(NoteSaved(Note(newPath, title, text)));
              } catch (err) {
                dispatch(
                  RenamingNoteWithUniquePathFailed(
                    path,
                    newPath,
                    title,
                    text,
                    err.toString(),
                  ),
                );
              }
            } else {
              dispatch(
                RenamingNoteFailed(path, newPath, title, text, err.toString()),
              );
              return;
            }
          }
        } else {
          dispatch(NoteSaved(Note(path, title, text)));
        }
      }
    } catch (err) {
      dispatch(
        SavingNoteFailed(path, title, text, oldTitle, oldText, err.toString()),
      );
    }
  }
}

// This can only happen upon retry,
// since the saving and renaming is normally combined
// Renaming doesn't change the file format
// (.md is renamed to .md, .txt to .txt)
@immutable
class RenameNote implements Command {
  final String path;
  final String newPath;
  final String title;
  final String text;

  const RenameNote(this.path, this.newPath, this.title, this.text);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        try {
          await renameFile(path, newPath, () => Future.value(idToken.raw));
          dispatch(NoteSaved(Note(newPath, title, text)));
        } catch (err) {
          if (err is RestApiException && err.statusCode == 409) {
            // Regenerate path from title, this time focing uniqueness
            var isMarkdown = isMarkdownFile(path);
            String newUniquePath =
                isMarkdown
                    ? generatePathFromTitleMd(title, true)
                    : generatePathFromTitleText(title, true);
            try {
              await renameFile(
                path,
                newUniquePath,
                () => Future.value(idToken.raw),
              );
              dispatch(NoteSaved(Note(newUniquePath, title, text)));
            } catch (err) {
              dispatch(
                RenamingNoteWithUniquePathFailed(
                  path,
                  newUniquePath,
                  title,
                  text,
                  err.toString(),
                ),
              );
            }
          } else {
            dispatch(
              RenamingNoteFailed(path, newPath, title, text, err.toString()),
            );
            return;
          }
        }
      }
    } catch (err) {
      dispatch(RenamingNoteFailed(path, newPath, title, text, err.toString()));
    }
  }
}

@immutable
class RenameNoteWithUniquePath implements Command {
  final String path;
  final String newPath;
  final String title;
  final String text;

  const RenameNoteWithUniquePath(
    this.path,
    this.newPath,
    this.title,
    this.text,
  );

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        await renameFile(path, newPath, () => Future.value(idToken.raw));
        dispatch(NoteSaved(Note(newPath, title, text)));
      }
    } catch (err) {
      dispatch(
        RenamingNoteWithUniquePathFailed(
          path,
          newPath,
          title,
          text,
          err.toString(),
        ),
      );
    }
  }
}

@immutable
class DeleteAccount implements Command {
  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        await deleteAllFiles(() => Future.value(idToken.raw));
        clearAllCaches();
        killSession();
        await Amplify.Auth.deleteUser();
      }
    } catch (err) {
      dispatch(DeletingAccountFailed(err.toString()));
    }
  }
}

@immutable
class DeleteNote implements Command {
  final Note note;

  const DeleteNote(this.note);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        await deleteFile(note.fileName, () => Future.value(idToken.raw));
        dispatch(NoteListViewNoteDeleted(note));
      }
    } catch (err) {
      dispatch(NoteListViewDeletingNoteFailed(note, err.toString()));
    }
  }
}

@immutable
class RestoreNote implements Command {
  final Note note;

  const RestoreNote(this.note);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        try {
          // Try to restore with exactly the same path as before, don't overwrite
          await postFile(
            note.fileName,
            note.text,
            () => Future.value(idToken.raw),
          );
        } catch (err) {
          if (err is RestApiException && err.statusCode == 409) {
            var isMarkdown = isMarkdownFile(note.fileName);

            // The path that suddenly is taken (almost unrealistic)
            // Regenerate path from title, this time enfocing uniqueness
            String newPath =
                isMarkdown
                    ? generatePathFromTitleMd(note.fileName, true)
                    : generatePathFromTitleText(note.fileName, true);
            try {
              await putFile(
                newPath,
                note.text,
                () => Future.value(idToken.raw),
              );
              dispatch(NoteListViewNoteRestoredOnNewPath(note, newPath));
              return;
            } catch (err) {
              dispatch(
                NoteListViewRestoringNoteOnNewPathFailed(
                  note,
                  newPath,
                  err.toString(),
                ),
              );
              return;
            }
          } else {
            dispatch(NoteListViewRestoringNoteFailed(note, err.toString()));
            return;
          }
        }

        dispatch(NoteListViewNoteRestored(note));
      }
    } catch (err) {
      dispatch(NoteListViewRestoringNoteFailed(note, err.toString()));
    }
  }
}

@immutable
class RestoreNoteWithOnNewPath implements Command {
  final Note note;
  final String newPath;

  const RestoreNoteWithOnNewPath(this.note, this.newPath);

  @override
  void execute(void Function(Message) dispatch) async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      if (session.isSignedIn) {
        var idToken = session.userPoolTokensResult.value.idToken;

        await putFile(newPath, note.text, () => Future.value(idToken.raw));
        dispatch(NoteListViewNoteRestoredOnNewPath(note, newPath));
      }
    } catch (err) {
      dispatch(
        NoteListViewRestoringNoteOnNewPathFailed(note, newPath, err.toString()),
      );
    }
  }
}
