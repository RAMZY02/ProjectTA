import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/user/user_state.dart';
import 'package:project_ta/screens/admin_kupon_screen.dart';
import 'package:project_ta/screens/login_screen.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../services/preferences_manager.dart';

class ProfilAdminScreen extends StatelessWidget {
  const ProfilAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            // App Bar yang tetap (tidak ikut scroll)
            _ProfileAppBar(),

            // Bagian menu yang dapat di-scroll dengan LayoutBuilder
            Expanded(
              child: _ProfileMenu(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        height: 300, // Tinggi tetap untuk app bar
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff886ff2),
              Color(0xff6849ef),
            ],
          ),
        ),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            if (authState is! Authenticated) {
              return const Center(
                child: Text(
                  "Login Dulu",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            if (userState is UserLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: kToolbarHeight),
                  // Foto Profil
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userState.profpic != '-'
                        ? NetworkImage(userState.profpic)
                        : const AssetImage('assets/icons/avatar-default-icon.png')
                    as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  // Nama User
                  Text(
                    userState.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
                  "GG",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.card_giftcard,
      'title': 'Kupon',
      'color': Colors.blue,
      'route': '/admin-kupon',
    },
    {
      'icon': Icons.logout,
      'title': 'Keluar',
      'color': Colors.red,
      'route': '/logout',
    },
  ];

  // Fungsi untuk logout
  Future<void> logout(BuildContext context) async {
    await PreferencesManager.setBool('isLoggedIn', false);
    await PreferencesManager.remove('email');
    await PreferencesManager.remove('password');

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Menghitung jumlah kolom berdasarkan lebar layar
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;

        // Menggunakan logika yang sama seperti di TopVideoScreen
        crossAxisCount = (screenWidth / 300).round();

        // Untuk memastikan minimal 2 kolom dan maksimal 4 kolom
        crossAxisCount = crossAxisCount.clamp(2, 4);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.5, // Sesuaikan aspect ratio untuk menu
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final menu = menuItems[index];
            return _buildMenuCard(context, menu);
          },
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, Map<String, dynamic> menu) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is AuthInitial) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (menu['route'] == '/admin-kupon') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminKuponScreen(),
                  ),
                );
              } else {
                logout(context);
                context.read<AuthBloc>().add(LogoutEvent());
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: menu['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      menu['icon'],
                      color: menu['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    menu['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}