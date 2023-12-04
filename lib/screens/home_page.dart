import 'package:echowake/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/video/video_bloc.dart';
import '../widgets/tiles/home_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final VideoBloc _bloc = VideoBloc();

  // 여기에서 VideoPlayerController 선언 및 초기화 필요 (만약 비디오를 재생할 경우)

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchEvent()); // 데이터를 가져오기 위한 이벤트를 추가합니다.
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocBuilder<VideoBloc, VideoState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is VideoLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VideoLoaded) {
            return state.posts.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                return HomeTile(
                  thumbnailUrl: post.thumbnailUrl,
                  profileUrl: post.profileUrl,
                  profileName: post.profileName,
                  title: post.title,
                  viewCount: post.viewCount,
                  likeCount: post.likeCount,
                );
              },
            )
                : const Center(
              child: Text('업로드된 데이터가 없습니다.'),
            );
          } else {
            return Center(
                child: Text('데이터를 불러오는데 실패했습니다.'));
          }
        },
      ),
    );
  }
}

class HomeTile extends StatelessWidget {
  final String thumbnailUrl;

  const HomeTile({Key? key, required this.thumbnailUrl, /* 다른 필드들... */}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card의 내용...
      child: Column(
        children: [
          Image.network(thumbnailUrl, fit: BoxFit.cover),
          // 다른 위젯들...
        ],
      ),
    );
  }
}