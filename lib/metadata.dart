import 'dart:typed_data';

import 'package:flutter/material.dart';

class ArtworkNotFoundException implements Exception {
  ArtworkNotFoundException({this.message = 'Artwork not found'});
  final String message;

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}

abstract class Artwork {
  bool get exists;
  Future<Uint8List> data();

  void throwIfNotExists() {
    if (!exists) {
      throw new ArtworkNotFoundException();
    }
  }
}

class Metadata {
  const Metadata({
    @required this.path,
    this.duration,
    this.title,
    this.album,
    this.artwork,
    this.artist,
    this.genre,
    this.composer,
    this.trackNumber,
    this.trackCount,
    this.year,
  });

  final String path;
  final Duration duration;

  final String title;
  final String album;
  final String artist;
  final String genre;
  final String composer;

  final int trackNumber;
  final int trackCount;

  final int year;

  final Future<Artwork> artwork;
}
