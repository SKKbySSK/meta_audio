import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta_audio/meta_audio.dart';
import 'package:meta_audio/metadata.dart';
import 'package:meta_audio_example/asset_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = true;
  Metadata _metadata;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final parser = MetaAudio();

    final path = await AssetManager.exportMusicFile();
    final metadata = await parser.parse(path);

    setState(() {
      _loading = false;
      _metadata = metadata;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('meta_audio'),
        ),
        body: _loading ? _buildLoading() : _buildMetadataViewer(),
      ),
    );
  }

  Center _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        value: null,
      ),
    );
  }

  Widget _buildMetadataViewer() {
    if (_metadata == null) {
      return Center(
        child: Text('Unable to read metadata'),
      );
    }

    return MetadataViewer(
      metadata: _metadata,
    );
  }
}

class MetadataViewer extends StatelessWidget {
  const MetadataViewer({
    Key key,
    this.metadata,
  }) : super(key: key);
  final Metadata metadata;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        buildArtwork(),
        buildItem('Title', metadata.title),
        buildItem('Album', metadata.album),
        buildItem('Artist', metadata.artist),
        buildItem('Genre', metadata.genre),
        buildItem('Composer', metadata.composer),
        buildItem('Duration', metadata.duration),
        buildItem('Track', metadata.trackNumber),
        buildItem('Track Count', metadata.trackCount),
        buildItem('Year', metadata.year),
        buildItem('Path', metadata.path),
      ],
    );
  }

  Widget buildArtwork() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: FutureBuilder<Uint8List>(
                future: getArtworkData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == null) {
                      return Center(
                        child: Text('No Artwork'),
                      );
                    } else {
                      return Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 5), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Image.memory(snapshot.data),
                      );
                    }
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      value: null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  Future<Uint8List> getArtworkData() async {
    final artwork = await metadata.artwork;
    if (!artwork.exists) {
      return null;
    }

    return await artwork.data();
  }

  Widget buildItem(String name, dynamic value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  name?.toString() ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  value?.toString() ?? '',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
