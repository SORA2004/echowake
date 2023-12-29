import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> searchResults = []; // 검색 결과를 저장할 리스트
  List<String> searchHistory = []; // 검색 기록을 저장할 리스트
  bool showSearchHistory = true; // 검색 기록 표시 여부

  void search(String query) {
    setState(() {
      searchHistory.remove(query);
      searchHistory.insert(0, query);
      showSearchHistory = false;
    });
  }

  void clearSearchHistory() {
    setState(() {
      searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Container(
          width: screenWidth * 0.7,
          height: 35.0,
          child: TextField(
            style: TextStyle(color: Colors.black),
            onSubmitted: search,
            decoration: InputDecoration(
              hintText: 'Blissom 검색..',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 검색 기록',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: clearSearchHistory,
                  child: Text(
                    '전체 삭제',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Text(
              '내가 자주 듣는 작품',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 내가 자주 듣는 작품 리스트
          Expanded(
            child: ListView.builder(
              itemCount: searchHistory.length + 5, // 예시를 위해 검색 기록 + 5개 항목
              itemBuilder: (context, index) {
                if (index < searchHistory.length) {
                  // 검색 기록 표시
                  return ListTile(
                    title: Text(searchHistory[index]),
                    onTap: () => search(searchHistory[index]),
                  );
                } else {
                  // '내가 자주 듣는 작품' 항목 표시
                  return ListTile(
                    leading: Icon(Icons.music_note),
                    title: Text('곡 제목 ${index - searchHistory.length}'),
                    subtitle: Text('아티스트 ${index - searchHistory.length}'),
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}