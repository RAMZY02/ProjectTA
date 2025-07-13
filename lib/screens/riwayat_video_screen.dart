import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/history_video/history_video_bloc.dart';
import 'package:project_ta/bloc/history_video/history_video_event.dart';
import 'package:project_ta/bloc/history_video/history_video_state.dart';
import 'package:project_ta/widgets/list_history_video.dart';

import '../constants/color.dart';
import 'detail_video_screen.dart';

class RiwayatVideoScreen extends StatelessWidget {
  const RiwayatVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Riwayat Video',
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.grey,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: BlocBuilder<HistoryVideoBloc, HistoryVideoState>(
        builder: (context, historyVideoState){
          if(authState is! Authenticated){
            return Text("Login Dulu Boss");
          }
          else if(historyVideoState is! HistoryVideoLoaded){
            context.read<HistoryVideoBloc>().add(FetchHistoryVideo(token: authState.token, userId: authState.id));
          }
          if(historyVideoState is HistoryVideoLoaded){
            return ListView.builder(
              itemCount: historyVideoState.historyVideos.length,
              itemBuilder: (context, index){
                final video = historyVideoState.historyVideos[index].video;
                return ListHistoryVideo(
                    video: video,
                    time: historyVideoState.historyVideos[index].timestamps,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailVideoScreen(
                            video: video,
                          ),
                        ),
                      );
                    }
                );
              }
            );
          }
          else{
            return CircularProgressIndicator();
          }
        }
      ),
    );
  }
}
