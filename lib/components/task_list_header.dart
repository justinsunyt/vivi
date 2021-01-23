import 'package:flutter/material.dart';
import 'package:Focal/utils/date.dart';

class TaskListHeader extends StatelessWidget {
  final date;

  const TaskListHeader({
    @required this.date,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Text(
        this.date == 'Overdue' ||
                this.date == 'No Date' ||
                this.date == 'Completed'
            ? this.date
            : DateTime.parse(this.date) == DateProvider().today
                ? 'Today, ${DateProvider().weekdayString(DateTime.parse(this.date), false)} ${DateProvider().monthString(DateTime.parse(this.date), false)} ${DateTime.parse(this.date).day}'
                : DateTime.parse(this.date) == DateProvider().tomorrow
                    ? 'Tomorrow, ${DateProvider().weekdayString(DateTime.parse(this.date), false)} ${DateProvider().monthString(DateTime.parse(this.date), false)} ${DateTime.parse(this.date).day}'
                    : '${DateProvider().weekdayString(DateTime.parse(this.date), false)} ${DateProvider().monthString(DateTime.parse(this.date), false)} ${DateTime.parse(this.date).day}${DateTime.parse(this.date).year != DateProvider().today.year ? ' ' + DateTime.parse(this.date).year.toString() : ''}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
