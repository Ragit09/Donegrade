import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';
import 'calendar_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import '../../core/utils/toast_util.dart';
import '../../core/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'Selesaikan Arsitektur Donegrade',
      description: 'Review struktur BLoC dan integrasi Firebase.',
      grade: 'A',
      isDone: false,
      deadline: DateTime.now().add(const Duration(hours: 2)),
    ),
    TaskModel(
      id: '2',
      title: 'Meeting Mingguan Tim UI/UX',
      description: 'Membahas pembaruan desain untuk versi 2.0',
      grade: 'B',
      isDone: true,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _toggleTask(String id) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
      }
    });
  }

  void _showAddTaskModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedGrade = 'B';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas Baru',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas',
                        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: Icon(Icons.title, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Singkat',
                        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: Icon(Icons.description, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Prioritas (Grade)', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['A', 'B', 'C'].map((grade) {
                        final isSelected = selectedGrade == grade;
                        Color gradeColor = grade == 'A' ? Colors.red : (grade == 'B' ? Colors.blue : Colors.orange);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedGrade = grade),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? gradeColor : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? gradeColor : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Grade $grade',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Tenggat Waktu', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) setModalState(() => selectedDate = date);
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text(DateFormat('d MMM yyyy').format(selectedDate)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(context: context, initialTime: selectedTime);
                              if (time != null) setModalState(() => selectedTime = time);
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(selectedTime.format(context)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (titleController.text.isEmpty) {
                            ToastUtil.showTopToast(context, 'Judul tidak boleh kosong!', color: Colors.redAccent);
                            return;
                          }
                          final deadline = DateTime(
                            selectedDate.year, selectedDate.month, selectedDate.day,
                            selectedTime.hour, selectedTime.minute,
                          );
                          setState(() {
                            _tasks.add(TaskModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: titleController.text,
                              description: descController.text,
                              grade: selectedGrade,
                              deadline: deadline,
                            ));
                          });
                          Navigator.pop(context);
                          ToastUtil.showTopToast(context, 'Tugas berhasil ditambahkan!', color: const Color(0xFF10B981));
                        },
                        child: const Text('Simpan Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      _HomeDashboard(tasks: _tasks, onToggle: _toggleTask),
      CalendarPage(tasks: _tasks, onToggle: _toggleTask),
      StatsPage(tasks: _tasks),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          notchMargin: 8,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left 2 items
                _buildNavItem(context, 0, Icons.home_rounded, 'Home', isDark),
                _buildNavItem(context, 1, Icons.calendar_month_rounded, 'Jadwal', isDark),
                // Center spacer for FAB
                const SizedBox(width: 48),
                // Right 2 items
                _buildNavItem(context, 2, Icons.analytics_rounded, 'Statistik', isDark),
                _buildNavItem(context, 3, Icons.person_rounded, 'Profil', isDark),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF34D399), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddTaskModal,
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    final selectedColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A);
    final unselectedColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.only(bottom: isSelected ? 4.0 : 2.0),
                child: Icon(
                  icon, 
                  size: isSelected ? 26 : 24, 
                  color: isSelected ? selectedColor : unselectedColor
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                  fontFamily: 'Outfit',
                ),
                child: Text(label),
              ),
              const SizedBox(height: 4),
              // Animated dot indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                width: isSelected ? 4 : 0,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(String) onToggle;

  const _HomeDashboard({required this.tasks, required this.onToggle});

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Grade A', 'Grade B', 'Selesai'];
  
  bool _isLoggedIn = false;
  String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
    // Tambahkan listener agar otomatis reload jika profil atau status login berubah
    AuthService.authStateNotifier.addListener(_loadUserStatus);
  }

  @override
  void dispose() {
    AuthService.authStateNotifier.removeListener(_loadUserStatus);
    super.dispose();
  }

  Future<void> _loadUserStatus() async {
    final loggedIn = await AuthService.isUserLoggedIn();
    if (mounted) {
      if (loggedIn) {
        final name = await AuthService.getUserName();
        setState(() {
          _isLoggedIn = true;
          _userName = name;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _userName = 'Guest';
        });
      }
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFFEF4444);
      case 'B': return const Color(0xFF3B82F6);
      case 'C': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }

  List<TaskModel> get _filteredTasks {
    if (_selectedFilter == 'Selesai') {
      return widget.tasks.where((t) => t.isDone).toList();
    } else if (_selectedFilter == 'Grade A') {
      return widget.tasks.where((t) => t.grade == 'A' && !t.isDone).toList();
    } else if (_selectedFilter == 'Grade B') {
      return widget.tasks.where((t) => t.grade == 'B' && !t.isDone).toList();
    }
    return widget.tasks.where((t) => !t.isDone).toList();
  }

  @override
  Widget build(BuildContext context) {
    int totalDone = widget.tasks.where((t) => t.isDone).length;
    double progress = widget.tasks.isEmpty ? 0 : totalDone / widget.tasks.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM').format(DateTime.now()),
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Halo, $_userName!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E3A8A)),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFF1E3A8A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Progres Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text('${(progress * 100).toInt()}% Selesai', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), 
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                      ),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      selectedColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                      ),
                      onSelected: (bool selected) {
                        setState(() { _selectedFilter = filter; });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _filteredTasks.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.task_outlined, size: 80, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Tidak ada tugas', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskCard(task, isDark);
                      },
                      childCount: _filteredTasks.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: task.isDone ? const Color(0xFF10B981).withOpacity(0.5) : Colors.transparent, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onToggle(task.id),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => widget.onToggle(task.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(top: 2, right: 16),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: task.isDone ? const Color(0xFF10B981) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: task.isDone ? const Color(0xFF10B981) : (isDark ? Colors.grey.shade600 : Colors.grey.shade300), width: 2),
                    ),
                    child: task.isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? Colors.grey : (isDark ? Colors.white : const Color(0xFF1E293B)),
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: _getGradeColor(task.grade).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Icon(Icons.local_fire_department, size: 12, color: _getGradeColor(task.grade)),
                                const SizedBox(width: 4),
                                Text('Grade ${task.grade}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getGradeColor(task.grade))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (task.deadline != null)
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('HH:mm').format(task.deadline!),
                                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
