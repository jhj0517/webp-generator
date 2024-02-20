import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/ffmpeg_converter.dart';

abstract class FFmpegEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ConvertFile extends FFmpegEvent {
  final XFile file;

  ConvertFile({required this.file});

  @override
  List<Object> get props => [file];
}

class CancelConversion extends FFmpegEvent {}

abstract class FFmpegJobState extends Equatable {
  @override
  List<Object> get props => [];
}

class JobInitial extends FFmpegJobState {}

class JobWorking extends FFmpegJobState {
  final int progress; // Progress as an integer percentage

  JobWorking({required this.progress});

  @override
  List<Object> get props => [progress];
}

class JobCompleted extends FFmpegJobState {
  final XFile file;

  JobCompleted({required this.file});

  @override
  List<Object> get props => [file];
}

class JobError extends FFmpegJobState {
  final String message;

  JobError({required this.message});

  @override
  List<Object> get props => [message];
}

class HomeBloc extends Bloc<FFmpegEvent, FFmpegJobState> {
  HomeBloc() : super(JobInitial()) {
    on<ConvertFile>(_onConvertFile);
    on<CancelConversion>(_onCancelConversion);
  }

  Future<void> _onConvertFile(ConvertFile event, Emitter<FFmpegJobState> emit) async {
    emit(JobWorking(progress: 0));
    try {
      // Wrap the call to convertVideoToWebp with progress handling logic
      await convertVideoToWebp(
        event.file.path,
        frame: 0,
        onProgress: (int progress) {
          // Emit progress state
          emit(JobWorking(progress: progress));
        },
      ).then((output) {
        // Assuming convertVideoToWebp is adjusted to return the outputPath
        // outputPath = output; // Capture the output path from the conversion
      });
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }


  Future<void> _onCancelConversion(CancelConversion event, Emitter<FFmpegJobState> emit) async {
    emit(JobInitial()); // Revert to initial state or handle as needed
  }
}
