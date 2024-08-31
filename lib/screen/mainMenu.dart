import 'package:final_login/screen/edit_profile_page2.dart';
import 'package:final_login/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:final_login/constants/color.dart';
import 'package:final_login/data/evaluation.dart';
import 'package:final_login/screen/questionscreen.dart';
import 'package:final_login/screen/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MainMenu extends StatefulWidget {
  final String userName;
  final int userId;
  MainMenu({
    required this.userName,
    required this.userId,
  });

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late String userName;
  late String latestProgramName = 'ยังไม่มีนัดหมาย';
  late String latestAppointmentDate = '';
  List<String> existingAppointments = [];

  @override
  void initState() {
    super.initState();
    userName = widget.userName;

    _fetchLatestAppointment().then((data) {
      if (data != null) {
        setState(() {
          latestProgramName = data['program_name'];
          latestAppointmentDate =
              _formatDateToThai(DateTime.parse(data['appointment_date']));
        });
      }
    });

    _fetchExistingAppointments();
  }

  Future<Map<String, dynamic>?> _fetchLatestAppointment() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/appointments-with-date/${widget.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> appointments = jsonDecode(response.body);
      if (appointments.isNotEmpty) {
        return appointments.first;
      }
    }
    return null;
  }

  Future<void> _fetchExistingAppointments() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/appointments-date-all/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> appointments = jsonDecode(response.body);
      setState(() {
        existingAppointments =
            appointments.map((appointment) => appointment['program_name']).toList().cast<String>();
      });
    }
  }

  String _formatDateToThai(DateTime date) {
    initializeDateFormatting('th_TH', null);

    final localDate =
        date.toLocal().add(Duration(hours: 7)); // ปรับเวลาเป็น GMT+7
    final thaiDateFormat = DateFormat.yMMMMEEEEd('th_TH');

    final buddhistYear = localDate.year + 543;
    return thaiDateFormat
        .format(localDate)
        .replaceAll('${localDate.year}', '$buddhistYear');
  }

  void _navigateToProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userId: widget.userId),
      ),
    );

    if (updatedData != null) {
      setState(() {
        userName =
            '${updatedData['title_name']} ${updatedData['first_name']} ${updatedData['last_name']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundGradientStart.withOpacity(0.9),
                backgroundGradientEnd.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundImage: AssetImage('assets/images/logor.png'),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'โรงพยาบาลพุธชินราช',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColorDark),
                        ),
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: Text(
                            userName,
                            style: TextStyle(color: textColorDark),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      icon: Icon(Icons.logout),
                      color: textColorDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'รายการนัดที่ใกล้ถึง',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: textColorDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: latestProgramName == 'ยังไม่มีนัดหมาย'
                            ? Colors.grey
                            : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: latestProgramName == 'ยังไม่มีนัดหมาย'
                                    ? Colors.grey
                                    : textColorDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    latestProgramName == 'ยังไม่มีนัดหมาย'
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.start,
                                children: [
                                  if (latestProgramName ==
                                      'ยังไม่มีนัดหมาย') ...[
                                    Text(
                                      'ยังไม่มีนัดหมาย',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: nextButtonTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(latestProgramName,
                                        style: TextStyle(
                                            color: nextButtonTextColor)),
                                    Text(
                                      latestAppointmentDate.isNotEmpty
                                          ? latestAppointmentDate
                                          : 'ไม่มีการนัดหมาย',
                                      style:
                                          TextStyle(color: nextButtonTextColor),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(
                      color: Colors.white,
                      thickness: 2.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'เลือกรายการตรวจ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColorDark,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children:
                        List.generate(getSampleQuizSets().length, (index) {
                      return HealthButton(
                        quizSet: getSampleQuizSets()[index],
                        userName: widget.userName,
                        userId: widget.userId,
                        existingAppointments: existingAppointments,
                      );
                    }),
                  ),
                ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthButton extends StatelessWidget {
  final QuizSet quizSet;
  final String userName;
  final int userId;
  final List<String> existingAppointments;

  HealthButton({
    super.key,
    required this.quizSet,
    required this.userName,
    required this.userId,
    required this.existingAppointments,
  });

  Future<Map<String, dynamic>> _fetchHealthData() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/profile/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load health data');
    }
  }

  void _navigateToQuiz(BuildContext context) async {
    if (existingAppointments.contains(quizSet.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('คุณได้ลงนัดรายการนี้แล้ว')),
      );
      return;
    }

    if (quizSet.name == 'ตรวจสุขภาพ') {
      try {
        final healthData = await _fetchHealthData();

        double? bmi = double.tryParse(healthData['bmi'].toString());
        double? waistToHeightRatio =
            double.tryParse(healthData['waist_to_height_ratio'].toString());

        if (bmi == null ||
            bmi.isNaN ||
            waistToHeightRatio == null ||
            waistToHeightRatio.isNaN) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: 'กรุณากรอกข้อมูลสุขภาพก่อนเข้าตรวจสุขภาพ',
            confirmBtnText: 'ไปกรอก',
            onConfirmBtnTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfilePage2(healthData: healthData),
                ),
              );
            },
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionScreen(
              quizSet: quizSet,
              userId: userId,
              userName: userName,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลสุขภาพ: $e')),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            quizSet: quizSet,
            userId: userId,
            userName: userName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: GestureDetector(
        onTap: () => _navigateToQuiz(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          height: MediaQuery.of(context).size.height * 0.1,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 243, 243, 243),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 188, 188, 188),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(children: [
            Icon(quizSet.icon, size: 40, color: Color(0xFF0277BD)),
            SizedBox(width: 25),
            Text(
              quizSet.name,
              style: TextStyle(fontSize: 28, color: Color(0xFF0277BD)),
            ),
          ]),
        ),
      ),
    );
  }
}
