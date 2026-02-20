// lib/presentation/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/group_model.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sekarang kita gunakan GroupModel dari integrasi API
  final List<GroupModel> groups = [];

  void _showAddGroupBottomSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final pinController = TextEditingController();
    
    // Simpan context bloc agar bisa diakses di dalam bottom sheet
    final homeBloc = context.read<HomeBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
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
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 24),
            Text("Buat Grup Baru \u2728", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            SizedBox(height: 24),
            
            _buildModernTextField(controller: nameController, label: "Nama Grup", icon: Icons.group_work, color: AppColors.primary),
            SizedBox(height: 16),
            _buildModernTextField(controller: descController, label: "Deskripsi", icon: Icons.description, color: AppColors.secondary),
            SizedBox(height: 16),
            _buildModernTextField(controller: pinController, label: "PIN (6 Digit)", icon: Icons.lock, color: AppColors.warning, isNumber: true),
            SizedBox(height: 32),
            
            // --- BLOC CONSUMER UNTUK BUTTON ---
            BlocProvider.value(
              value: homeBloc, // Gunakan Bloc dari HomePage
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeCreateGroupSuccess) {
                    Navigator.pop(context); // Tutup BottomSheet
                    
                    // Tambahkan ke UI
                    setState(() {
                      groups.add(state.newGroup);
                    });
                    
                    // Tampilkan Snackbar Hijau
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
                    );
                  } else if (state is HomeError) {
                    // Tampilkan Snackbar Merah
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage), backgroundColor: AppColors.error),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is HomeLoading;

                  return Container(
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
                      onPressed: isLoading ? null : () {
                        // Validasi simpel
                        if (nameController.text.isNotEmpty && pinController.text.length == 6) {
                          context.read<HomeBloc>().add(
                            CreateGroupEvent(
                              name: nameController.text,
                              description: descController.text,
                              pin: int.parse(pinController.text),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Isi data dengan benar dan pastikan PIN 6 digit!"), backgroundColor: AppColors.warning)
                          );
                        }
                      },
                      child: isLoading 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Ciptakan Ruang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ... Sisa kode AppBar, ListView dan _buildGroupCard sama dengan sebelumnya ...
  // PASTIKAN parameter _buildGroupCard menggunakan `GroupModel` bukan `ChatGroup`

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

  Widget _buildGroupCard(GroupModel group, int index) {
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