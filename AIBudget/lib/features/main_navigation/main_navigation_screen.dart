import 'package:AIBudget/features/main_navigation/%08add_expense_screen.dart';
import 'package:AIBudget/features/main_navigation/payment_report_screen.dart';
import 'package:AIBudget/features/main_navigation/widgets/bottom_sheet.dart';
import 'package:AIBudget/features/main_navigation/widgets/cardApproval.dart';
import 'package:AIBudget/features/main_navigation/widgets/img_popup_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:AIBudget/constants/gaps.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainNavitationScreenState();
}

const Color kbYellow = Colors.amber;
const Color kbBlack = Colors.black87;

class _MainNavitationScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  final double _currentIndex = 0;
  DateTime _selectedDay = DateTime(2023, 9, 1);
  DateTime _focusedDay = DateTime(2023, 9, 1);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool isLoading = false;
  Map<DateTime, List<dynamic>> events = {};

  Future<Map<DateTime, List<double>>> fetchTotalAmountsForMonth(
      int year, int month) async {
    final response = await http.post(
      Uri.parse("https://5431508973.for-seoul.synctreengine.com/total_amounts"),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "year": year,
        "month": month,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      List<dynamic> resultList = responseData['result'];

      Map<DateTime, List<double>> mappedEvents = {};

      for (var item in resultList) {
        DateTime transactionDate = DateTime.parse(item['transaction_date']);
        double totalAmount = double.parse(item['total_amount']);
        mappedEvents[transactionDate] = [totalAmount];
      }

      print(mappedEvents);
      print("print33333333333");
      DateTime firstKey = mappedEvents.keys.first;
      List<double>? firstValue = mappedEvents[firstKey];

      print("First key: $firstKey");
      print("Value of first key: $firstValue");
      print(firstValue);
      return mappedEvents;
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  void showStackDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) => StackDialog(
          controller: PageController(),
        ),
      );
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      _focusedDay = focusedDay;
    });
    _fetchCardApprovals();
  }

  void _onPlusPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
    showStackDialog(context);
  }

  void _loadEvents() async {
    int currentYear = _focusedDay.year;
    int currentMonth = _focusedDay.month;

    try {
      Map<DateTime, List<double>> fetchedEvents =
          await fetchTotalAmountsForMonth(currentYear, currentMonth);
      setState(() {
        events = fetchedEvents; // fetchedEvents 값을 events에 할당
        print(fetchedEvents);
        print("fetchedEvents2");
      });
    } catch (error) {
      // Handle the error (e.g., show a message to the user)
    }
  }

  void _fetchCardApprovals() async {
    setState(() {
      isLoading = true;
    });

    DateTime dateToFetch =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    try {
      List<CardApprovalData> approvals =
          await fetchCardApprovals(dateToFetch, dateToFetch);

      if (events[dateToFetch] == null) {
        events[dateToFetch] = [];
      }

      events[dateToFetch]!.addAll(approvals.map((e) => e.amount));

      // 여기서 fetchedEvents의 데이터도 추가합니다.
      int currentYear = dateToFetch.year;
      int currentMonth = dateToFetch.month;
      Map<DateTime, List<double>> fetchedEvents =
          await fetchTotalAmountsForMonth(currentYear, currentMonth);

      if (fetchedEvents.containsKey(dateToFetch)) {
        events[dateToFetch]!.addAll(fetchedEvents[dateToFetch]!);
      }
    } catch (error) {
      // 에러 처리
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showStackDialog() {
    final dialogFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    void _dialogOnClosePressed() {
      dialogFadeController.reverse().then((value) {});
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StackDialog(
            controller: _controller, initialIndex: _currentIndex);
      },
    ).then((_) {
      dialogFadeController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Budget",
          style: TextStyle(color: kbBlack),
        ),
        centerTitle: true,
        leading: Builder(
          // 여기에 Builder 위젯을 추가합니다.
          builder: (context) => IconButton(
            color: kbBlack,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const FaIcon(FontAwesomeIcons.bars),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
        actions: <Widget>[
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            color: kbBlack,
            onPressed: () {
              _showStackDialog(); // 스마일 아이콘을 눌렀을 때 StackDialog를 표시합니다.
            },
            icon: const FaIcon(
              FontAwesomeIcons.tags,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              color: kbBlack,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          const PaymentReportScreen()), // 결제 보고서 페이지로 이동
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.chartPie,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 80,
              child: DrawerHeader(
                margin: EdgeInsets.only(
                  top: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Text(
                  'Menu Header',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            Gaps.v20,
            ListTile(
              tileColor: Colors.white,
              title: const Text(
                'Menu Item 1',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                // Do something...
                Navigator.of(context).pop(); // Drawer를 닫습니다.
              },
            ),
            ListTile(
              tileColor: Colors.white,
              title: const Text(
                'Menu Item 2',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                // Do something...
                Navigator.of(context).pop(); // Drawer를 닫습니다.
              },
            ),
            ListTile(
              tileColor: Colors.white,
              title: const Text(
                'Menu Item 3',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                // Do something...
                Navigator.of(context).pop(); // Drawer를 닫습니다.
              },
            ),
            // 다른 메뉴 항목을 추가하려면 여기에 추가하세요.
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Gaps.v10,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TableCalendar(
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadEvents();
                  },
                  eventLoader: (date) {
                    var keyDate = DateTime(date.year, date.month, date.day);
                    print("Fetching events for: $keyDate");
                    var eventData = events[keyDate] ?? [];
                    print("Fetched events: $eventData");
                    return eventData;
                    // print(events);
                    // print(events[DateTime(2023, 9, 1)]);
                    // print("events1");
                    // return events[DateTime(date.year, date.month, date.day)] ??
                    //     [];
                  },
                  calendarBuilders: CalendarBuilders(
                    todayBuilder: (context, date, events) {
                      return Center(
                        child: Container(
                          width: 30, // 원하는 원의 너비
                          height: 30, // 원하는 원의 높이
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey.shade300,
                          ),
                          child: Center(child: Text(date.day.toString())),
                        ),
                      );
                    },
                    selectedBuilder: (context, date, events) {
                      return Center(
                        child: Container(
                          width: 30, // 원하는 원의 너비
                          height: 30, // 원하는 원의 높이
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Center(child: Text(date.day.toString())),
                        ),
                      );
                    },
                    // 3. singleMarkerBuilder에서 해당 날짜의 total_amount를 표시
                    singleMarkerBuilder: (context, date, event) {
                      double? amount;
                      if (event is List<double> && event.isNotEmpty) {
                        amount = event[0];
                      } else if (event is double) {
                        amount = event;
                      }

                      if (amount != null) {
                        print(
                            "Displaying total_amount for date $date: $amount");
                        return Text(
                          amount.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 10.0,
                            color: amount < 0
                                ? Colors.red.shade500
                                : Colors.blue.shade500, // 조건부 색상 변경
                          ),
                        );
                      }

                      print("No valid data for date $date");
                      return const Text('Data exist',
                          style: TextStyle(fontSize: 10));
                    },
                  ),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    if (format == CalendarFormat.week) {
                      //! 2weeks나 Weeks인 상태로 화살표를 누르면 월도 바뀜
                      setState(() {
                        _calendarFormat = CalendarFormat.week;
                      });
                    } else {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onDaySelected: _onDaySelected,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonTextStyle: TextStyle(
                      color: kbBlack,
                      fontSize: 14,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: kbBlack),
                    rightChevronIcon: Icon(Icons.chevron_right, color: kbBlack),
                    formatButtonShowsNext: false,
                  ),
                  locale: "ko_KR",
                  rowHeight: 60,
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2010, 10, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                ),
              ),
            ],
          ),
          CustomBottomSheet(selectedDate: _selectedDay),
        ],
      ),
    );
  }
}
