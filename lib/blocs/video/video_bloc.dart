import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../models/video_model.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  VideoBloc() : super(VideoInitial()) {
    on<VideoEvent>((event, emit) async {
      if (event is FetchEvent) {
        emit(
          VideoLoading(),
        );
        try {
          // Firestore에서 데이터 가져오기 (실시간 스트림)
          Stream<QuerySnapshot<Map<String, dynamic>>> stream =
          _firestore.collection('posts').snapshots();

          await for (QuerySnapshot<Map<String, dynamic>> snapshot in stream) {
            List<VideoModel> posts = snapshot.docs
                .map((doc) => VideoModel.fromFirestore(doc))
                .toList();

            // 데이터 변경이 감지되면 새로운 상태로 업데이트
            emit(VideoLoaded(posts: posts));
          }
        } catch (e) {
          emit(
            const VideoError(
              message: '불러오기 실패하였습니다.',
            ),
          );
        }
      }
    });
  }
}