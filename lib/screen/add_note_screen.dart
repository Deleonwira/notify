import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/note_models.dart';
import '../models/category_model.dart';
import '../data/database_helper.dart';
import 'category_selection_screen.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? existingNote;
  final Category? preSelectedCategory;

  const AddNoteScreen({super.key, this.existingNote, this.preSelectedCategory});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? selectedCategory;
  Color? categoryColor;
  int? categoryIconCodePoint;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.existingNote != null) {
      titleController.text = widget.existingNote!.title;
      contentController.text = widget.existingNote!.content;
      selectedCategory = widget.existingNote!.category;
      categoryColor = widget.existingNote!.color;

      // Fetch icon for existing category
      if (selectedCategory != null) {
        final cats = await DatabaseHelper().getCategories();
        final cat = cats.firstWhere((c) => c.name == selectedCategory, 
            orElse: () => Category(name: '', iconCodePoint: 0xf42d)); // Default icon if not found
        if (mounted) {
          setState(() {
            categoryIconCodePoint = cat.iconCodePoint;
          });
        }
      }
    } else if (widget.preSelectedCategory != null) {
      setState(() {
        selectedCategory = widget.preSelectedCategory!.name;
        categoryColor = widget.preSelectedCategory!.color;
        categoryIconCodePoint = widget.preSelectedCategory!.iconCodePoint;
      });
    }
  }

  void saveNote() async {
    if (titleController.text.trim().isEmpty) return;

    final newNote = Note(
      id: widget.existingNote?.id,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      color: categoryColor ?? const Color(0xFF7C3AED),
      category: selectedCategory,
      createdAt: widget.existingNote?.createdAt,
    );

    if (widget.existingNote != null) {
      await DatabaseHelper().updateNote(newNote);
    } else {
      await DatabaseHelper().insertNote(newNote);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF007AFF), // iOS System Blue
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        title: Text(
          widget.existingNote != null ? 'Edit Note' : 'New Note',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: saveNote,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF007AFF), // iOS System Blue
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -1.0,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Note Title',
                      hintStyle: TextStyle(
                        color: Colors.grey[300],
                        fontWeight: FontWeight.w800,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Content field
                  TextField(
                    controller: contentController,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF3A3A3C),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: TextStyle(
                        color: Colors.grey[300],
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom toolbar for Category and Colors
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[100]!, width: 1),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              top: 10,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category & Trash button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => CategorySelectionScreen(
                              selectedCategory: selectedCategory,
                            ),
                          ),
                        );
                        if (result != null && result is Category) {
                          setState(() {
                            selectedCategory = result.name;
                            categoryColor = result.color;
                            categoryIconCodePoint = result.iconCodePoint;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            if (categoryIconCodePoint != null) ...[
                              Icon(
                                IconData(categoryIconCodePoint!,
                                    fontFamily: 'CupertinoIcons',
                                    fontPackage: 'cupertino_icons'),
                                size: 16,
                                color: categoryColor ?? const Color(0xFF1C1C1E),
                              ),
                              const SizedBox(width: 8),
                            ] else ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: categoryColor ?? Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              selectedCategory ?? 'No Category',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF1C1C1E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.existingNote != null)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final shouldDelete = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Delete Note?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  child: const Text('Delete'),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldDelete == true) {
                            await DatabaseHelper().deleteNote(widget.existingNote!.id!);
                            if (mounted) Navigator.pop(context, true);
                          }
                        },
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: Color(0xFFFF3B30),
                          size: 22,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
