import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:flutter/services.dart';
import 'event.dart';

class MyCalendar extends StatefulWidget {
  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  CalendarEventsController<Event> eventsController = CalendarEventsController<
      Event>();
  CalendarController calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Prototype')
        ),
        body: Stack(
            children: [
              CalendarView(
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
                  horizontalStepDuration: const Duration(days: 1),
                  paintWeekNumber: true,
                  enableRescheduling: true,
                ),
                tileBuilder: _tileBuilder,
                multiDayTileBuilder: _multiDayTileBuilder,
                scheduleTileBuilder: _scheduleTileBuilder,
                eventHandlers: CalendarEventHandlers(
                  onEventTapped: (event) async {
                    HapticFeedback.lightImpact();
                    print("on event tapped");
                    // Check if the event that was tapped is is currently selected.
                    setState(() {
                      eventsController.selectedEvent == event
                      // If it is selected, deselect it.
                          ? eventsController.deselectEvent()
                      // If it is not selected, select it.
                          : eventsController.selectEvent(
                          event as CalendarEvent<Event>);
                    });
                  },
                  onEventChanged: (initialDateTimeRange, event) async {
                    // If you want to deselect the event after it has been resized/rescheduled. uncomment the following line.
                    // eventController.deselectEvent();
                    print("on event changed");
                    HapticFeedback.vibrate();
                  },
                  onEventChangeStart: (event) {
                    // You can give the user some haptic feedback here.
                    print("on event change start");
                  },
                  onCreateEvent: (DateTimeRange dateTimeRange) {
                    HapticFeedback.selectionClick();
                    print("on create event");

                    Event event = Event( // The custom object that you want to link to the event.
                        color: Colors.greenAccent,
                        timeRange: formatTimeRange(dateTimeRange)
                    );

                    eventsController.addEvent(
                        CalendarEvent(
                          dateTimeRange: DateTimeRange(
                              start: dateTimeRange.start,
                              end: dateTimeRange.start.add(
                                  const Duration(hours: 1))),
                          modifiable: true,
                          // Change this to false if you do not want the user to modify the event.
                          eventData: event,
                        )
                    );

                    setState(() {
                      if (eventsController.selectedEvent != null) {
                        eventsController.deselectEvent();
                      }
                    });
                  },
                ),
              ),
              Visibility(
                visible: eventsController.selectedEvent != null,
                child: Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Handle delete action
                      setState(() {
                        eventsController.removeEvent(
                            eventsController.selectedEvent as CalendarEvent<
                                Event>);
                        eventsController.deselectEvent();
                      });
                    },
                    child: const Icon(Icons.delete),
                  ),
                ),
              ),
            ]

        )


    );
  }
}

Widget _tileBuilder(CalendarEvent<dynamic> event, TileConfiguration tileConfiguration) {
  final Event? customObject = event.eventData;

  return Card(
    color: customObject?.color,
    child: Text(customObject!.timeRange),
  );
}

Widget _multiDayTileBuilder(event, tileConfiguration) => const Card(
  color: Colors.red,
);

Widget _scheduleTileBuilder(event, date) => const Card(
  color: Colors.redAccent,
);

String formatTimeRange(DateTimeRange dateTimeRange) {
  return "${dateTimeRange.start.hour}:${dateTimeRange.start.minute} - "
      "${dateTimeRange.end.hour}:${dateTimeRange.end.minute}";
}