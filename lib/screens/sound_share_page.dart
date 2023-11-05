import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';

class Sound {
  String id;
  String title;
  String profileName;
  int likes;
  List<String> likedBy;
  String audioUrl;
  String profileImageUrl;
  String category;
  List<String> tags;
  String downloadUrl;

  Sound({
    required this.id,
    required this.title,
    required this.profileName,
    required this.likes,
    required this.likedBy,
    required this.audioUrl,
    required this.profileImageUrl,
    required this.category,
    required this.tags,
    required this.downloadUrl,
  });

  bool get isLiked => likedBy.contains(FirebaseAuth.instance.currentUser?.uid);

  void toggleLike() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      if (isLiked) {
        likedBy.remove(userId);
        likes -= 1;
      } else {
        likedBy.add(userId);
        likes += 1;
      }
    }
  }
}


class SoundCard extends StatefulWidget {
  final Sound sound;

  SoundCard({required this.sound});

  @override
  _SoundCardState createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setSource(UrlSource(widget.sound.audioUrl));
      await _audioPlayer.resume();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.sound.profileImageUrl),
              radius: 30,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sound.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(widget.sound.profileName),
                ],
              ),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlay,
            ),
            IconButton(
              icon: Icon(
                widget.sound.isLiked ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () {
                widget.sound.toggleLike();
                setState(() {});
              },
            ),
            Text('${widget.sound.likes}'),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () {
                // 다운로드 기능을 여기에 구현하세요.
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class SoundSharePage extends StatefulWidget {
  @override
  _SoundSharePageState createState() => _SoundSharePageState();
}

class _SoundSharePageState extends State<SoundSharePage> {
  List<Sound> sounds = [];
  List<Sound> filteredSounds = [];
  String searchQuery = ''; // 검색 쿼리를 저장할 상태 변수

  @override
  void initState() {
    super.initState();
    _loadSoundsFromFirestore();
    _updateSoundsCategoryAndTags();
  }

  Future<void> _updateSoundsCategoryAndTags() async {
    CollectionReference soundsCollection = FirebaseFirestore.instance.collection('audio_files');
    QuerySnapshot querySnapshot = await soundsCollection.get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // 각 문서에 대해 카테고리와 태그를 업데이트합니다.
      await soundsCollection.doc(doc.id).update({
        'category': 'Music', // 예시로 'Music'을 설정합니다.
        'tags': ['relax', 'instrumental'], // 예시 태그를 설정합니다.
      });
    }
  }

  Future<void> _loadSoundsFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
        'audio_files').get();

    List<Sound> loadedSounds = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      Sound sound = Sound(
        id: doc.id,
        title: data['title'],
        profileName: data['profileName'],
        likes: data['likes'],
        likedBy: List<String>.from(data['likedBy'] ?? []),
        audioUrl: data['audioUrl'],
        profileImageUrl: data['profileImageUrl'],
        category: data['category'] ?? '', // 기본값으로 빈 문자열을 설정
        tags: List<String>.from(data['tags'] ?? []), downloadUrl: '', // 기본값으로 빈 리스트를 설정
      );
      loadedSounds.add(sound);
    }

    setState(() {
      sounds = loadedSounds; // 상태 변수를 업데이트
      _updateSearchQuery(searchQuery);
    });
  }

  void _toggleLike(Sound sound) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final isLiked = sound.likedBy.contains(userId);
      setState(() {
        if (isLiked) {
          sound.likedBy.remove(userId);
          sound.likes -= 1;
        } else {
          sound.likedBy.add(userId);
          sound.likes += 1;
        }
      });

      // Firestore 데이터베이스 업데이트
      FirebaseFirestore.instance.collection('audio_files').doc(sound.id).update({
        'likedBy': sound.likedBy,
        'likes': sound.likes,
      });
    }
  }

  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredSounds = sounds.where((sound) {
        final queryLower = query.toLowerCase();
        final titleContains = sound.title.toLowerCase().contains(queryLower);
        final profileNameContains = sound.profileName.toLowerCase().contains(queryLower);
        final categoryContains = sound.category.toLowerCase().contains(queryLower);
        final tagsContains = sound.tags.any((tag) => tag.toLowerCase().contains(queryLower));
        return titleContains || profileNameContains || categoryContains || tagsContains;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30, // 프로필 사진 크기 증가
                  backgroundColor: Colors.grey, // 임시 색상
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text('안녕하세요,', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    Text('프로필 이름', style: TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '알람에 설정할 많은 소리를 찾아보세요!',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: _updateSearchQuery,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
            child: Text(
              '카테고리',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 20),
                _buildCategoryCard('자연', 'assets/images/nature.jpg'),
                SizedBox(width: 10),
                _buildCategoryCard('동물', 'assets/images/animals.jpg'), // 동물 카테고리 추가
                SizedBox(width: 20),
                _buildCategoryCard('동기부여', 'assets/images/nature.jpg'),
                SizedBox(width: 20),
                _buildCategoryCard('쓴소리', 'assets/images/nature.jpg'),
                // ... 추가 카테고리 카드
              ],
            ),
          ),
          // ... 나머지 UI 요소
          Expanded(
            child: ListView.builder(
              itemCount: searchQuery.isEmpty ? sounds.length : filteredSounds.length,
              itemBuilder: (context, index) {
                Sound sound = searchQuery.isEmpty ? sounds[index] : filteredSounds[index];
                return SoundCard(sound: sound);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSoundPage()),
          ).then((value) {
            _loadSoundsFromFirestore(); // 데이터를 다시 로드합니다.
          });
        },
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return Container(
      width: 120, // 너비를 120으로 설정
      height: 120, // 높이를 120으로 설정
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0), // 왼쪽 패딩 추가
        child: Align(
          alignment: Alignment.centerLeft, // 왼쪽 정렬
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black, // 글씨 색상을 검정색으로 설정
            ),
          ),
        ),
      ),
    );
  }
}

class AddSoundPage extends StatefulWidget {
  @override
  _AddSoundPageState createState() => _AddSoundPageState();
}

class _AddSoundPageState extends State<AddSoundPage> {
  String title = '';
  String profileName = '';
  int likes = 0;
  bool isLiked = false;
  String profileImageUrl = '';
  String? audioPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Profile Name'),
              onChanged: (value) {
                setState(() {
                  profileName = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement audio recording
              },
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: () {
                if (audioPath != null) {
                  _uploadAudioFile();
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAudioFile() async {
    File audioFile = File(audioPath!);

    String fileName = basename(audioFile.path);
    Reference ref = FirebaseStorage.instance.ref().child('audio_files/$fileName');
    UploadTask uploadTask = ref.putFile(audioFile);
    await uploadTask.whenComplete(() async {
      String downloadUrl = await ref.getDownloadURL();
      _saveSoundToFirestore(downloadUrl);
    });
  }

  void _saveSoundToFirestore(String audioUrl) {
    FirebaseFirestore.instance.collection('audio_files').add({
      'title': title,
      'profileName': profileName,
      'likes': likes,
      'isLiked': isLiked,
      'audioUrl': audioUrl,
      'profileImageUrl': profileImageUrl,
    });
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  CategoryCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        leading: Image.network(imageUrl),
        onTap: () {
          // 카테고리 클릭 시 로직 (예: 해당 카테고리의 사운드 목록으로 이동)
        },
      ),
    );
  }
}
