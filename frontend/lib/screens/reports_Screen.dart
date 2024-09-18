import 'dart:convert';
import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/providers/fieldsProvider.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsScreen> createState() {
    return _ReportsScreenState();
  }
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  List<String> dropdownItems =
      []; // This will now be populated from the provider
  String selectedField =
      ''; // Default value, will be set in initState or when list updates
  bool isStretchedDropDown = false;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  DateTime selectedDate = DateTime.now();
  int? selectedBarIndex;
  bool _isLoading = false;
  late TabController _tabController;
  Map<String, Map<int, Map<int, int>>> reportCountByMonth = {};
  Map<String, Map<String, List<Map<String, dynamic>>>> hourlyReservations = {};
  String selectedMonthYear = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedMonthYear = '${DateTime.now().month}.${DateTime.now().year}';
    _getReportsCountByMonth();
    _getReportsByHours();
    _updateSelectedMonthYear();
    // Initialize the dropdown items from the stadium list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stadiumList = ref.read(stadiumListProvider);
      if (stadiumList.isNotEmpty) {
        dropdownItems = stadiumList.map((stadium) => stadium.title).toList();
        selectedField =
            dropdownItems.first; // Set the first item as selected by default
      }
    });
  }

  void _updateSelectedMonthYear() {
    selectedMonthYear = '$selectedMonth.$selectedYear';
    print('Selected MonthYear: $selectedMonthYear');
  }

  Map<String, Map<int, Map<int, int>>> parseResponse(
      Map<String, dynamic> json) {
    return json.map((key, value) {
      Map<int, Map<int, int>> monthMap =
          (value as Map<String, dynamic>).map((nestedKey, nestedValue) {
        Map<int, int> countMap =
            (nestedValue as Map<String, dynamic>).map((countKey, countValue) {
          return MapEntry(int.parse(countKey), countValue as int);
        });
        return MapEntry(int.parse(nestedKey), countMap);
      });
      return MapEntry(key, monthMap);
    });
  }

  Future<void> _getReportsCountByMonth() async {
    final url = Uri.http(httpIP, 'api/get_reservation_count_per_month_report');

    try {
      Map<String, dynamic> requestBody = {
        "year": selectedYear.toString(),
        "manager_id": ref.read(userSingletonProvider).id
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print("Response body: ${response.body}");

      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
        });
        // Handle error if needed
      } else {
        String responseBody = response.body.trim();

        if (responseBody.isNotEmpty) {
          // Decode the JSON response
          Map<String, dynamic> jsonResponse = json.decode(responseBody);

          // Parse the entire response body
          setState(() {
            reportCountByMonth = parseResponse(jsonResponse);
          });

          // You can now use the 'reportCountByMonth' map as needed
        }
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> _getReportsByHours() async {
    final url = Uri.http(httpIP, 'api/get_hourly_reservations_report');
    try {
      Map<String, dynamic> requestBody = {
        "date": selectedMonthYear,
        "manager_id":
            ref.read(userSingletonProvider).id // Replace with actual manager ID
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        setState(() {
          _isLoading = false;
        });
        // Handle error if needed
      } else {
        String responseBody = response.body.trim();

        if (responseBody.isNotEmpty) {
          // Decode the JSON response
          Map<String, dynamic> jsonResponse = json.decode(responseBody);

          // Parse the response and format the date correctly
          Map<String, Map<String, List<Map<String, dynamic>>>> parsedData = {};
          jsonResponse.forEach((date, timeRanges) {
            String formattedDate =
                '${int.parse(date.split('.')[0])}.${date.split('.')[1]}';
            parsedData[formattedDate] = {};

            (timeRanges as Map<String, dynamic>).forEach((timeRange, details) {
              parsedData[formattedDate]![timeRange] = (details as List)
                  .map<Map<String, dynamic>>((detail) => {
                        "count": detail["count"],
                        "field_name": detail["field_name"]
                      })
                  .toList();
            });
          });

          // Update the state with the parsed data
          setState(() {
            hourlyReservations = parsedData;
            print("Parsed Data:");
            print(hourlyReservations);
          });

          // You can now use the 'hourlyReservations' map as needed
        }
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final stadiumList = ref.watch(stadiumListProvider); // Watch the provider
    // Update dropdown items whenever the list changes
    if (dropdownItems.isEmpty && stadiumList.isNotEmpty) {
      dropdownItems = stadiumList.map((stadium) => stadium.title).toList();
      selectedField =
          dropdownItems.first; // Update the selected field if necessary
    }

    Map<int, int>? yearData = reportCountByMonth[selectedField]?[selectedYear];
    Map<String, List<Map<String, dynamic>>>? hourlyData =
        hourlyReservations[selectedMonthYear];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Stadium Reservations'),
                Tab(text: 'Reservations By Hour'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // First tab content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This graph indicates amount of reservations by each month',
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isStretchedDropDown = !isStretchedDropDown;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffbbbbbb)),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(27)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xffbbbbbb)),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(25)),
                              ),
                              constraints: const BoxConstraints(
                                minHeight: 45,
                                minWidth: double.infinity,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Text(
                                        selectedField,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  Icon(isStretchedDropDown
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward),
                                ],
                              ),
                            ),
                            if (isStretchedDropDown)
                              SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 120,
                                    minHeight: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xffbbbbbb)),
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(27)),
                                  ),
                                  child: ListView.builder(
                                    itemCount: dropdownItems.length,
                                    itemBuilder: (context, index) {
                                      return RadioListTile(
                                        title: Text(dropdownItems[index]),
                                        value: dropdownItems[index],
                                        groupValue: selectedField,
                                        onChanged: (val) {
                                          setState(() {
                                            selectedField = val.toString();
                                            isStretchedDropDown = false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                height: 300,
                                child: YearPicker(
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  initialDate: DateTime.now(),
                                  selectedDate: DateTime(selectedYear),
                                  onChanged: (DateTime dateTime) {
                                    setState(() {
                                      selectedYear = dateTime.year;
                                      _getReportsCountByMonth();
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text('Select Year: $selectedYear'),
                    ),
                    const SizedBox(height: 20),
                    yearData == null || yearData.isEmpty
                        ? const Text('No data available for the selected year.')
                        : SizedBox(
                            height: 400,
                            child: MyBarGraph(
                              summary: BarData(
                                field: selectedField,
                                data: yearData,
                              ).getMonthlySummary(),
                              titles: List.generate(
                                  12,
                                  (index) => DateFormat('MMM')
                                      .format(DateTime(0, index + 1))),
                              onBarTap: (month) {
                                setState(() {
                                  selectedMonth = month + 1;
                                  selectedDate =
                                      DateTime(selectedYear, selectedMonth, 1);
                                  _updateSelectedMonthYear();
                                  _getReportsByHours(); // Call the API with new date
                                  _tabController.animateTo(1);
                                });
                              },
                              onBarLongPress: (month, value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reservations: $value'),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
            // Second tab content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildMonthYearPicker(context);
                        },
                      );
                    },
                    child: Text('Select Date: $selectedMonthYear'),
                  ),
                  const SizedBox(height: 20),
                  hourlyData == null || hourlyData.isEmpty
                      ? const Text('No data available for the selected date.')
                      : Expanded(
                          child: ListView.builder(
                            itemCount: hourlyData.length,
                            itemBuilder: (context, index) {
                              String timeRange =
                                  hourlyData.keys.elementAt(index);
                              List<Map<String, dynamic>> reservations =
                                  hourlyData[timeRange]!;

                              // Calculate the total number of reservations for this time range
                              int totalReservations = reservations.fold<int>(
                                0,
                                (sum, reservation) =>
                                    sum + (reservation['count'] as int),
                              );

                              // Filter out reservations with a count of 0
                              List<Map<String, dynamic>> filteredReservations =
                                  reservations
                                      .where((reservation) =>
                                          reservation['count'] > 0)
                                      .toList();

                              if (totalReservations == 0) {
                                return SizedBox.shrink();
                              }

                              // Display reservations for each time range
                              return ExpansionTile(
                                title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0), // Add padding
                                  child: Text(
                                      '$timeRange: $totalReservations reservations'),
                                ),
                                children:
                                    filteredReservations.map((reservation) {
                                  return ListTile(
                                    title: Text(
                                        'Field: ${reservation['field_name']} (#${reservation['count']}  Reservations)'),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthYearPicker(BuildContext context) {
    int tempSelectedYear = selectedYear;
    int tempSelectedMonth = selectedMonth;

    return AlertDialog(
      title: const Text('Select Month and Year'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  DropdownButton<int>(
                    value: tempSelectedMonth,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                            DateFormat.MMMM().format(DateTime(0, index + 1))),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          tempSelectedMonth = value;
                        });
                      }
                    },
                  ),
                  DropdownButton<int>(
                    value: tempSelectedYear,
                    items: List.generate(100, (index) {
                      int year = DateTime.now().year - 50 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          tempSelectedYear = value;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selectedYear = tempSelectedYear;
              selectedMonth = tempSelectedMonth;
              selectedMonthYear = '$selectedMonth.$selectedYear';
              selectedDate = DateTime(selectedYear, selectedMonth, 1);
              _updateSelectedMonthYear();
              _getReportsByHours(); // Call the API with new date
            });
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class BarData {
  final String field;
  final Map<int, int> data;

  BarData({
    required this.field,
    required this.data,
  });

  List<double> getMonthlySummary() {
    return List.generate(12, (index) => data[index + 1]?.toDouble() ?? 0.0);
  }
}

class MyBarGraph extends StatelessWidget {
  final List<double> summary;
  final List<String> titles;
  final Function(int) onBarTap;
  final Function(int, double) onBarLongPress;

  const MyBarGraph({
    Key? key,
    required this.summary,
    required this.titles,
    required this.onBarTap,
    required this.onBarLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: summary.reduce((a, b) => a > b ? a : b) + 10,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < titles.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(titles[index],
                        style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
        ),
        barGroups: summary.asMap().entries.map((data) {
          return BarChartGroupData(
            x: data.key,
            barRods: [
              BarChartRodData(
                toY: data.value,
                color: const Color.fromARGB(255, 131, 57, 0),
                width: 15,
              ),
            ],
            showingTooltipIndicators: [],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (barTouchResponse != null && barTouchResponse.spot != null) {
              final index = barTouchResponse.spot!.touchedBarGroupIndex;
              final value = barTouchResponse.spot!.touchedRodData.toY;
              if (event.isInterestedForInteractions) {
                if (event is FlLongPressStart) {
                  onBarLongPress(index, value);
                } else if (event is FlTapUpEvent) {
                  onBarTap(index);
                }
              }
            }
          },
        ),
      ),
    );
  }
}
