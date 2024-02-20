import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/color_constants.dart';
import '../bloc/home_bloc.dart';
import '../utils/ffmpeg_converter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  XFile? _video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        title: const Text(
          "webp Generator",
          style: TextStyle(
            color: ColorConstants.fontColor
          ),
        ),
      ),
      body: Center(
        child: IconButton(
          icon: Icon(
            Icons.emergency_recording_sharp,
          ),
          onPressed: () async{
            await _pickVideo();
            await convertVideoToWebp(
              _video!.path,
              frame: 0,
              onProgress: (int progress) {
                debugPrint("Progress : ${progress}");
              }
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    // Pick an video
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _video = video;
    });
  }
}
