import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Memo extends StatefulWidget {
  const Memo({super.key});

  @override
  State<Memo> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<Memo> {
  List<Map<String, String>> notes = [];
  final TextEditingController _controller = TextEditingController();
  int? _editingIndex; // 편집 중인 메모 인덱스를 추적

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // 메모 저장
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedNotes = prefs.getStringList('notes') ?? [];
    setState(() {
      notes = savedNotes.map((note) {
        final parts = note.split('|');
        return {'name': parts[0], 'content': parts[1]};
      }).toList();
    });
  }

  // 메모 추가
  Future<void> _addNote() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        notes.add({'name': _controller.text, 'content': ''});
      });
      _controller.clear();
      await _saveNotes();
    }
  }

  // 메모 삭제
  Future<void> _deleteNote(int index) async {
    setState(() {
      notes.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null; // 삭제된 메모가 편집 중일 경우 편집 상태 해제
      }
    });
    await _saveNotes();
  }

  // 메모 내용 수정
  Future<void> _editNoteContent(int index, String newContent) async {
    setState(() {
      notes[index]['content'] = newContent;
    });
    await _saveNotes();
  }

  // 메모 이름 수정
  Future<void> _editNoteName(int index, String newName) async {
    setState(() {
      notes[index]['name'] = newName;
    });
    await _saveNotes();
  }

  // 로컬에 메모 저장
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotes =
        notes.map((note) => '${note['name']}|${note['content']}').toList();
    await prefs.setStringList('notes', savedNotes);
  }

  // 메모 이름 수정 다이얼로그
  Future<String?> _showEditNameDialog(
      BuildContext context, String currentName) {
    final TextEditingController editController =
        TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('메모 이름 수정'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: '새 메모 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(editController.text);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 메모 내용 입력 필드 (최대 높이로 보이게 설정)
  Widget _buildNoteContentEditor(int index) {
    final TextEditingController contentController =
        TextEditingController(text: notes[index]['content']!);

    contentController.addListener(() {
      _editNoteContent(index, contentController.text);
    });

    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 30.0),
      child: Column(
        children: [
          TextField(
            controller: contentController,
            decoration: InputDecoration(
              hintText: '메모 내용 입력',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            maxLines: null, // 입력 필드가 최대 높이로 보이도록 설정
            minLines: 19, // 최소 높이를 설정하여 화면 크기에 맞게 적당히 보이도록 함
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 텍스트 필드에서 입력한 내용을 저장하고 텍스트 필드 숨기기
                  _editNoteContent(index, contentController.text);
                  Navigator.pop(context); // BottomSheet 닫기
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 101, 91),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 13),
                    textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                child: const Text('저장'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면을 자동으로 조정하도록 설정
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '새 메모 추가',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('메모가 없습니다.'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(notes[index]['name']!),
                            onTap: () {
                              setState(() {
                                // 다른 메모 클릭 시 편집 상태 해제
                                if (_editingIndex != index) {
                                  _editingIndex = index;
                                } else {
                                  _editingIndex = null;
                                }
                              });
                              // 메모 클릭 시 내용 수정 필드도 보이게 함
                              showModalBottomSheet(
                                context: context,
                                builder: (_) {
                                  return _buildNoteContentEditor(index);
                                },
                              ).whenComplete(() {
                                setState(() {
                                  // BottomSheet가 닫히면 편집 상태를 해제
                                  _editingIndex = null;
                                });
                              });
                            },
                            selected:
                                _editingIndex == index, // 편집 중인 메모에만 선택 상태 표시
                            selectedTileColor: Colors.grey.shade300, // 눌린 상태 색상
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final newName = await _showEditNameDialog(
                                        context, notes[index]['name']!);
                                    if (newName != null && newName.isNotEmpty) {
                                      _editNoteName(index, newName);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteNote(index),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
