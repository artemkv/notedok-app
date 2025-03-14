import 'package:flutter/material.dart';

@immutable
class FileData {
  final String fileName;
  final String lastModified;
  final String etag;

  const FileData(this.fileName, this.lastModified, this.etag);

  FileData.fromJson(Map<String, dynamic> json)
    : fileName = json['fileName'],
      lastModified = json['lastModified'],
      etag = json['etag'];
}

@immutable
class GetFilesResponse {
  final List<FileData> files;
  final bool hasMore;
  final String nextContinuationToken;

  const GetFilesResponse(this.files, this.hasMore, this.nextContinuationToken);

  GetFilesResponse.fromJson(Map<String, dynamic> json)
    : files = (json['files'] as List).map((x) => FileData.fromJson(x)).toList(),
      hasMore = json['hasMore'],
      nextContinuationToken = json['nextContinuationToken'];
}

@immutable
class Note {
  final String fileName;
  final String title;
  final String text;

  const Note(this.fileName, this.title, this.text);

  const Note.empty() : fileName = "", title = "", text = "";

  @override
  bool operator ==(Object other) {
    return other is Note &&
        fileName == other.fileName &&
        title == other.title &&
        text == other.text;
  }

  @override
  int get hashCode => Object.hash(fileName, title, text);
}
