import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/menu.dart';

Future<void> showDayRecordsSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.82,
      child: _DayRecordsSheet(date: DateUtils.dateOnly(date)),
    ),
  );
}

class _DayRecordsSheet extends StatelessWidget {
  const _DayRecordsSheet({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${date.year}年${date.month}月${date.day}日の記録',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: globalDrinkRecordsNotifier,
                builder: (context, allRecords, child) {
                  final records =
                      allRecords.where((record) {
                        final recordedAt = record['recordedAt'];
                        return recordedAt is DateTime &&
                            DateUtils.isSameDay(recordedAt, date);
                      }).toList()..sort(
                        (left, right) => (right['recordedAt'] as DateTime)
                            .compareTo(left['recordedAt'] as DateTime),
                      );

                  if (records.isEmpty) {
                    return const Center(
                      child: Text(
                        'この日の記録はありません',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _RecordDetailCard(record: records[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordDetailCard extends StatelessWidget {
  const _RecordDetailCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final recordedAt = record['recordedAt'] as DateTime;
    final memo = record['memo']?.toString() ?? '';
    final alcoholGrams = _asDouble(record['alcoholGrams']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                record['icon'] is IconData
                    ? record['icon'] as IconData
                    : Icons.local_drink_outlined,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['name'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_formatTime(recordedAt)} ・ ${record['volume']}ml ・ '
                    '${_formatNumber(_asDouble(record['abv']))}% ・ '
                    '${alcoholGrams.toStringAsFixed(1)}g',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  if (memo.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      memo,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: '記録の操作',
              onSelected: (value) {
                if (value == 'edit') {
                  showDialog<void>(
                    context: context,
                    builder: (context) =>
                        _EditDrinkRecordDialog(originalRecord: record),
                  );
                } else {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('編集')),
                PopupMenuItem(value: 'delete', child: Text('削除')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除しますか？'),
        content: Text('${record['name']} の記録を削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      deleteDrinkRecord(record);
    }
  }
}

class _EditDrinkRecordDialog extends StatefulWidget {
  const _EditDrinkRecordDialog({required this.originalRecord});

  final Map<String, dynamic> originalRecord;

  @override
  State<_EditDrinkRecordDialog> createState() => _EditDrinkRecordDialogState();
}

class _EditDrinkRecordDialogState extends State<_EditDrinkRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _volumeController;
  late final TextEditingController _abvController;
  late final TextEditingController _memoController;
  late DateTime _recordedAt;

  @override
  void initState() {
    super.initState();
    final record = widget.originalRecord;
    _nameController = TextEditingController(text: record['name'].toString());
    _volumeController = TextEditingController(
      text: record['volume'].toString(),
    );
    _abvController = TextEditingController(
      text: _formatNumber(_asDouble(record['abv'])),
    );
    _memoController = TextEditingController(
      text: record['memo']?.toString() ?? '',
    );
    _recordedAt = record['recordedAt'] as DateTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _volumeController.dispose();
    _abvController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('飲酒記録を編集'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '名前'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '名前を入力してください'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _volumeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(labelText: '量 (ml)'),
                        validator: _validateVolume,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _abvController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: '度数 (%)'),
                        validator: _validateAbv,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _memoController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: '体調メモ'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(_formatDateTime(_recordedAt)),
                  trailing: TextButton(
                    onPressed: _pickRecordedAt,
                    child: const Text('変更'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _save, child: const Text('更新')),
      ],
    );
  }

  Future<void> _pickRecordedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(_recordedAt.year - 10),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
    );
    if (time == null || !mounted) {
      return;
    }
    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (selectedDateTime.isAfter(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('未来の時刻は記録できません')));
      }
      return;
    }
    setState(() {
      _recordedAt = selectedDateTime;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    updateDrinkRecord(
      originalRecord: widget.originalRecord,
      name: _nameController.text,
      volume: int.parse(_volumeController.text),
      abv: double.parse(_abvController.text),
      recordedAt: _recordedAt,
      memo: _memoController.text,
    );
    Navigator.of(context).pop();
  }
}

String? _validateVolume(String? value) {
  final volume = int.tryParse(value?.trim() ?? '');
  if (volume == null || volume <= 0) {
    return '1以上';
  }
  if (volume > 10000) {
    return '10000以下';
  }
  return null;
}

String? _validateAbv(String? value) {
  final abv = double.tryParse(value?.trim() ?? '');
  if (abv == null || abv <= 0) {
    return '0より大きく';
  }
  if (abv > 100) {
    return '100以下';
  }
  return null;
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString()) ?? 0;
}

String _formatNumber(double value) {
  return value == value.toInt() ? value.toInt().toString() : value.toString();
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDateTime(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}/$month/$day ${_formatTime(value)}';
}
