import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../data/dummy_data.dart';
import '../widgets/navigation_widgets.dart';
import '../models/note_models.dart';
import '../screen/add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Note> notes = [];
  int selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    notes = List.from(dummyNotes);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void addNote(Note newNote) {
    setState(() {
      notes.insert(0, newNote);
    });
  }

  void deleteNote(int index) {
    final deletedNote = notes[index];
    setState(() {
      notes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFF007AFF),
          onPressed: () {
            setState(() {
              notes.insert(index, deletedNote);
            });
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
      return matchesSearch;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final months = [
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
                              'Notes',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                        // Menu & count
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF).withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${notes.length} notes',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (ctx) => GestureDetector(
                                onTap: () => Scaffold.of(ctx).openDrawer(),
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
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = index;
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
                                ? const Color(0xFF1C1C1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1C1C1E,
                                      ).withAlpha(77),
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
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Notes Grid or Empty State ──
            if (displayNotes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No notes found'
                            : 'No notes yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Tap + to create your first note',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
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
                    );
                  }, childCount: displayNotes.length),
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
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withAlpha(102),
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
              final newNote = await Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const AddNoteScreen()),
              );
              if (newNote != null) {
                addNote(newNote);
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

// ── Note Card Widget ──
class _NoteCard extends StatelessWidget {
  final Note note;
  final int index;
  final String Function(DateTime) formatDate;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.index,
    required this.formatDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
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
                  color: Color(0xFF1C1C1E),
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
                  Icon(CupertinoIcons.clock, size: 12, color: Colors.grey[400]),
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
    );
  }
}
