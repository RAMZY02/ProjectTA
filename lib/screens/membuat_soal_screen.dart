import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:project_ta/bloc/auth/auth_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_bloc.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/models/soal_model.dart';
import 'package:project_ta/models/ujian_model.dart';

import '../bloc/auth/auth_state.dart';

class MembuatSoalScreen extends StatefulWidget {
  final UjianModel ujian;

  const MembuatSoalScreen({super.key, required this.ujian});

  @override
  State<MembuatSoalScreen> createState() => _MembuatSoalScreenState();
}

class _MembuatSoalScreenState extends State<MembuatSoalScreen> {

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final TextEditingController _optionCController = TextEditingController();
  final TextEditingController _optionDController = TextEditingController();
  final TextEditingController _optionEController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final TextEditingController _mathNotationController = TextEditingController();

  String? _selectedAnswer;
  String _questionType = 'Pilihan Ganda';
  String? _imagePath;
  String? _audioPath;
  String? _videoPath;
  String? _filePath;

  void _addQuestion(AuthState state) {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soal tidak boleh kosong')),
      );
      return;
    }

    if (_questionType == 'Pilihan Ganda' && _selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban yang benar')),
      );
      return;
    }

    final newQuestion = {
      'id_ujian': widget.ujian.id,
      'tipe': _questionType,
      'soal': _questionController.text,
      'opsi_a': _questionType == 'Pilihan Ganda' ? _optionAController.text : '-',
      'opsi_b': _questionType == 'Pilihan Ganda' ? _optionBController.text : '-',
      'opsi_c': _questionType == 'Pilihan Ganda' ? _optionCController.text : '-',
      'opsi_d': _questionType == 'Pilihan Ganda' ? _optionDController.text : '-',
      'opsi_e': _questionType == 'Pilihan Ganda' ? _optionEController.text : '-',
      'jawaban': _questionType == 'Pilihan Ganda' ? _selectedAnswer : '-',
      'pembahasan': _explanationController.text,
      'link_video': _videoPath ?? '-',
      'link_gambar': _imagePath ?? '-',
      'link_audio': _audioPath ?? '-',
      'link_file': _filePath ?? '-',
      'notasi_matematika': _mathNotationController.text.isNotEmpty
          ? _mathNotationController.text
          : '-',
    };

    if(state is Authenticated){
      context.read<SoalUjianBloc>().add(AddSoal(token: state.token, soalData: newQuestion));
    }

    setState(() {
      _clearForm();
    });
  }

  void _clearForm() {
    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    _optionEController.clear();
    _explanationController.clear();
    _mathNotationController.clear();
    _selectedAnswer = null;
    _imagePath = null;
    _audioPath = null;
    _videoPath = null;
    _filePath = null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Soal untuk ${widget.ujian.nama}'),
      ),
      body: SafeArea(
        child: BlocBuilder<SoalUjianBloc, SoalUjianState>(
          builder: (context, soalState){
            if (authState is Authenticated && soalState is SoalUjianInitial) {
              Future.microtask(() {
                context.read<SoalUjianBloc>().add(FetchSoalUjian2(token: authState.token, ujianId: widget.ujian.id));
              });
            }

            if(soalState is SoalUjianLoaded){
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Question Form Card
                    _buildQuestionForm(authState),
                    const SizedBox(height: 16),
                    // List of Added Questions
                    if (soalState.soalList.isNotEmpty) _buildQuestionList(soalState.soalList, authState),
                  ],
                ),
              );
            }
            else if(soalState is SoalUjianNotFound){
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Question Form Card
                    _buildQuestionForm(authState),
                    const SizedBox(height: 16),
                    Center(child: Text("Belum ada soal yang tersedia"))
                  ],
                ),
              );
            }
            else if (soalState is SoalUjianLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            else if (soalState is SoalUjianError) {
              return Center(child: Text(soalState.message));
            }
            else {
              return const Center(child: Text(""));
            }
          }
        )
      ),
    );
  }

  Widget _buildQuestionForm(AuthState authState) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Soal Baru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            // Question Type Selection
            const Text('Jenis Soal:'),
            _buildQuestionTypeSelector(),
            const SizedBox(height: 16),
            // Media Attachment Buttons
            const Text('Lampiran Media:'),
            const SizedBox(height: 8),
            _buildMediaButtons(),
            const SizedBox(height: 16),
            // Question Input
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Tulis soal disini',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Math Notation Preview
            if (_mathNotationController.text.isNotEmpty) _buildMathPreview(),
            // Options for Multiple Choice
            if (_questionType == 'Pilihan Ganda') _buildMultipleChoiceOptions(),
            // Explanation Field
            _buildExplanationField(),
            const SizedBox(height: 16),
            // Add Question Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _addQuestion(authState);
                },
                child: const Text('Tambah Soal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runSpacing: 8,
        children: [
          RadioListTile<String>(
            title: const Text('Pilihan Ganda'),
            value: 'Pilihan Ganda',
            groupValue: _questionType,
            onChanged: (value) => _updateQuestionType(value!),
          ),
          RadioListTile<String>(
            title: const Text('Isian'),
            value: 'isian',
            groupValue: _questionType,
            onChanged: (value) => _updateQuestionType(value!),
          ),
          RadioListTile<String>(
            title: const Text('Upload File'),
            value: 'upload file',
            groupValue: _questionType,
            onChanged: (value) => _updateQuestionType(value!),
          ),
        ],
      ),
    );
  }

  void _updateQuestionType(String value) {
    setState(() {
      _questionType = value;
      _selectedAnswer = null;
    });
  }

  Widget _buildMediaButtons() {
    return Wrap(
      spacing: 8,
      children: [
        IconButton(
          icon: const Icon(Icons.image),
          color: _imagePath != null ? Colors.blue : null,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.audiotrack),
          color: _audioPath != null ? Colors.blue : null,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: _videoPath != null ? Colors.blue : null,
          onPressed: () {}
        ),
        IconButton(
          icon: const Icon(Icons.insert_drive_file),
          color: _filePath != null ? Colors.blue : null,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.functions),
          color: _mathNotationController.text.isNotEmpty ? Colors.blue : null,
          onPressed: (){},
        ),
      ],
    );
  }

  Widget _buildMathPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pratinjau Notasi Matematika:'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Math.tex(
            _mathNotationController.text,
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilihan Jawaban:'),
        const SizedBox(height: 8),
        _buildOptionField('A', _optionAController),
        _buildOptionField('B', _optionBController),
        _buildOptionField('C', _optionCController),
        _buildOptionField('D', _optionDController),
        _buildOptionField('E', _optionEController),
        const SizedBox(height: 16),
        const Text('Pilih Jawaban yang Benar:'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['A', 'B', 'C', 'D', 'E'].map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(option),
                  selected: _selectedAnswer == option,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAnswer = selected ? option : null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExplanationField() {
    return TextField(
      controller: _explanationController,
      decoration: const InputDecoration(
        labelText: 'Pembahasan (mengapa jawaban benar)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildQuestionList(List<SoalModel> soal, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Soal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        if(authState is Authenticated)
        ...soal.map((question) => _buildQuestionCard(question, soal, authState.token)),
      ],
    );
  }

  Widget _buildOptionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Opsi $label',
          border: const OutlineInputBorder(),
          prefixText: '$label. ',
        ),
      ),
    );
  }

  Widget _buildQuestionCard(SoalModel question, List<SoalModel> soal, String token) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Soal ${soal.indexOf(question) + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // Implement edit functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    context.read<SoalUjianBloc>().add(DeleteSoal(token: token, id: question.id, id_ujian: widget.ujian.id));
                    setState(() {
                      soal.remove(question);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(question.soal),
            // if (question['notasi_matematika'] != '-') ...[
            //   const SizedBox(height: 8),
            //   Math.tex(
            //     question['notasi_matematika'],
            //     textStyle: const TextStyle(fontSize: 16),
            //   ),
            // ],
            if (question.tipe == 'Pilihan Ganda') ...[
              const SizedBox(height: 8),
              const Text('Pilihan Jawaban:'),
              _buildOptionPreview('A', question.opsiA),
              _buildOptionPreview('B', question.opsiB),
              _buildOptionPreview('C', question.opsiC),
              _buildOptionPreview('D', question.opsiD),
              _buildOptionPreview('E', question.opsiE),
              const SizedBox(height: 8),
              Text(
                'Jawaban benar: ${question.jawaban}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            ...[
            const SizedBox(height: 8),
            const Text('Pembahasan:'),
            Text(question.pembahasan),
          ],
            if (question.linkGambar != '-' ||
                question.linkAudio != '-' ||
                question.linkVideo != '-') ...[
              const SizedBox(height: 8),
              const Text('Lampiran:'),
              Wrap(
                spacing: 8,
                children: [
                  if (question.linkGambar != '-')
                    Chip(
                      label: const Text('Gambar'),
                      avatar: const Icon(Icons.image, size: 18),
                    ),
                  if (question.linkAudio != '-')
                    Chip(
                      label: const Text('Audio'),
                      avatar: const Icon(Icons.audiotrack, size: 18),
                    ),
                  if (question.linkVideo != '-')
                    Chip(
                      label: const Text('Video'),
                      avatar: const Icon(Icons.videocam, size: 18),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionPreview(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label. $value'),
    );
  }
}