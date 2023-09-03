import 'dart:io';
import 'dart:typed_data';
import 'package:compresee_app/progress_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'api/video_compress_api.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Compression App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? fileVideo;
  Uint8List? thumbnailBytes;
  int? videoSize;
  MediaInfo? compressedVideoInfo;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Video Compress'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: clearSelection,
              child: Text('Clear'),
              style: TextButton.styleFrom(primary: Colors.white),
            )
          ],
        ),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(40),
          child: buildContent(),
        ),
      );

  Widget buildContent() {
    if (fileVideo == null) {
      return ElevatedButton(
        child: Text('Pick Video'),
        onPressed: pickVideo,
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildThumbnail(),
          const SizedBox(height: 24),
          buildVideoInfo(),
          const SizedBox(height: 24),
          buildVideoCompressedInfo(),
          const SizedBox(height: 24),
          ElevatedButton(
            child: Text('Compress Video'),
            onPressed: compressVideo,
          ),
        ],
      );
    }
  }

  Widget buildThumbnail() => thumbnailBytes == null
      ? CircularProgressIndicator()
      : Image.memory(thumbnailBytes!, height: 100);
  Widget buildVideoInfo() {
    if (videoSize == null) return Container();
    final size = videoSize! / 1000;
    return Column(
      children: [
        const Text(
          'Original Video Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Size: $size  KB',
          style: TextStyle(fontSize: 20),
        )
      ],
    );
  }

  Widget buildVideoCompressedInfo() {
    if (compressedVideoInfo == null) return Container();
    final size = compressedVideoInfo!.filesize! / 1000;

    return Column(
      children: [
        const Text('Compressed Video Info',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Size: $size KB', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(
          '${compressedVideoInfo!.path}',
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  void clearSelection() => setState(() {
        compressedVideoInfo = null;
        fileVideo = null;
      });

  Future pickVideo() async {
    final picker = ImagePicker();
    final PickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (PickedFile == null) return;
    final file = File(PickedFile.path);
    setState(() => fileVideo = file);

    generateThumbnail(fileVideo!);
    getVideoSize(fileVideo!);
  }

  Future generateThumbnail(File file) async {
    final thumbnailBytes = await VideoCompress.getByteThumbnail(file.path);
    setState(() => this.thumbnailBytes = thumbnailBytes);
  }

  Future getVideoSize(File file) async {
    final size = await file.length();
    setState(() => videoSize = size);
  }

  Future compressVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(child: ProgressDilogWidget()),
    );
    final info = await VideoCompressApi.compressVideo(fileVideo!);
    setState(() => compressedVideoInfo = info);
    Navigator.of(context).pop();
  }
}
