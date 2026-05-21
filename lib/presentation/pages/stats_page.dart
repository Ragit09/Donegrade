import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';

class StatsPage extends StatefulWidget {
  final List<TaskModel> tasks;

  const StatsPage({super.key, required this.tasks});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Perhitungan Inti
    int totalTasks = widget.tasks.length;
    int totalDone = widget.tasks.where((t) => t.isDone).length;
    int totalPending = widget.tasks.where((t) => !t.isDone).length;
    double completionRate = totalTasks == 0 ? 0.0 : (totalDone / totalTasks) * 100;
    
    int gradeATotal = widget.tasks.where((t) => t.grade == 'A').length;
    int gradeADone = widget.tasks.where((t) => t.grade == 'A' && t.isDone).length;

    int gradeBTotal = widget.tasks.where((t) => t.grade == 'B').length;
    int gradeBDone = widget.tasks.where((t) => t.grade == 'B' && t.isDone).length;

    int gradeCTotal = widget.tasks.where((t) => t.grade == 'C').length;
    int gradeCDone = widget.tasks.where((t) => t.grade == 'C' && t.isDone).length;

    // Perhitungan Tren Mingguan (Menggunakan data Deadline)
    // Mencari jumlah tugas yang selesai berdasarkan hari tenggat waktu (7 hari terakhir hingga hari ini)
    final now = DateTime.now();
    List<FlSpot> weeklySpots = [];
    List<String> weekDays = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      weekDays.add(DateFormat('E').format(date)); // Sen, Sel, Rab...
      
      final tasksOnDate = widget.tasks.where((t) {
        if (t.deadline == null) return false;
        return t.deadline!.year == date.year && t.deadline!.month == date.month && t.deadline!.day == date.day;
      }).length;
      
      final doneOnDate = widget.tasks.where((t) {
        if (t.deadline == null || !t.isDone) return false;
        return t.deadline!.year == date.year && t.deadline!.month == date.month && t.deadline!.day == date.day;
      }).length;
      
      weeklySpots.add(FlSpot((6 - i).toDouble(), doneOnDate.toDouble()));
    }
    
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            title: Text(
              'Statistik Produktivitas',
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards
                  Row(
                    children: [
                      _buildKPICard('Total Tugas', '$totalTasks', Icons.assignment, const Color(0xFF3B82F6), isDark),
                      const SizedBox(width: 16),
                      _buildKPICard('Penyelesaian', '${completionRate.toStringAsFixed(1)}%', Icons.analytics, const Color(0xFF10B981), isDark),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pie Chart Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Komposisi Status Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: totalTasks == 0 
                                ? Center(child: Text('Tidak ada data', style: TextStyle(color: Colors.grey.shade500)))
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                              setState(() {
                                                if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                                  touchedPieIndex = -1;
                                                  return;
                                                }
                                                touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                              });
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                          sectionsSpace: 4,
                                          centerSpaceRadius: 50,
                                          sections: _showingPieSections(totalDone, totalPending, isDark),
                                        ),
                                      ),
                                      // Text di tengah Donut
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${completionRate.toStringAsFixed(0)}%',
                                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                                          ),
                                          Text(
                                            'Selesai',
                                            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem('Selesai', totalDone, const Color(0xFF10B981), isDark, completionRate),
                                  const SizedBox(height: 16),
                                  _buildLegendItem('Tertunda', totalPending, const Color(0xFFF59E0B), isDark, 100 - completionRate),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Line Chart Section (Tren Mingguan)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tren Produktivitas Mingguan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                        Text('Tugas Selesai (7 Hari Terakhir)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 && value.toInt() < weekDays.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(weekDays[value.toInt()], style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 1 == 0) {
                                        return Text('${value.toInt()}', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600));
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0, maxX: 6, minY: 0,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: weeklySpots,
                                  isCurved: true,
                                  color: const Color(0xFF10B981),
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                      radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF10B981)
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFF10B981).withOpacity(0.15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  // Detail Progress Text
                  Text('Rincian Akurasi Penyelesaian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildGradeProgressDetailed(isDark, 'Grade A', gradeATotal == 0 ? 0 : gradeADone / gradeATotal, gradeADone, gradeATotal, const Color(0xFFEF4444)),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                        _buildGradeProgressDetailed(isDark, 'Grade B', gradeBTotal == 0 ? 0 : gradeBDone / gradeBTotal, gradeBDone, gradeBTotal, const Color(0xFF3B82F6)),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                        _buildGradeProgressDetailed(isDark, 'Grade C', gradeCTotal == 0 ? 0 : gradeCDone / gradeCTotal, gradeCDone, gradeCTotal, const Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingPieSections(int done, int pending, bool isDark) {
    return List.generate(2, (i) {
      final isTouched = i == touchedPieIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 28.0 : 22.0;
      
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xFF10B981),
            value: done.toDouble(),
            title: '$done',
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xFFF59E0B),
            value: pending.toDouble(),
            title: '$pending',
            radius: radius,
            titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
          );
        default:
          throw Error();
      }
    });
  }

  BarChartGroupData _makeBarData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color, bool isDark, double percentage) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
              Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18)),
      ],
    );
  }

  Widget _buildGradeProgressDetailed(bool isDark, String title, double progress, int done, int total, Color color) {
    final percentStr = (progress * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.flag_circle, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
              ],
            ),
            Text('$percentStr% ($done/$total)', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}
