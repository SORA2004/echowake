import 'package:echowake/models/audio_model.dart';
import 'package:echowake/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/audio/audio_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final AudioBloc _bloc = AudioBloc();

  void reloadData() {
    // VideoBloc에 새로운 FetchEvent 추가
    _bloc.add(FetchEvent());
  }

  // 여기에서 VideoPlayerController 선언 및 초기화 필요 (만약 비디오를 재생할 경우)

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchEvent());
    WidgetsBinding.instance.addObserver(this); // this는 이제 WidgetsBindingObserver입니다.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // this는 이제 WidgetsBindingObserver입니다.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bloc.add(FetchEvent()); // 앱이 화면에 다시 나타나면 데이터 새로 고침
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/AppIcon-1024x+(7).png'), // 앱 아이콘 추가
        ),
        title: const Text(
          'Blissom', // 앱 이름 추가
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true, // 제목을 중앙에 배치
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchPage(), // 검색 페이지로 이동
              ));
            },
          ),
        ],
      ),
      body: BlocBuilder<AudioBloc, AudioState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is AudioLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AudioLoaded) {
            return state.posts.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return HomeTile(post: post);
              },
            )
                : const Center(
              child: Text('여러분의 멋진 음악을 들려주세요!'),
            );
          } else {
            return Center(child: Text('데이터를 불러오는데 실패했습니다.'));
          }
        },
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}

class HomeTile extends StatelessWidget {
  final AudioModel post;

  const HomeTile({
    super.key,
    required this.post,
  });

  @override
  bool get wantKeepAlive => true; // 상태 유지

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFFC2E1FC),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFFD9D9D9),
            ),
            child: Image.network(
              post.videoThumbnailUrl,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFD9D9D9),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${post.title}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        '프로필 닉네임',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.circle,
                        size: 5,
                        color: Color(0xFFB2B2B2),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '조회수 ${post.viewCount}명',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.circle,
                        size: 5,
                        color: Color(0xFFB2B2B2),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '좋아요 ${post.likeCount}명',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Icon(
                Icons.favorite,
                size: 36,
              ),
              Icon(
                Icons.more_vert,
                size: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }
}