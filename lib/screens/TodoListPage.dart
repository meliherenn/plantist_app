import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';



class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Map<String, dynamic>> tasks = [];

  final List<Color> _availableColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.blueAccent,
    Colors.yellowAccent,
    Colors.green,
    Colors.teal,
    Colors.purpleAccent,
    Colors.grey,
  ];

  void _showAddReminderSheet({int? editIndex}) {
    String title = "";
    String subtitle = "";
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    Color selectedColor = _availableColors[Random().nextInt(_availableColors.length)];
    bool checked = false;
    bool hasAttachment = false;

    if (editIndex != null) {
      final existing = tasks[editIndex];
      title = existing['title'];
      subtitle = existing['subtitle'];
      selectedDate = existing['date'];
      selectedTime = existing['time'] != null && existing['time'] != ''
          ? TimeOfDay(
        hour: int.tryParse(existing['time'].split(":")[0]) ?? 0,
        minute: int.tryParse(existing['time'].split(":")[1]) ?? 0,
      )
          : null;
      selectedColor = existing['color'];
      checked = existing['checked'];
      hasAttachment = existing['attachment'] ?? false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24.h,
          left: 24.w,
          right: 24.w,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    Text(
                      editIndex != null ? "Edit Reminder" : "New Reminder",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        if (title.trim().isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Warning"),
                              content: const Text("Title cannot be empty!"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        setState(() {
                          final newTask = {
                            'title': title,
                            'subtitle': subtitle,
                            'date': selectedDate ?? DateTime.now(),
                            'time': selectedTime != null ? selectedTime!.format(context) : '',
                            'color': selectedColor,
                            'checked': checked,
                            'attachment': hasAttachment,
                          };
                          if (editIndex != null) {
                            tasks[editIndex] = newTask;
                          } else {
                            tasks.add(newTask);
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Text(editIndex != null ? "Save" : "Add"),
                    ),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Title (Title cannot be empty)"),
                  onChanged: (val) => title = val,
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Notes"),
                  onChanged: (val) => subtitle = val,
                ),
                SizedBox(height: 12.h),
                ListTile(
                  title: Text("Details"),
                  subtitle: Text(selectedDate == null
                      ? 'Today'
                      : DateFormat.yMMMd().format(selectedDate!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setModalState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  trailing: Icon(Icons.keyboard_arrow_right),
                ),
                ListTile(
                  title: Text("Attach a file"),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      setModalState(() {
                        hasAttachment = true;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editTask(int index) {
    _showAddReminderSheet(editIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));

    final todayTasks = tasks.where((t) => isSameDay(t['date'], today)).toList();
    final tomorrowTasks = tasks.where((t) => isSameDay(t['date'], tomorrow)).toList();
    final otherTasks = tasks.where((t) =>
    !isSameDay(t['date'], today) && !isSameDay(t['date'], tomorrow)).toList();


    Map<String, List<Map<String, dynamic>>> groupedTasks = {};
    for (var task in otherTasks) {
      final formattedDate = DateFormat('dd.MM.yyyy').format(task['date']);
      groupedTasks.putIfAbsent(formattedDate, () => []).add(task);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Plantist', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search, color: Colors.black))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView(
          children: [
            SizedBox(height: 8.h),
            Text("Today", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ...todayTasks.asMap().entries.map((entry) => _buildTask(entry.key, entry.value)).toList(),

            SizedBox(height: 16.h),
            Text("Tomorrow", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ...tomorrowTasks
                .asMap()
                .entries
                .map((entry) => _buildTask(entry.key + todayTasks.length, entry.value))
                .toList(),


            for (var entry in groupedTasks.entries) ...[
              SizedBox(height: 16.h),
              Text(entry.key, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ...entry.value.asMap().entries.map((e) {
                final taskIndex = todayTasks.length + tomorrowTasks.length;
                return _buildTask(taskIndex + e.key, e.value);
              }).toList(),
            ]
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: SizedBox(
          width: 320.w,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () => _showAddReminderSheet(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text("+ New Reminder", style: TextStyle(fontSize: 16.sp)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Widget _buildTask(int index, Map<String, dynamic> task) {
    DateTime taskDate = task['date'];
    DateTime now = DateTime.now();
    String dateLabel;

    if (isSameDay(taskDate, now)) {
      dateLabel = "Today";
    } else if (isSameDay(taskDate, now.add(Duration(days: 1)))) {
      dateLabel = "Tomorrow";
    } else {
      dateLabel = DateFormat('dd.MM.yyyy').format(taskDate);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (context) => _editTask(index),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) {
                setState(() => tasks.removeAt(index));
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              setState(() {
                task['checked'] = !(task['checked'] ?? false);
              });
            },
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: task['color'], width: 2),
                color: task['checked'] ? task['color'] : Colors.white,
              ),
            ),
          ),
          title: Text(task['title']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task['subtitle'] != null) Text(task['subtitle']),
              if (task['attachment'] == true)
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text("1 Attachment", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              if (task['time'] != null && task['time'] != '')
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: task['color']),
                    SizedBox(width: 4.w),
                    Text(task['time'], style: TextStyle(color: task['color'])),
                  ],
                ),
            ],
          ),
          trailing: Text(dateLabel),
        ),
      ),
    );
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
