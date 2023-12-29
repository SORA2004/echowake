import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../models/audio_model.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AudioBloc() : super(AudioInitial()) {
    on<AudioEvent>((event, emit) async {
      if (event is FetchEvent) {
        emit(
          AudioLoading(),
        );
        try {
          // Firestore에서 데이터 가져오기 (실시간 스트림)
          Stream<QuerySnapshot<Map<String, dynamic>>> stream =
          _firestore.collection('posts').snapshots();

          await for (QuerySnapshot<Map<String, dynamic>> snapshot in stream) {
            List<AudioModel> posts = snapshot.docs
                .map((doc) => AudioModel.fromFirestore(doc))
                .toList();

            // 데이터 변경이 감지되면 새로운 상태로 업데이트
            emit(AudioLoaded(posts: posts));
          }
        } catch (e) {
          emit(
            const AudioError(
              message: '불러오기 실패하였습니다.',
            ),
          );
        }
      }
    });
  }
}