import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/user/user_bloc.dart';
import 'package:project_ta/bloc/user/user_event.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../constants/color.dart';
import 'package:project_ta/services/preferences_manager.dart';
import 'bottom_navbar_admin_screen.dart';
import 'bottom_navbar_guru_screen.dart';
import 'bottom_navbar_siswa_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  // Fungsi untuk menyimpan data login ke SharedPreferences
  Future<void> _saveLoginData(Map<String, dynamic> userData) async {
    await PreferencesManager.setBool('isLoggedIn', true);
    await PreferencesManager.setString('email', userData['email'] ?? '');
    await PreferencesManager.setString('password', userData['password'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon App
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 30),

                // Login Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Selamat Datang",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Silakan login untuk melanjutkan",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email harus diisi';
                            }
                            if (!value.contains('@')) {
                              return 'Email tidak valid';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.email, color: kPrimaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: kPrimaryColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontSize: 16),
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        ),
                        const SizedBox(height: 20),

                        // Password Field dengan toggle visibility
                        TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                            // Menambahkan suffix icon untuk toggle visibility
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Menggunakan kondisi untuk menentukan icon yang ditampilkan
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // Toggle state visibility password
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: kPrimaryColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          // Menggunakan state _isPasswordVisible untuk mengontrol obscureText
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(fontSize: 16),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(LoginEvent(
                                emailController.text,
                                passwordController.text,
                              ));
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) async {
                            if (state is AuthError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            } else if (state is Authenticated) {

                              final userData = {
                                'email': state.email,
                                'password': passwordController.text,
                              };

                              print('userdata disini');
                              print(userData);

                              await _saveLoginData(userData);

                              // Load user data ke UserBloc
                              context.read<UserBloc>().add(LoadUser(
                                id: state.id,
                                username: state.username,
                                kelas: state.kelas,
                                agama: state.agama,
                                role: state.role,
                                id_mapel: state.id_mapel,
                                mapel: state.mapel,
                                nomor_ortu: state.nomor_ortu,
                                token: state.token,
                                poin: state.poin,
                                profpic: state.profpic,
                                email: state.email,
                              ));

                              // Navigasi berdasarkan role
                              Widget targetScreen;
                              switch (state.role) {
                                case 'admin':
                                  targetScreen = BottomNavbarAdminScreen();
                                  break;
                                case 'siswa':
                                  targetScreen = BottomNavbarSiswaScreen();
                                  break;
                                case 'guru':
                                  targetScreen = BottomNavbarGuruScreen();
                                  break;
                                default:
                                  targetScreen = BottomNavbarSiswaScreen();
                              }

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => targetScreen),
                                    (route) => false,
                              );
                            }
                          },
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                ),
                                onPressed: state is AuthLoading ? null : () async {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(LoginEvent(
                                      emailController.text,
                                      passwordController.text,
                                    ));
                                  }
                                },
                                child: state is AuthLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}