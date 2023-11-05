import 'package:flutter/cupertino.dart';
import 'alarm_page.dart';
import 'package:flutter/material.dart';

class AlarmSettingPage extends StatefulWidget {
  final Function(Alarm) onAlarmSaved;
  final Alarm? initialAlarm;

  AlarmSettingPage({required this.onAlarmSaved, this.initialAlarm});

  @override
  _AlarmSettingPageState createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  late TimeOfDay selectedTime;
  late Alarm _editedAlarm;

  double volume = 0.5;
  bool repeat = false;
  late int _selectedHour;
  late int _selectedMinute;
  List<bool> days = [false, false, false, false, false, false, false];
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAlarm != null) {
      selectedTime = widget.initialAlarm!.time;
      volume = widget.initialAlarm!.volume;
      _editedAlarm = widget.initialAlarm ?? Alarm(time: selectedTime, days: days, title: '');
      repeat = widget.initialAlarm!.repeat;
      _selectedHour = selectedTime.hour;
      _selectedMinute = selectedTime.minute;
      days = widget.initialAlarm!.days;
      titleController.text = widget.initialAlarm!.title;
    }

    else {
      selectedTime = TimeOfDay.now();
      _selectedHour = DateTime.now().hour;
      _selectedMinute = DateTime.now().minute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알람 설정"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Alarm alarm = Alarm(
                time: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                volume: volume,
                repeat: repeat,
                days: days,
                title: titleController.text,
              );
              widget.onAlarmSaved(alarm);
              Navigator.pop(context, alarm);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(height: 25.0),
          Text(
            "시간",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            height: 320,
            // 아래의 body: 를 삭제하고 바로 Row를 시작합니다.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: [
                Container(
                  width: 100,
                  child: CupertinoPicker(
                    itemExtent: 60.0,  // <-- itemExtent 값을 조절합니다.
                    looping: true,
                    onSelectedItemChanged: (selectedIndex) {
                      setState(() {
                        _selectedHour = selectedIndex;
                      });
                    },
                    children: List<Widget>.generate(24, (index) {
                      return Center(child: Text("$index", style: TextStyle(fontSize: 35)));  // <-- 숫자 크기를 35로 설정
                    }),
                  ),
                ),
                SizedBox(width: 10),
                Text(":", style: TextStyle(fontSize: 35)),  // <-- ":" 크기를 35로 설정
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: CupertinoPicker(
                    itemExtent: 60.0,  // <-- itemExtent 값을 조절합니다.
                    looping: true,
                    onSelectedItemChanged: (selectedIndex) {
                      setState(() {
                        _selectedMinute = selectedIndex;
                      });
                    },
                    children: List<Widget>.generate(60, (index) {
                      return Center(child: Text(index.toString().padLeft(2, '0'), style: TextStyle(fontSize: 35)));  // <-- 숫자 크기를 35로 설정
                    }),
                  ),
                ),

              ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Text("반복"),
                SizedBox(width: 20),
                Checkbox(
                  value: repeat,
                  onChanged: (newValue) {
                    setState(() {
                      repeat = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          ListTile(
            title: Text("요일 선택"),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return ChoiceChip(
                  label: Text(
                    ['월', '화', '수', '목', '금', '토', '일'][index],
                    style: TextStyle(
                        color: days[index] ? Colors.white : Colors.black),
                  ),
                  selected: days[index],
                  onSelected: (bool selected) {
                    setState(() {
                      days[index] = selected;
                    });
                  },
                );
              }),
            ),
          ),
          ListTile(
            title: Text("알람 이름"),
            subtitle: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "알람 이름을 입력하세요",
              ),
            ),
          ),
          ListTile(
            title: Text("볼륨"),
            subtitle: Slider(
              value: volume,
              onChanged: (newVolume) {
                setState(() {
                  volume = newVolume;
                });
              },
              min: 0.4,      // 최소 볼륨을 40%로 설정
              max: 1.0,
              divisions: 6,  // 40, 50, 60, 70, 80, 90, 100 - 총 7단계로 나눔
              label: "${(volume * 100).toInt()}%",
            ),
          ),
        ],
      ),
    );
  }
}

class Alarm {
  TimeOfDay time;
  double volume;
  bool isOn;
  bool repeat;
  List<bool> days; // 알람 제목
  String title;

  Alarm({
    required this.time,
    this.volume = 0.5,
    this.isOn = true,
    this.repeat = false,
    required this.days,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
    'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    'volume': volume,
    'repeat': repeat,
    'days': days,
    'title': title,
    'isOn': isOn,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    time: TimeOfDay(
        hour: int.parse(json['time'].split(':')[0]),
        minute: int.parse(json['time'].split(':')[1])),
    volume: json['volume'].toDouble(),
    repeat: json['repeat'],
    days: (json['days'] as List).cast<bool>(),
    title: json['title'],
    isOn: json['isOn'],
  );
}