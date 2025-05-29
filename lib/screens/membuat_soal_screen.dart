import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MembuatSoalScreen extends StatefulWidget {
  final Map<String, dynamic> ujian;

  const MembuatSoalScreen({super.key, required this.ujian});

  @override
  State<MembuatSoalScreen> createState() => _MembuatSoalScreenState();
}

class _MembuatSoalScreenState extends State<MembuatSoalScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'id': '1',
      "id_ujian": "1",
      'soal': 'Ibu kota Indonesia',
      'opsi_a': 'Jakarta',
      'opsi_b': 'Bandung',
      'opsi_c': 'Thailand',
      'opsi_d': 'Korea',
      'opsi_e': 'China',
      'jawaban': 'Jakarta',
      "tipe": "pilihan_ganda",
      "pembahasan": "Jakarta adalah ibukota Indonesia sejak tahun 1946",
      "link_video": "-",
      "link_gambar": "-",
      "link_audio": "-",
      "link_file": "-",
      "notasi_matematika": '-'
    },
    {
      'id': '2',
      "id_ujian": "1",
      'soal': '2 + 2 = ?',
      'opsi_a': '-',
      'opsi_b': '-',
      'opsi_c': '-',
      'opsi_d': '-',
      'opsi_e': '-',
      'jawaban': '-',
      "tipe": "isian",
      "pembahasan": "Penjumlahan dasar",
      "link_video": "-",
      "link_gambar": "-",
      "link_audio": "-",
      "link_file": "-",
      "notasi_matematika": '-'
    },
  ];

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final TextEditingController _optionCController = TextEditingController();
  final TextEditingController _optionDController = TextEditingController();
  final TextEditingController _optionEController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final TextEditingController _mathNotationController = TextEditingController();

  String? _selectedAnswer;
  String _questionType = 'pilihan_ganda';
  String? _imagePath;
  String? _audioPath;
  String? _videoPath;
  String? _filePath;

  void _addQuestion() {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soal tidak boleh kosong')),
      );
      return;
    }

    if (_questionType == 'pilihan_ganda' && _selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban yang benar')),
      );
      return;
    }

    final newQuestion = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'id_ujian': widget.ujian['id'],
      'tipe': _questionType,
      'soal': _questionController.text,
      'opsi_a': _questionType == 'pilihan_ganda' ? _optionAController.text : '-',
      'opsi_b': _questionType == 'pilihan_ganda' ? _optionBController.text : '-',
      'opsi_c': _questionType == 'pilihan_ganda' ? _optionCController.text : '-',
      'opsi_d': _questionType == 'pilihan_ganda' ? _optionDController.text : '-',
      'opsi_e': _questionType == 'pilihan_ganda' ? _optionEController.text : '-',
      'jawaban': _questionType == 'pilihan_ganda' ? _selectedAnswer : '-',
      'pembahasan': _explanationController.text,
      'link_video': _videoPath ?? '-',
      'link_gambar': _imagePath ?? '-',
      'link_audio': _audioPath ?? '-',
      'link_file': _filePath ?? '-',
      'notasi_matematika': _mathNotationController.text.isNotEmpty
          ? _mathNotationController.text
          : '-',
    };

    setState(() {
      _questions.add(newQuestion);
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

  void _showMediaOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Tambah Gambar'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagePath = 'path/to/image.jpg';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('Tambah Audio'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _audioPath = 'path/to/audio.mp3';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Tambah Video'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _videoPath = 'path/to/video.mp4';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Tambah File'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _filePath = 'path/to/file.pdf';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Soal untuk ${widget.ujian['title']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: (){},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question Form Card
              _buildQuestionForm(),
              const SizedBox(height: 16),
              // List of Added Questions
              if (_questions.isNotEmpty) _buildQuestionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionForm() {
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
            if (_questionType == 'pilihan_ganda') _buildMultipleChoiceOptions(),
            // Explanation Field
            _buildExplanationField(),
            const SizedBox(height: 16),
            // Add Question Button
            Center(
              child: ElevatedButton(
                onPressed: _addQuestion,
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
            value: 'pilihan_ganda',
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
            value: 'upload_file',
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

  Widget _buildQuestionList() {
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
        ..._questions.map((question) => _buildQuestionCard(question)).toList(),
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

  Widget _buildQuestionCard(Map<String, dynamic> question) {
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
                  'Soal ${_questions.indexOf(question) + 1}',
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
                    setState(() {
                      _questions.remove(question);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(question['soal']),
            if (question['notasi_matematika'] != '-') ...[
              const SizedBox(height: 8),
              Math.tex(
                question['notasi_matematika'],
                textStyle: const TextStyle(fontSize: 16),
              ),
            ],
            if (question['tipe'] == 'pilihan_ganda') ...[
              const SizedBox(height: 8),
              const Text('Pilihan Jawaban:'),
              _buildOptionPreview('A', question['opsi_a']),
              _buildOptionPreview('B', question['opsi_b']),
              _buildOptionPreview('C', question['opsi_c']),
              _buildOptionPreview('D', question['opsi_d']),
              _buildOptionPreview('E', question['opsi_e']),
              const SizedBox(height: 8),
              Text(
                'Jawaban benar: ${question['jawaban']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (question['pembahasan'] != null && question['pembahasan'].isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Pembahasan:'),
              Text(question['pembahasan']),
            ],
            if (question['link_gambar'] != '-' ||
                question['link_audio'] != '-' ||
                question['link_video'] != '-' ||
                question['link_file'] != '-') ...[
              const SizedBox(height: 8),
              const Text('Lampiran:'),
              Wrap(
                spacing: 8,
                children: [
                  if (question['link_gambar'] != '-')
                    Chip(
                      label: const Text('Gambar'),
                      avatar: const Icon(Icons.image, size: 18),
                    ),
                  if (question['link_audio'] != '-')
                    Chip(
                      label: const Text('Audio'),
                      avatar: const Icon(Icons.audiotrack, size: 18),
                    ),
                  if (question['link_video'] != '-')
                    Chip(
                      label: const Text('Video'),
                      avatar: const Icon(Icons.videocam, size: 18),
                    ),
                  if (question['link_file'] != '-')
                    Chip(
                      label: const Text('File'),
                      avatar: const Icon(Icons.insert_drive_file, size: 18),
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