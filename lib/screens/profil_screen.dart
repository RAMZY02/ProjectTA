import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/infoPengguna_screen.dart';
import 'package:project_ta/screens/login_screen.dart';
import 'package:project_ta/screens/rapot_screen.dart';
import 'package:project_ta/screens/riwayatUjian_screen.dart';
import 'package:project_ta/screens/temanKelas_screen.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'kupon_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileAppBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: _ProfileMenu(),
          ),
        ],
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: kToolbarHeight),
          // Foto Profil
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/1.jpg'),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 16),
          // Nama User
          Text(
            'Ara Chan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Kelas dan Poin
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Kelas 7A',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow[300], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '1.500 Poin',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.person,
      'title': 'Info Pengguna',
      'color': Colors.blue,
      'route': '/info-pengguna',
    },
    {
      'icon': Icons.card_giftcard,
      'title': 'Kupon',
      'color': Colors.purple,
      'route': '/kupon',
    },
    {
      'icon': Icons.history,
      'title': 'Riwayat Ujian',
      'color': Colors.orange,
      'route': '/riwayat-ujian',
    },
    {
      'icon': Icons.assignment,
      'title': 'Rapot',
      'color': Colors.grey,
      'route': '/rapot',
    },
    {
      'icon': Icons.people,
      'title': 'Teman Kelas',
      'color': Colors.green,
      'route': '/teman-kelas',
    },
    {
      'icon': Icons.logout,
      'title': 'Keluar',
      'color': Colors.red,
      'route': '/logout',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Daftar Menu
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final menu = menuItems[index];
              return _buildMenuCard(context, menu);
            },
          ),
        ],
      ),
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
              if (menu['route'] == '/info-pengguna') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InfoPenggunaScreen(),
                  ),
                );
              } else if (menu['route'] == '/rapot') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RapotScreen(),
                  ),
                );
              } else if (menu['route'] == '/kupon') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KuponScreen(),
                  ),
                );
              } else if (menu['route'] == '/riwayat-ujian') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RiwayatUjianScreen(),
                  ),
                );
              } else if (menu['route'] == '/teman-kelas') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TemanKelasScreen(),
                  ),
                );
              } else {
                context.read<AuthBloc>().add(LogoutEvent());
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
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