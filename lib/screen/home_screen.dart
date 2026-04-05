import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../widgets/navigation_widgets.dart';
import '../models/note_models.dart';
import '../models/category_model.dart';
import '../models/activity_model.dart';
import '../screen/add_note_screen.dart';
import '../screen/category_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Note> notes = [];
  List<Activity> activities = [];
  
  int selectedCategoryIndex = 0;
  List<Category> categories = [
    Category(
      id: -1,
      name: "All",
      color: const Color(0xFF3B0764),
      iconCodePoint: 0xf42d, // square_grid_2x2
    ),
  ];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadNotes();
    _loadActivities();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();
  }

  Future<void> _loadCategories() async {
    final dbCategories = await DatabaseHelper().getCategories();
    if (mounted) {
      setState(() {
        categories = [
          Category(
            id: -1,
            name: "All",
            color: const Color(0xFF3B0764),
            iconCodePoint: 0xf42d,
          ),
          ...dbCategories
        ];
        if (selectedCategoryIndex >= categories.length) selectedCategoryIndex = 0;
      });
    }
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await DatabaseHelper().getNotes();
    if (mounted) {
      setState(() {
        notes = loadedNotes;
      });
    }
  }

  Future<void> _loadActivities() async {
    final loadedActivities = await DatabaseHelper().getActivities();
    if (mounted) {
      setState(() {
        activities = loadedActivities;
      });
    }
  }

  void _showAllCategoriesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F8FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3B0764),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(categories.length, (index) {
                    final isSelected = index == selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B0764)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              IconData(categories[index].iconCodePoint,
                                  fontFamily: 'CupertinoIcons',
                                  fontPackage: 'cupertino_icons'),
                              color: isSelected ? Colors.white : categories[index].color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              categories[index].name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void deleteNote(int index) async {
    final deletedNote = notes[index];
    setState(() {
      notes.removeAt(index);
    });

    if (deletedNote.id != null) {
      await DatabaseHelper().deleteNote(deletedNote.id!);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFF7C3AED),
          onPressed: () async {
            await DatabaseHelper().insertNote(deletedNote);
            _loadNotes();
          },
        ),
      ),
    );
  }

  List<Note> get filteredNotes {
    return notes.where((note) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesCategory = true;
      if (selectedCategoryIndex > 0 && selectedCategoryIndex < categories.length) {
        matchesCategory = note.category == categories[selectedCategoryIndex].name;
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final displayNotes = filteredNotes;

    return Scaffold(
      drawer: const NavigationWidgets(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Notare',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF3B0764),
                              ),
                            ),
                          ],
                        ),
                        // Profile/Drawer Trigger
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.line_horizontal_3,
                                size: 18,
                                color: Color(0xFF3B0764),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                CupertinoIcons.clear_circled_solid,
                                color: Colors.grey[350],
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Category Chips ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedCategoryIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF3B0764)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF3B0764).withAlpha(77),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(10),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      IconData(categories[index].iconCodePoint,
                                          fontFamily: 'CupertinoIcons',
                                          fontPackage: 'cupertino_icons'),
                                      color: isSelected
                                          ? Colors.white
                                          : categories[index].color,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      categories[index].name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showAllCategoriesModal(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.square_grid_2x2,
                          size: 20,
                          color: Color(0xFF3B0764),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── My Notes Section Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  children: [
                    const Text(
                      'My Notes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B0764),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${displayNotes.length} notes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (displayNotes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.doc_text, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No notes found', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final note = displayNotes[index];
                    return _NoteCard(
                      note: note,
                      index: index,
                      formatDate: _formatDate,
                      onDelete: () {
                        final realIndex = notes.indexOf(note);
                        if (realIndex != -1) deleteNote(realIndex);
                      },
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => AddNoteScreen(existingNote: note),
                          ),
                        );
                        if (result == true) {
                          _loadNotes();
                        }
                      },
                    );
                  }, childCount: displayNotes.length),
                ),
              ),

            // ── Today's Tasks Section Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                child: Row(
                  children: [
                    const Text(
                      'Today\'s Tasks',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B0764),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${activities.length} tasks',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (activities.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.checkmark_circle, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('No tasks for today', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activity = activities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ActivityTile(
                          activity: activity,
                          onToggle: (val) async {
                            setState(() {
                              activity.isCompleted = val;
                            });
                            await DatabaseHelper().updateActivity(activity);
                          },
                          onDelete: () async {
                            await DatabaseHelper().deleteActivity(activity.id!);
                            _loadActivities();
                          },
                        ),
                      );
                    },
                    childCount: activities.length,
                  ),
                ),
              ),
          ],
        ),
      ),

      // ── FAB ──
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withAlpha(102),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () async {
              // 1. Select category first
              final Category? selected = await Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const CategorySelectionScreen()),
              );

              if (selected == null) return; // User cancelled

              // 2. Open AddNoteScreen with pre-filled category
              if (!mounted) return;
              final result = await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => AddNoteScreen(preSelectedCategory: selected),
                ),
              );

              if (result == true) {
                _loadNotes();
                _loadCategories();
              }
            },
            child: const Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Activity Tile Widget ──
class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ActivityTile({
    required this.activity,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (activity.type) {
      case ActivityType.todo:
        icon = CupertinoIcons.checkmark_circle;
        break;
      case ActivityType.event:
        icon = CupertinoIcons.calendar;
        break;
      case ActivityType.reminder:
        icon = CupertinoIcons.bell;
        break;
    }

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => onToggle(!activity.isCompleted),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activity.isCompleted ? activity.color : Colors.grey[300]!,
                    width: 2,
                  ),
                  color: activity.isCompleted ? activity.color : Colors.transparent,
                ),
                child: activity.isCompleted
                    ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                      color: activity.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(icon, size: 12, color: activity.color),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.type.name.toUpperCase()} • ${DateFormat('HH:mm').format(activity.date)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (activity.priority != ActivityPriority.none)
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: activity.priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Note Card Widget ──
class _NoteCard extends StatelessWidget {
  final Note note;
  final int index;
  final String Function(DateTime) formatDate;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.index,
    required this.formatDate,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Delete Note'),
              content: const Text('Are you sure you want to delete this note?'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: note.color.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color accent bar
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: note.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                // Title
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B0764),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Content preview
                Expanded(
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Date
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(note.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
