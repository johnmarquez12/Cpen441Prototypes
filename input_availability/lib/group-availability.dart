import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:input_availability/event.dart';
import 'package:input_availability/tuple2.dart';
import 'package:kalender/kalender.dart';
import 'package:date_format/date_format.dart';

final CalendarEventsController<Event> eventsController =
    CalendarEventsController<Event>();
final CalendarController<Event> calendarController = CalendarController(
  initialDate: DateTime.now(),
);

const t = String.fromEnvironment("TEST");

final availabilities = t == "easy"
    ? [
        DateTimeRange(
          start: DateTime(2023, 12, 7, 15),
          end: DateTime(2023, 12, 7, 16),
        ),
        DateTimeRange(
          start: DateTime(2023, 12, 8, 11),
          end: DateTime(2023, 12, 8, 12, 30),
        ),
        DateTimeRange(
          start: DateTime(2023, 12, 9, 18, 30),
          end: DateTime(2023, 12, 9, 21),
        ),
      ]
    : t == "medium"
        ? [
            DateTimeRange(
              start: DateTime(2023, 12, 7, 15),
              end: DateTime(2023, 12, 7, 16),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 7, 17),
              end: DateTime(2023, 12, 7, 18),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 8, 11),
              end: DateTime(2023, 12, 8, 12, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 8, 14),
              end: DateTime(2023, 12, 8, 15, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 9, 14, 30),
              end: DateTime(2023, 12, 9, 15),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 9, 18, 30),
              end: DateTime(2023, 12, 9, 20),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 10, 14, 30),
              end: DateTime(2023, 12, 10, 16),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 10, 16, 30),
              end: DateTime(2023, 12, 10, 20),
            ),
          ]
        : [
            DateTimeRange(
              start: DateTime(2023, 12, 7, 13),
              end: DateTime(2023, 12, 7, 14, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 7, 15),
              end: DateTime(2023, 12, 7, 16),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 7, 17),
              end: DateTime(2023, 12, 7, 18),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 7, 19),
              end: DateTime(2023, 12, 7, 20),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 8, 11),
              end: DateTime(2023, 12, 8, 12, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 8, 14),
              end: DateTime(2023, 12, 8, 15, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 8, 16),
              end: DateTime(2023, 12, 8, 16, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 8, 18),
              end: DateTime(2023, 12, 8, 19, 30),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 9, 11, 30),
              end: DateTime(2023, 12, 9, 13),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 9, 13, 30),
              end: DateTime(2023, 12, 9, 14),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 9, 14, 30),
              end: DateTime(2023, 12, 9, 15),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 9, 18, 30),
              end: DateTime(2023, 12, 9, 21),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 10, 12, 30),
              end: DateTime(2023, 12, 10, 14),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 10, 14, 30),
              end: DateTime(2023, 12, 10, 16),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 10, 16, 30),
              end: DateTime(2023, 12, 10, 17),
            ),
            DateTimeRange(
              start: DateTime(2023, 12, 10, 18, 30),
              end: DateTime(2023, 12, 10, 20),
            ),
          ];

/// The number of available people, in the same order as the [DateTimeRange]s
/// that appear in [availabilities].
final participants = t == "easy"
    ? [
        2,
        3,
        4,
      ]
    : t == "medium"
        ? [6, 5, 7, 5, 7, 6, 5, 6]
        : [12, 12, 13, 13, 14, 13, 15, 13, 14, 12, 13, 12, 14, 12, 15, 12];

const totalParticipants = t == "easy"
    ? 4
    : t == "medium"
        ? 8
        : 16;

var selectedTimeIndex = -1;

class GroupAvailability extends StatefulWidget {
  const GroupAvailability({super.key});

  @override
  State<GroupAvailability> createState() => _GroupAvailabilityState();
}

class _GroupAvailabilityState extends State<GroupAvailability> {
  // Combine the lists using zip
  final combinedList = List.generate(availabilities.length,
      (index) => Tuple2(availabilities[index], participants[index]));

  /// The max number of suggested times
  final int maxSuggestedTimes = 3;

  /// The minimum duration of the suggested time slots in hours
  double _currentSliderValue = 0.5;

  /// The filtered time slots, from combinedList, with duration of at least [_currentSliderValue] hours
  List<Tuple2> filteredList = [];

  @override
  void initState() {
    super.initState();
    combinedList.sort((a, b) => b.participants.compareTo(a.participants));

    for (var entry in combinedList) {
      eventsController.addEvent(createCalendarEvent(entry.availability));
    }

    filteredList.add(combinedList[0]);
    filteredList.add(combinedList[1]);
    filteredList.add(combinedList[2]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Group\'s Best Availability'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Suggested Times:"),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                reverse: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getAvailabilityText(),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Slider(
                  value: _currentSliderValue,
                  min: 0.5,
                  max: 3,
                  divisions: 5,
                  label: _currentSliderValue.toString(),
                  onChanged: (double value) {
                    setState(
                      () {
                        selectedTimeIndex = -1;
                        _currentSliderValue = value;
                        int hours = value.toInt();
                        int minutes = ((value - hours) * 60).round();

                        filteredList = combinedList
                            .where((tuple) =>
                                tuple.availability.duration >=
                                Duration(hours: hours, minutes: minutes))
                            .toList();
                      },
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Need help?'),
                        content: const Text(
                          "Adjust the slider to select the minimum duration you prefer (in hours) when filtering the group's best available times. For example, dragging the slider to 1.5 will show the best available time slots with duration of at least 1 hour 30 minutes.",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.help),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 2 / 3,
              child: CalendarView<Event>(
                style: CalendarStyle(
                  calendarHeaderBackgroundStyle: CalendarHeaderBackgroundStyle(
                    headerBackgroundColor: Colors.orangeAccent[100],
                  ),
                ),
                eventsController: eventsController,
                controller: calendarController,
                viewConfiguration: WeekConfiguration(
                  timelineWidth: 56,
                  multiDayTileHeight: 24,
                  eventSnapping: false,
                  timeIndicatorSnapping: false,
                  createEvents: true,
                  createMultiDayEvents: true,
                  verticalStepDuration: const Duration(minutes: 15),
                  verticalSnapRange: const Duration(minutes: 15),
                  newEventDuration: const Duration(hours: 1),
                  horizontalStepDuration: const Duration(days: 1),
                  paintWeekNumber: true,
                  enableRescheduling: true,
                ),
                tileBuilder: _tileBuilder,
                multiDayTileBuilder: _multiDayTileBuilder,
                scheduleTileBuilder: _scheduleTileBuilder,
                eventHandlers: CalendarEventHandlers(
                  onEventTapped: onEventTapped,
                ),
              ),
            ),
          ],
        ));
  }

  CalendarEvent<Event> createCalendarEvent(DateTimeRange dateTimeRange) {
    var index = 0;

    for (var i = 0; i < combinedList.length; i++) {
      if (combinedList[i].availability == dateTimeRange) {
        index = i;
        break;
      }
    }

    var opacity = combinedList[index].participants / totalParticipants;
    if (opacity < 1.0) {
      opacity -= 0.2;
    } else if (opacity <= 0.1) {
      opacity = 0.1;
    }

    return CalendarEvent(
      dateTimeRange: dateTimeRange,
      modifiable: false,
      eventData: Event(
        // The custom object that you want to link to the event.
        color: Colors.greenAccent.withOpacity(opacity),

        timeRange:
            "${combinedList[index].participants.toString()}/$totalParticipants",
      ),
    );
  }

  List<Widget> getAvailabilityText() {
    if (filteredList.isEmpty) {
      return [];
    }

    final List<Widget> result = [];

    for (var i = 0; i < filteredList.length; i++) {
      if (i >= maxSuggestedTimes) {
        break;
      }

      final a = filteredList[i].availability;
      var startHour = a.start.hour;
      var startMin = a.start.minute == 0 ? "00" : a.start.minute;
      var endHour = a.end.hour;
      var endMin = a.end.minute == 0 ? "00" : a.end.minute;

      final startFormatted = formatDate(a.start, [
        D,
        ', ',
        M,
        ' ',
        dd,
        ' (',
        h,
        (startHour < 12 ? ":${startMin}am" : ":${startMin}pm")
      ]);

      final endFormatted = formatDate(a.end,
          [' - ', h, (endHour < 12 ? ":${endMin}am)" : ":${endMin}pm)")]);
      result.add(
        GestureDetector(
          onTap: () {
            setState(() {
              eventsController.selectEvent(createCalendarEvent(a));
              selectedTimeIndex = i;
            });
          },
          child: Container(
            decoration: i == selectedTimeIndex
                ? BoxDecoration(
                    color: Colors.greenAccent[200]?.withOpacity(0.5),
                    border: Border.all(
                      color: Colors.red,
                      width: 2.5,
                    ),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: RichText(
                text: TextSpan(
                    text: "$startFormatted $endFormatted - ",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black, // Add this line
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: filteredList.isEmpty
                            ? ""
                            : "${filteredList[i].participants.toString()}/$totalParticipants",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black, // Add this line
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  Future<void> onEventTapped(CalendarEvent<Event> event) async {
    HapticFeedback.lightImpact();

    // Check if the event that was tapped is is currently selected.
    setState(() {
      eventsController.selectEvent(event);

      var i = 0;

      for (i = 0; i < combinedList.length; i++) {
        final a = combinedList[i].availability;

        if (event.dateTimeRange == a) {
          break;
        }
      }

      selectedTimeIndex = i;
    });
  }
}

Widget _tileBuilder(
    CalendarEvent<dynamic> event, TileConfiguration tileConfiguration) {
  final Event? customObject = event.eventData;
  var fontSize = 11.0;

  if (event.dateTimeRange.duration.compareTo(const Duration(hours: 1)) < 0) {
    fontSize = 10.0;
  }

  return Card(
    color: customObject?.color,
    shadowColor: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        border:
            eventsController.selectedEvent == event && selectedTimeIndex > -1
                ? Border.all(color: Colors.red, width: 2)
                : null,
      ),
      child: Center(
        child: Text(
          customObject!.timeRange,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}

Widget _multiDayTileBuilder(event, tileConfiguration) => const Card(
      color: Colors.red,
    );

Widget _scheduleTileBuilder(event, date) => const Card(
      color: Colors.redAccent,
    );
