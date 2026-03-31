import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../widgets/navigation_widgets.dart';
import '../models/activity_model.dart';
import '../data/database_helper.dart';
import 'add_activity_screen.dart';

class CalendarScreen extends StatefulWidget {
  final String title;

  const CalendarScreen({super.key, required this.title});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<Activity> _activities = [];
  final List<String> _weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await DatabaseHelper().getActivities();
    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

  int get _daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  int get _firstWeekdayOffset {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    return firstDay.weekday % 7;
  }

  List<Activity> _getActivitiesForDate(DateTime date) {
    return _activities.where((activity) {
      return activity.date.year == date.year &&
          activity.date.month == date.month &&
          activity.date.day == date.day;
    }).toList();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _showMonthYearPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 260,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: _currentMonth,
                mode: CupertinoDatePickerMode.monthYear,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _currentMonth = newDate;
                  });
                },
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAddScreen(ActivityType type) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
            AddActivityScreen(type: type, initialDate: _selectedDate),
      ),
    );

    if (result == true) {
      _loadActivities();
    }
  }

  void _showAddTemplateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to ${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TemplateOption(
                    icon: CupertinoIcons.checkmark_square,
                    label: 'Todo List',
                    color: const Color(0xFF007AFF),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddScreen(ActivityType.todo);
                    },
                  ),
                  _TemplateOption(
                    icon: CupertinoIcons.calendar,
                    label: 'Event',
                    color: const Color(0xFFFF9500),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddScreen(ActivityType.event);
                    },
                  ),
                  _TemplateOption(
                    icon: CupertinoIcons.bell,
                    label: 'Reminder',
                    color: const Color(0xFFFF2D55),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddScreen(ActivityType.reminder);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _toggleTodo(Activity activity) async {
    if (activity.type == ActivityType.todo) {
      setState(() {
        activity.isCompleted = !activity.isCompleted;
      });
      await DatabaseHelper().updateActivity(activity);
    }
  }

  void _toggleSubTask(Activity act, SubTask st) async {
    setState(() {
      st.isCompleted = !st.isCompleted;
      // If all subtasks are complete, mark main activity as complete
      act.isCompleted = act.subTasks.every((s) => s.isCompleted);
    });
    if (st.id != null) {
      await DatabaseHelper().toggleSubTaskCompletion(st.id!, st.isCompleted);
    }
    await DatabaseHelper().updateActivity(act);
  }

  void _deleteActivity(Activity activity) async {
    setState(() {
      _activities.remove(activity);
    });
    if (activity.id != null) {
      await DatabaseHelper().deleteActivity(activity.id!);
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateActivities = _getActivitiesForDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      drawer: const NavigationWidgets(),
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Calendar View ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showMonthYearPicker,
                        child: Row(
                          children: [
                            Text(
                              '${_currentMonth.day} ${_monthName(_currentMonth.month)}, ${_currentMonth.year.toString().substring(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              CupertinoIcons.chevron_down,
                              size: 14,
                              color: Color(0xFF1C1C1E),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _previousMonth,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.chevron_left,
                                size: 20,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _nextMonth,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.chevron_right,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekDays
                        .map(
                          (day) => SizedBox(
                            width: 32,
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: _daysInMonth + _firstWeekdayOffset,
                    itemBuilder: (context, index) {
                      if (index < _firstWeekdayOffset) {
                        return const SizedBox.shrink();
                      }
                      final day = index - _firstWeekdayOffset + 1;
                      final date = DateTime(
                        _currentMonth.year,
                        _currentMonth.month,
                        day,
                      );
                      final isSelected =
                          date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
                      final dayActivities = _getActivitiesForDate(date);

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = date);
                          _showAddTemplateBottomSheet();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1C1C1E)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.toString(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                ),
                              ),
                              if (dayActivities.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: dayActivities
                                        .take(3)
                                        .map(
                                          (act) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1.5,
                                            ),
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: act.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- Activities List ---
            Expanded(
              child: selectedDateActivities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.calendar_today,
                            size: 50,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events for this date',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: selectedDateActivities.length,
                      itemBuilder: (context, index) {
                        final act = selectedDateActivities[index];
                        final bool hasTime = act.startTime != null;
                        return Dismissible(
                          key: ValueKey(act.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteActivity(act),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              CupertinoIcons.trash,
                              color: Colors.white,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: act.priority != ActivityPriority.none
                                  ? Border(
                                      left: BorderSide(
                                        color: act.priorityColor,
                                        width: 4,
                                      ),
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: act.color.withAlpha(15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Theme(
                              // Used ExpansionTile to allow showing subtasks list
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: act.type == ActivityType.todo
                                    ? GestureDetector(
                                        onTap: () => _toggleTodo(act),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(top: 4),
                                          decoration: BoxDecoration(
                                            color: act.isCompleted
                                                ? act.color
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: act.isCompleted
                                                  ? act.color
                                                  : act.color.withAlpha(100),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: act.isCompleted
                                              ? const Icon(
                                                  CupertinoIcons.checkmark,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      )
                                    : Container(
                                        width: 24,
                                        height: 24,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: act.color.withAlpha(26),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          act.type == ActivityType.event
                                              ? CupertinoIcons.calendar
                                              : CupertinoIcons.bell,
                                          size: 12,
                                          color: act.color,
                                        ),
                                      ),
                                title: Text(
                                  act.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration:
                                        act.type == ActivityType.todo &&
                                            act.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color:
                                        act.type == ActivityType.todo &&
                                            act.isCompleted
                                        ? Colors.grey
                                        : const Color(0xFF1C1C1E),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    if (hasTime)
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.clock,
                                            size: 12,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${DateFormat.Hm().format(act.startTime!)}${act.endTime != null ? ' - ${DateFormat.Hm().format(act.endTime!)}' : ''}",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (act.subTasks.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: act.progress,
                                              backgroundColor: Colors.grey[200],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    act.color,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              minHeight: 4,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${act.subTasks.where((s) => s.isCompleted).length}/${act.subTasks.length}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                children: [
                                  if (act.description != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          act.description!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (act.subTasks.isNotEmpty)
                                    ...act.subTasks.map((st) {
                                      return CheckboxListTile(
                                        title: Text(
                                          st.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            decoration: st.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: st.isCompleted
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                        value: st.isCompleted,
                                        activeColor: act.color,
                                        checkboxShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) =>
                                            _toggleSubTask(act, st),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: const EdgeInsets.only(
                                          left: 32,
                                          right: 16,
                                        ),
                                      );
                                    }),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTemplateBottomSheet,
        backgroundColor: const Color(0xFF1C1C1E),
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
