import 'package:project_ta/constants/color.dart';
import 'package:project_ta/screens/admin_kupon_screen.dart';
import 'package:flutter/material.dart';
import 'package:project_ta/screens/master_screen.dart';
import 'package:project_ta/screens/scan_barcode_screen.dart';
import 'package:project_ta/screens/upload_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'login_screen.dart';

class BottomNavbarAdminScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavbarAdminScreen({super.key, this.initialIndex = 0});

  @override
  _BottomNavbarAdminState createState() => _BottomNavbarAdminState();
}

class _BottomNavbarAdminState extends State<BottomNavbarAdminScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    MasterScreen(),
    AdminKuponScreen(),
    UploadScreen(),
    ScanBarcodeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
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
      child: Scaffold(
        body: Center(
          child: _selectedIndex == 4
              ? Container() // Kosongkan karena logout akan diproses
              : _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryColor,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          selectedLabelStyle: TextStyle(height: 1.5),
          unselectedLabelStyle: TextStyle(height: 1.5),
          items: [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.dashboard, color: Colors.blue),
              icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
              label: "Master",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.card_giftcard, color: Colors.blue),
              icon: Icon(Icons.card_giftcard_outlined, color: Colors.grey),
              label: "Kupon",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.cloud_upload, color: Colors.blue),
              icon: Icon(Icons.cloud_upload_outlined, color: Colors.grey),
              label: "Upload",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.qr_code_scanner, color: Colors.blue),
              icon: Icon(Icons.qr_code_scanner_outlined, color: Colors.grey),
              label: "Scan",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.exit_to_app, color: Colors.blue),
              icon: Icon(Icons.exit_to_app_outlined, color: Colors.grey),
              label: "Logout",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if (index == 4) {
              // Jika menekan tombol logout
              context.read<AuthBloc>().add(LogoutEvent());
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}