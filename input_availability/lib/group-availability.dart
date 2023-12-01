import 'package:flutter/material.dart';
import 'package:input_availability/event.dart';
import 'package:kalender/kalender.dart';

final CalendarEventsController<Event> eventsController =
    CalendarEventsController<Event>();
final CalendarController<Event> calendarController = CalendarController(
  initialDate: DateTime.now(),
);

class GroupAvailability extends StatelessWidget {
  const GroupAvailability({super.key});

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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("hello"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("hello"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("hello"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("hello"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("hello"),
                      ),
                    ],
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
}

Widget _tileBuilder(
    CalendarEvent<dynamic> event, TileConfiguration tileConfiguration) {
  final Event? customObject = event.eventData;

  return Card(
    color: customObject?.color,
    child: Text(customObject!.timeRange,
        style: const TextStyle(fontSize: 4.0, fontWeight: FontWeight.bold)),
  );
}

Widget _multiDayTileBuilder(event, tileConfiguration) => const Card(
      color: Colors.red,
    );

Widget _scheduleTileBuilder(event, date) => const Card(
      color: Colors.redAccent,
    );

String formatTimeRange(DateTimeRange dateTimeRange) {
  return "${dateTimeRange.start.hour}:"
      "${dateTimeRange.start.minute == 0 ? "00" : dateTimeRange.start.minute}"
      " - "
      "${dateTimeRange.end.hour}:"
      "${dateTimeRange.end.minute == 0 ? "00" : dateTimeRange.end.minute}";
}

CalendarEvent<Event> createCalendarEvent(DateTimeRange dateTimeRange) {
  return CalendarEvent(
    dateTimeRange: dateTimeRange,
    modifiable: true,
    eventData: Event(
      // The custom object that you want to link to the event.
      color: Colors.greenAccent,
      timeRange: formatTimeRange(dateTimeRange),
    ),
  );
}
