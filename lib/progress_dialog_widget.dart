import 'package:video_compress/video_compress.dart';
import 'package:flutter/material.dart';

class ProgressDilogWidget extends StatefulWidget {
  const ProgressDilogWidget({super.key});

  @override
  State<ProgressDilogWidget> createState() => _ProgressDilogWidgetState();
}

class _ProgressDilogWidgetState extends State<ProgressDilogWidget> {
  late Subscription subscription;
  double? progress;

  @override
  void initState() {
    super.initState();

    subscription = VideoCompress.compressProgress$
        .subscribe((progress) => setState(() => this.progress = progress));
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression();
    subscription.unsubscribe();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = progress == null ? progress : progress! / 100;
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Compressing Video ...', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          LinearProgressIndicator(value: value, minHeight: 12),
          const SizedBox(height: 16),
          ElevatedButton(
            child: Text('Cancel'),
            onPressed: () => VideoCompress.cancelCompression(),
          ),
        ],
      ),
    );
  }
}
