import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';

class CalendarPage extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(String) onToggle;

  const CalendarPage({super.key, required this.tasks, required this.onToggle});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstWeekday(int year, int month) {
    return DateTime(year, month, 1).weekday; // 1 = Senin, 7 = Minggu
  }

  bool _hasTasksOnDate(DateTime date) {
    return widget.tasks.any((t) =>
        t.deadline != null &&
        t.deadline!.year == date.year &&
        t.deadline!.month == date.month &&
        t.deadline!.day == date.day);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter tasks by selected date
    final dailyTasks = widget.tasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.year == _selectedDate.year &&
             t.deadline!.month == _selectedDate.month &&
             t.deadline!.day == _selectedDate.day;
    }).toList();

    dailyTasks.sort((a, b) => a.deadline!.compareTo(b.deadline!));

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal Bulanan',
                  style: TextStyle(fontSize: 24, color: isDark ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF60A5FA).withOpacity(0.2) : const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A)),
                  ),
                ),
              ],
            ),
          ),
          
          // Full Month Calendar Custom Widget
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark) BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Weekdays Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                
                // Days Grid
                _buildCalendarGrid(isDark),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
            child: Text(
              'Aktivitas Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
          
          // Task Timeline
          Expanded(
            child: dailyTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Kosong, tidak ada tugas terjadwal.',
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: dailyTasks.length,
                    itemBuilder: (context, index) {
                      final task = dailyTasks[index];
                      final time = DateFormat('HH:mm').format(task.deadline!);
                      return _buildTimelineItem(
                        time: time,
                        task: task,
                        isLast: index == dailyTasks.length - 1,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    final daysInMonth = _getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekday = _getFirstWeekday(_focusedMonth.year, _focusedMonth.month);
    
    // Total cells in grid (previous month empty cells + current month days)
    final totalCells = daysInMonth + firstWeekday - 1;
    final totalRows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalRows * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1 || index >= daysInMonth + firstWeekday - 1) {
          return const SizedBox.shrink(); // Empty slot
        }

        final day = index - firstWeekday + 2;
        final currentDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        
        final isSelected = currentDate.year == _selectedDate.year &&
                           currentDate.month == _selectedDate.month &&
                           currentDate.day == _selectedDate.day;
                           
        final isToday = currentDate.year == DateTime.now().year &&
                        currentDate.month == DateTime.now().month &&
                        currentDate.day == DateTime.now().day;

        final hasTasks = _hasTasksOnDate(currentDate);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A)).withOpacity(0.5), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? Colors.white 
                        : (isToday ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A)) : (isDark ? Colors.white : const Color(0xFF1E293B))),
                  ),
                ),
                if (hasTasks)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFFEF4444);
      case 'B': return const Color(0xFF3B82F6);
      case 'C': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }

  Widget _buildTimelineItem({required String time, required TaskModel task, required bool isLast, required bool isDark}) {
    final color = _getGradeColor(task.grade);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => widget.onToggle(task.id),
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: task.isDone ? const Color(0xFF10B981) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(color: task.isDone ? const Color(0xFF10B981) : color, width: 3),
                  ),
                  child: task.isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
            ],
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => widget.onToggle(task.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isDone ? Colors.grey : (isDark ? Colors.white : const Color(0xFF1E293B)),
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
