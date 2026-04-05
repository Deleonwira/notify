import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/activity_model.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';

class AddActivityScreen extends StatefulWidget {
  final ActivityType type;
  final DateTime initialDate;

  const AddActivityScreen({
    super.key,
    required this.type,
    required this.initialDate,
  });

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;
  ActivityPriority _priority = ActivityPriority.none;
  final List<SubTask> _subTasks = [];

  void _addSubtask() {
    TextEditingController stController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Subtask'),
        content: TextField(
          controller: stController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Subtask title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (stController.text.trim().isNotEmpty) {
                setState(() {
                  _subTasks.add(SubTask(title: stController.text.trim()));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    final newAct = Activity(
      title: _titleController.text.trim(),
      type: widget.type,
      date: widget.initialDate,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      priority: _priority,
      subTasks: _subTasks,
    );

    await DatabaseHelper().insertActivity(newAct);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final dt = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        if (isStart) {
          _startTime = dt;
        } else {
          _endTime = dt;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String typeStr = widget.type.name.isEmpty 
        ? '' 
        : widget.type.name.capitalize();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New $typeStr',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DESC
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Notes / Description',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TIME TRACKING
            const Text(
              'Time Schedule',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      widget.type == ActivityType.reminder 
                          ? CupertinoIcons.bell 
                          : CupertinoIcons.clock,
                      color: const Color(0xFF7C3AED),
                    ),
                    title: Text(widget.type == ActivityType.reminder 
                        ? 'Notification Time' 
                        : 'Start Time'),
                    trailing: Text(
                      _startTime != null
                          ? DateFormat.Hm().format(_startTime!)
                          : 'Select >',
                      style: TextStyle(
                        color: _startTime != null ? Colors.black : Colors.grey,
                      ),
                    ),
                    onTap: () => _pickTime(true),
                  ),
                  const Divider(height: 1, indent: 50),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.clock_solid,
                      color: Color(0xFFA855F7),
                    ),
                    title: const Text('End Time'),
                    trailing: Text(
                      _endTime != null
                          ? DateFormat.Hm().format(_endTime!)
                          : 'Select >',
                      style: TextStyle(
                        color: _endTime != null ? Colors.black : Colors.grey,
                      ),
                    ),
                    onTap: () => _pickTime(false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PRIORITY
            const Text(
              'Priority Level',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ActivityPriority.values.map((p) {
                bool isSelected = _priority == p;
                Color pColor = p == ActivityPriority.none
                    ? Colors.grey
                    : (p == ActivityPriority.low
                          ? const Color(0xFFD8B4FE)
                          : (p == ActivityPriority.medium
                                ? const Color(0xFFE9D5FF)
                                : const Color(0xFFFF3B30)));
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? pColor.withAlpha(26) : Colors.white,
                        border: Border.all(
                          color: isSelected ? pColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          p.name.capitalize(),
                          style: TextStyle(
                            color: isSelected ? pColor : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // SUBTASKS (Only for Todo)
            if (widget.type == ActivityType.todo) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtasks',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.add_circled_solid,
                      color: Color(0xFF7C3AED),
                    ),
                    onPressed: _addSubtask,
                  ),
                ],
              ),
              if (_subTasks.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: _subTasks.map((st) {
                      return ListTile(
                        leading: const Icon(
                          CupertinoIcons.circle,
                          size: 20,
                          color: Colors.grey,
                        ),
                        title: Text(st.title),
                        trailing: GestureDetector(
                          onTap: () => setState(() => _subTasks.remove(st)),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                const Text(
                  'No subtasks added.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
