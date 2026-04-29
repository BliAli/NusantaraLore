import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';

class TimezoneConverter extends StatefulWidget {
  const TimezoneConverter({super.key});

  @override
  State<TimezoneConverter> createState() => _TimezoneConverterState();
}

class _TimezoneConverterState extends State<TimezoneConverter> {
  String _selectedTimezone = 'WIB';
  TimeOfDay _selectedTime = TimeOfDay.now();

  static const _timezones = {
    'WIB': {'offset': 7, 'label': 'WIB (Jakarta)', 'zone': 'Asia/Jakarta'},
    'WITA': {'offset': 8, 'label': 'WITA (Makassar)', 'zone': 'Asia/Makassar'},
    'WIT': {'offset': 9, 'label': 'WIT (Jayapura)', 'zone': 'Asia/Jayapura'},
    'GMT': {'offset': 0, 'label': 'GMT (London)', 'zone': 'Europe/London'},
    'JST': {'offset': 9, 'label': 'JST (Tokyo)', 'zone': 'Asia/Tokyo'},
  };

  Map<String, String> _getConvertedTimes() {
    final baseMinutes =
        _selectedTime.hour * 60 + _selectedTime.minute;
    final baseOffset = (_timezones[_selectedTimezone]!['offset'] as int);

    final result = <String, String>{};
    for (final entry in _timezones.entries) {
      final targetOffset = entry.value['offset'] as int;
      final diff = targetOffset - baseOffset;
      var targetMinutes = baseMinutes + (diff * 60);

      String dayLabel = '';
      if (targetMinutes < 0) {
        targetMinutes += 24 * 60;
        dayLabel = ' (kemarin)';
      } else if (targetMinutes >= 24 * 60) {
        targetMinutes -= 24 * 60;
        dayLabel = ' (besok)';
      }

      final h = targetMinutes ~/ 60;
      final m = targetMinutes % 60;
      result[entry.key] =
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}$dayLabel';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final convertedTimes = _getConvertedTimes();
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal festival & pertunjukan budaya',
            style: TextStyle(color: kColorTextLight, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedTimezone,
                  decoration: const InputDecoration(labelText: 'Zona Waktu'),
                  items: _timezones.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value['label'] as String),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedTimezone = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() => _selectedTime = time);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hari ini: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now)}',
            style: const TextStyle(fontSize: 12, color: kColorTextLight),
          ),
          const SizedBox(height: 24),
          const Text(
            'Waktu di Zona Lain',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...convertedTimes.entries.map((entry) {
            final isSelected = entry.key == _selectedTimezone;
            final tzInfo = _timezones[entry.key]!;

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? kColorPrimary.withValues(alpha: 0.1)
                    : kColorSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? kColorPrimary
                      : kColorSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tzInfo['label'] as String,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        'UTC${(tzInfo['offset'] as int) >= 0 ? '+' : ''}${tzInfo['offset']}',
                        style: const TextStyle(
                            fontSize: 12, color: kColorTextLight),
                      ),
                    ],
                  ),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? kColorPrimary : kColorText,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
