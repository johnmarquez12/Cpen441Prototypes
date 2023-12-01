import 'package:flutter/material.dart';
import 'package:input_availability/event.dart';
import 'package:kalender/kalender.dart';
import 'package:date_format/date_format.dart';

final CalendarEventsController<Event> eventsController =
    CalendarEventsController<Event>();
final CalendarController<Event> calendarController = CalendarController(
  initialDate: DateTime.now(),
);

final availabilities = [
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
    end: DateTime(2023, 12, 9, 20),
  ),
];

/// The number of available people, in the same order as the [DateTimeRange]s
/// that appear in [availabilities].
final participants = [
  2,
  3,
  4,
];

final totalParticipants = 4;

class GroupAvailability extends StatefulWidget {
  const GroupAvailability({super.key});

  @override
  State<GroupAvailability> createState() => _GroupAvailabilityState();
}

class _GroupAvailabilityState extends State<GroupAvailability> {
  @override
  void initState() {
    super.initState();
    for (var a in availabilities) {
      eventsController.addEvent(createCalendarEvent(a));
    }
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
              height: MediaQuery.of(context).size.height / 10,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                reverse: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height / 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: getAvailabilityText(),
                  ),
                ),
              ),
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
              ),
            ),
          ],
        ));
  }

  List<Widget> getAvailabilityText() {
    final List<Widget> result = [];

    for (var i = 0; i < availabilities.length; i++) {
      final a = availabilities[i];
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
        ' from ',
        h,
        (startHour < 12 ? ":${startMin}am" : ":${startMin}pm")
      ]);

      final endFormatted = formatDate(
          a.end, [' to ', h, (endHour < 12 ? ":${endMin}am" : ":${endMin}pm")]);
      result.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: RichText(
            text: TextSpan(
                text: "$startFormatted $endFormatted - ",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black, // Add this line
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "${participants[i].toString()}/$totalParticipants",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black, // Add this line
                    ),
                  )
                ]),
          ),
        ),
      );
    }

    return result;
  }
}

Widget _tileBuilder(
    CalendarEvent<dynamic> event, TileConfiguration tileConfiguration) {
  final Event? customObject = event.eventData;

  return Card(
    color: customObject?.color,
    shadowColor: Colors.transparent,
    child: Center(
      child: Text(
        customObject!.timeRange,
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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

CalendarEvent<Event> createCalendarEvent(DateTimeRange dateTimeRange) {
  var index = 0;

  for (var i = 0; i < availabilities.length; i++) {
    if (availabilities[i] == dateTimeRange) {
      index = i;
      break;
    }
  }

  var opacity = participants[index] / totalParticipants;
  if (opacity < 1.0) {
    opacity -= 0.2;
  }

  return CalendarEvent(
    dateTimeRange: dateTimeRange,
    modifiable: false,
    eventData: Event(
      // The custom object that you want to link to the event.
      color: Colors.greenAccent.withOpacity(opacity),

      timeRange: "${participants[index].toString()}/$totalParticipants",
    ),
  );
}
