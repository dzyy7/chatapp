import 'package:flutter/material.dart';
import 'package:chatapp/core/constants/app_colors.dart';
import 'package:chatapp/data/models/home_model.dart';

// --- BAGIAN 2: HALAMAN UTAMA ---
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ChatGroup> groups = [
    ChatGroup(name: "Flutter Developer", description: "Bahas UI/UX & State Management", pin: 123456),
    ChatGroup(name: "Circle Nongkrong", description: "Rencana mabar nanti malam", pin: 112233),
  ];

  // Fungsi untuk menampilkan Bottom Sheet kekinian
  void _showAddGroupBottomSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final pinController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparan untuk efek rounded
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 16
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 15)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar (Garis kecil di atas modal)
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text("Buat Grup Baru \u2728", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            SizedBox(height: 8),
            Text("Kumpulkan teman-temanmu dalam satu ruang obrolan.", style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 24),
            
            // TextFields dengan desain modern
            _buildModernTextField(controller: nameController, label: "Nama Grup", icon: Icons.group_work, color: AppColors.primary),
            SizedBox(height: 16),
            _buildModernTextField(controller: descController, label: "Deskripsi", icon: Icons.description, color: AppColors.secondary),
            SizedBox(height: 16),
            _buildModernTextField(controller: pinController, label: "PIN Keamanan", icon: Icons.lock, color: AppColors.warning, isNumber: true),
            SizedBox(height: 32),
            
            // Tombol Simpan Full-Width Gradient
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [AppColors.secondaryDark, AppColors.secondary]),
                boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      groups.add(ChatGroup(
                        name: nameController.text,
                        description: descController.text,
                        pin: int.tryParse(pinController.text) ?? 0,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text("Ciptakan Ruang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // AppBar Modern dengan Gradasi
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text("Pesan Kamu", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // Dekorasi latar belakang untuk mempercantik
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Daftar Grup dengan Animasi Transisi
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutBack,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      final clampedValue = value.clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - clampedValue)),
                        child: Opacity(opacity: clampedValue, child: child),
                      );
                    },
                    child: _buildGroupCard(groups[index], index),
                  );
                },
                childCount: groups.length,
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button yang Bouncy
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGroupBottomSheet,
        backgroundColor: AppColors.secondary,
        elevation: 8,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Grup Baru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  // --- WIDGET BANTUAN ---

  Widget _buildGroupCard(ChatGroup group, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withOpacity(0.06), blurRadius: 12, spreadRadius: 2, offset: Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: AppColors.primaryLight.withOpacity(0.3),
          splashColor: AppColors.primaryLight.withOpacity(0.5),
          onTap: () {
            // Aksi ke ruang obrolan
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Bergradasi
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(group.name[0].toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                SizedBox(width: 16),
                
                // Info Grup
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      SizedBox(height: 4),
                      Text(group.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                
                // Indikator Waktu/Notifikasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("12:00", style: TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w500)),
                    SizedBox(height: 6),
                    // Indikator jumlah pesan (Badge)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
                      child: Text("3", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({required TextEditingController controller, required String label, required IconData icon, required Color color, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: color),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
      ),
    );
  }
}