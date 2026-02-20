import 'package:flutter/material.dart';
import 'package:chatapp/data/models/home_model.dart';
import 'package:chatapp/core/constants/app_colors.dart';

// Gunakan class AppColors yang kamu berikan di sini
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ChatGroup> groups = [
    ChatGroup(name: "Grup 1", description: "Deskripsi Grup 1", pin: 123456),
  ];

  void _showAddGroupDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text("Tambah Grup Baru", style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nama Grup",
                labelStyle: TextStyle(color: AppColors.primary),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Deskripsi"),
            ),
            TextField(
              controller: pinController,
              decoration: InputDecoration(labelText: "PIN"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() {
                groups.add(ChatGroup(
                  name: nameController.text,
                  description: descController.text,
                  pin: int.tryParse(pinController.text) ?? 0,
                ));
              });
              Navigator.pop(context);
            },
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Chat Groups"),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: groups.length,
        separatorBuilder: (context, index) => Divider(color: AppColors.divider, height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(groups[index].name[0], style: TextStyle(color: AppColors.primaryDark)),
            ),
            title: Text(groups[index].name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            subtitle: Text(groups[index].description, style: TextStyle(color: AppColors.textSecondary)),
            trailing: Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {
              // Navigasi ke dalam chat grup
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        backgroundColor: AppColors.secondary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}