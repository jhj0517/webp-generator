import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:ffmpeg_kit_flutter/statistics_callback.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';


Future<void> convertVideoToWebp(String inputPath, {int frame = 0, required Function(int) onProgress}) async {
  // FFmpeg command
  // `-i` specifies the input file
  // -vf` applies a filter with `select` to choose a specific frame (`eq(n,0)` selects the first frame)
  // `-vframes` specifies the number of frames to output (1, since we're converting to a single image)

  StatisticsCallback statisticsCallback = (Statistics statistics) {
    // Update progress. This simply updates with frame number
    onProgress(statistics.getVideoFrameNumber());
  };

  FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);

  final outputPath = p.join(Directory.systemTemp.path, 'tempimage.webp');
  final file = File(outputPath);
  await file.create();

  String command = '-i $inputPath -vf "select=eq(n,$frame)" -vframes 1 -y $outputPath';
  String testCommand = '-y -i $inputPath -c:v copy -c:a copy $outputPath';

  await FFmpegKit.execute(testCommand).then((session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      onProgress(100);
    } else if (ReturnCode.isCancel(returnCode)) {
      onProgress(0);
    } else {
      final failStackTrace = await session.getFailStackTrace();
      debugPrint("FFmpeg failed with return code $returnCode and stack trace: $failStackTrace");
      debugPrint("inputPath :$inputPath , outputPath :$outputPath");
      onProgress(-1); // error
      return;
    }
  });
  FFmpegKitConfig.disableStatistics();

  // Save temp image into Gallery
  final result = await ImageGallerySaver.saveFile(
    outputPath,
    name: "test.webp",
    isReturnPathOfIOS: true
  );
  debugPrint("result : ${result}");
}

