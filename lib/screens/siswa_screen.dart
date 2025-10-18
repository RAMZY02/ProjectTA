import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/auth/auth_state.dart';
import 'package:project_ta/bloc/users/users_bloc.dart';
import 'package:project_ta/bloc/users/users_event.dart';
import 'package:project_ta/bloc/users/users_state.dart';

class SiswaScreen extends StatefulWidget {
  const SiswaScreen({Key? key}) : super(key: key);

  @override
  _SiswaScreenState createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen> {
  int filterKelas = 7;
  List<int> id_user = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if(authState is Authenticated){
      context.read<UsersBloc>().add(FetchUsersByTingkatan(token: authState.token, kelas: '7'));
    }

    // Menambahkan listener untuk search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleNaikkanKelas(BuildContext context, AuthState authState, int kelas, List<int> siswa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin memproses kenaikan kelas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if(authState is Authenticated){
          context.read<UsersBloc>().add(UpdateUsersKelas(token: authState.token, kelas: kelas, notPromoted: siswa));
        }
        setState(() {
          id_user = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kenaikan kelas berhasil diproses')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Color _getKelasColor(int kelas) {
    switch (kelas) {
      case 7: return Colors.orange;
      case 8: return Colors.purple;
      case 9: return Colors.teal;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kenaikan Kelas Siswa'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari siswa berdasarkan nama atau NIS...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
          ),

          // Filter Kelas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ...List.generate(3, (index) {
                  final kelas = index + 7;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('Kelas $kelas'),
                      selected: filterKelas == kelas,
                      onSelected: (_) {
                        setState(() => filterKelas = kelas);
                        if(authState is Authenticated){
                          context.read<UsersBloc>().add(FetchUsersByTingkatan(token: authState.token, kelas: filterKelas.toString()));
                        }
                      },
                      backgroundColor: _getKelasColor(kelas).withOpacity(0.2),
                      selectedColor: _getKelasColor(kelas),
                      labelStyle: TextStyle(
                        color: filterKelas == kelas ? Colors.white : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Daftar Siswa
          BlocBuilder<UsersBloc, UsersState>(
              builder: (context, usersState){
                if(usersState is UsersLoading){
                  return Center(child: CircularProgressIndicator());
                }
                else if(usersState is UsersLoaded){
                  if(usersState.users.isEmpty){
                    return const Center(child: Text('Tidak ada data siswa'));
                  }
                  else{
                    // Filter data berdasarkan query pencarian
                    final filteredUsers = usersState.users.where((siswa) {
                      final nama = siswa.nama.toLowerCase();
                      final nis = siswa.nis.toString().toLowerCase();
                      return nama.contains(_searchQuery) || nis.contains(_searchQuery);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Tidak ada siswa yang sesuai dengan pencarian'),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final siswa = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getKelasColor(int.parse(siswa.kelas.substring(0, 1))),
                                child: Text(
                                  siswa.kelas.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(siswa.nama),
                              subtitle: Text('NIS: ${siswa.nis}'),
                              trailing: Checkbox(
                                value: siswa.tidakNaik,
                                onChanged: (value) {
                                  setState(() {
                                    siswa.tidakNaik = value ?? false;
                                  });
                                  if(siswa.tidakNaik == true){
                                    id_user.add(siswa.id);
                                    print("ini siswa");
                                    print(id_user);
                                  }
                                  else{
                                    id_user.remove(siswa.id);
                                    print("ini siswa");
                                    print(id_user);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
                else{
                  return Text("ini kosong");
                }
              }
          ),

          // Tombol Aksi
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Naikkan Kelas'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: (){
                      _handleNaikkanKelas(context, authState, filterKelas!, id_user);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}