import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class MyCalendar extends StatefulWidget {
  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  final eventsController = CalendarEventsController<Event>();
  final calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    eventsController.addEvent(
      CalendarEvent(
        dateTimeRange: DateTimeRange(start: DateTime.now().subtract(const Duration(hours: 8)), end: DateTime.now().subtract(const Duration(hours: 6))), // The DateTimeRange of the event.
        modifiable: true, // Change this to false if you do not want the user to modify the event.
        eventData: Event(  // The custom object that you want to link to the event.
          color: Colors.greenAccent,
        ),
      ),
    );    
    
    return Scaffold(
        appBar: AppBar(
            title: Text('Prototype')
        ),
        body: CalendarView(
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
            newEventDuration: const Duration(minutes: 15),
            paintWeekNumber: true,
            enableRescheduling: true,
          ),
          tileBuilder: _tileBuilder,
          multiDayTileBuilder: _multiDayTileBuilder,
          scheduleTileBuilder: _scheduleTileBuilder,
          eventHandlers: CalendarEventHandlers(
            onEventTapped: (event) async {

              // Check if the event that was tapped is is currently selected.
              eventsController.selectedEvent == event
              // If it is selected, deselect it.
                  ? eventsController.deselectEvent()
              // If it is not selected, select it.
                  : eventsController.selectEvent(event as CalendarEvent<Event>);
            },
            onEventChanged: (initialDateTimeRange, event) async {
              // If you want to deselect the event after it has been resized/rescheduled. uncomment the following line.
              // eventController.deselectEvent();
            },
            onEventChangeStart: (event) {
              // You can give the user some haptic feedback here.
            },
            onDateTapped: (dateTime) {
              eventsController.addEvent(
                  CalendarEvent(
                    dateTimeRange: DateTimeRange(start: dateTime, end: dateTime.add(const Duration(hours: 1))),
                    modifiable: true, // Change this to false if you do not want the user to modify the event.
                    eventData: Event(  // The custom object that you want to link to the event.
                      color: Colors.greenAccent,
                    ),
                )
              );
            }
          )
        )

    );
  }

}

class Event {
  final Color color;

  // Named constructor with named parameters
  Event({
    required this.color,
  });
}

Widget _tileBuilder(CalendarEvent<dynamic> event, TileConfiguration tileConfiguration) {
  final Event? customObject = event.eventData;

  return Card(
    color: customObject?.color,
  );
}

Widget _multiDayTileBuilder(event, tileConfiguration) => const Card(
  color: Colors.red,
);
Widget _scheduleTileBuilder(event, date) => const Card(
  color: Colors.redAccent,
);
