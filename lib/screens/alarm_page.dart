import 'package:flutter/material.dart';
import 'alarm_setting_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // 추가

Future<List<Alarm>> loadAlarms() async {
  final prefs = await SharedPreferences.getInstance();
  final alarmsString = prefs.getString('alarms') ?? '[]';
  final alarmsList = (jsonDecode(alarmsString) as List).cast<Map<String, dynamic>>();
  return alarmsList.map((e) => Alarm.fromJson(e)).toList();
}

Future<void> saveAlarms(List<Alarm> alarms) async {
  final prefs = await SharedPreferences.getInstance();
  final alarmsString = jsonEncode(alarms.map((e) => e.toJson()).toList());
  prefs.setString('alarms', alarmsString);
}

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAlarms();
  }

  _loadSavedAlarms() async {
    final loadedAlarms = await loadAlarms();
    setState(() {
      alarms = loadedAlarms;
    });
  }

  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알람 삭제'),
          content: Text('해당 알람을 정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  alarms.removeAt(index);
                  saveAlarms(alarms);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _daysToString(List<bool> days) {
    const dayNames = ["일", "월", "화", "수", "목", "금", "토"];
    List<String> selectedDays = [];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(dayNames[i]);
      }
    }
    return selectedDays.join(", ");
  }

  String _getAlarmMessage() {
    if (alarms.isEmpty || !alarms.any((alarm) => alarm.isOn)) {
      return "현재 예정된 알람이 없습니다.";
    } else {
      final now = DateTime.now();
      final nextAlarm = alarms.firstWhere((alarm) => alarm.isOn);
      final alarmDateTime = DateTime(now.year, now.month, now.day, nextAlarm.time.hour, nextAlarm.time.minute);
      final diff = alarmDateTime.difference(now);
      final remainingTime = DateFormat('HH:mm').format(DateTime(0).add(diff));
      return "$remainingTime 뒤에 알람이 울립니다.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Text(
              _getAlarmMessage(),
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  Alarm alarm = alarms[index];
                  String daysText;
                  if (alarm.days.every((day) => day)) {
                    daysText = "매일";
                  } else if (alarm.days.every((day) => !day)) {
                    daysText = "요일 설정 안됨";
                  } else {
                    daysText = _daysToString(alarm.days);
                  }
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
                    color: alarm.isOn ? Colors.white : Colors.grey[400], // 알람이 꺼져 있을 때의 배경색을 더 어둡게 변경
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      title: Text(
                        alarm.title,
                        style: TextStyle(
                          fontSize: 16 * 1.5,
                          fontWeight: FontWeight.bold,
                          color: alarm.isOn ? Colors.black : Colors.grey,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            "${alarm.time.format(context)}",
                            style: TextStyle(
                              fontSize: 28, // 폰트 크기를 조금 줄여 오버플로우 문제 해결
                              fontWeight: FontWeight.normal,
                              color: alarm.isOn ? Colors.black : Colors.grey,
                            ),
                          ),
                          SizedBox(width: 30), // 요일과 시간 사이 간격을 조금 줄임
                          Text(
                            daysText,
                            style: TextStyle(
                              fontSize: 14, // 폰트 크기를 조금 줄여 오버플로우 문제 해결
                              color: alarm.isOn ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: alarm.isOn,
                            onChanged: (bool value) {
                              setState(() {
                                alarm.isOn = value;
                                saveAlarms(alarms);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(index);
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        var editedAlarm = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlarmSettingPage(
                              onAlarmSaved: (alarm) {},
                              initialAlarm: alarm,
                            ),
                          ),
                        );
                        if (editedAlarm != null) {
                          setState(() {
                            alarms[index] = editedAlarm;
                            saveAlarms(alarms);
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlarmSettingPage(onAlarmSaved: (alarm) {
                setState(() {
                  alarms.add(alarm);
                  saveAlarms(alarms);
                });
              }),
            ),
          );
        },
      ),
    );
  }
}






