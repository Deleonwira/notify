import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../data/database_helper.dart';
import '../models/category_model.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String? selectedCategory;

  const CategorySelectionScreen({super.key, this.selectedCategory});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseHelper().getCategories();
    setState(() {
      categories = cats;
    });
  }

  void _showAddCategoryModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = const Color(0xFF3B82F6);
    final List<Color> colorOptions = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFEF4444),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Category Name',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colorOptions.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black45, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          final newCategory = Category(
                            name: name,
                            color: selectedColor,
                            iconCodePoint: CupertinoIcons.folder.codePoint, // Default icon
                          );

                          await DatabaseHelper().insertCategory(newCategory);
                          if (mounted) {
                            Navigator.pop(context);
                            _loadCategories();
                          }
                        },
                        child: const Text(
                          'Add Category',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select Category',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_back,
            color: Color(0xFF007AFF),
            size: 28,
          ),
        ),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 16),
            onPressed: () => _showAddCategoryModal(context),
            child: const Icon(
              CupertinoIcons.add,
              color: Color(0xFF007AFF),
              size: 28,
            ),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: CupertinoActivityIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: categories.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 64,
                endIndent: 24,
                color: Colors.grey[100],
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat.name == widget.selectedCategory;
                return ListTile(
                  onTap: () {
                    Navigator.pop(context, cat);
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cat.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      IconData(cat.iconCodePoint,
                          fontFamily: 'CupertinoIcons',
                          fontPackage: 'cupertino_icons'),
                      color: cat.color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFF007AFF)
                          : const Color(0xFF1C1C1E),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: Color(0xFF007AFF),
                          size: 20,
                        )
                      : null,
                );
              },
            ),
    );
  }
}
