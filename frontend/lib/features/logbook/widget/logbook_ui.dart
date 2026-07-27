import 'package:flutter/material.dart';
import '../model/logbook_model.dart';

const logbookPrimary = Color(0xFF2563EB);
const logbookPrimarySoft = Color(0xFFEFF6FF);
const logbookSuccess = Color(0xFF16A34A);
const logbookSuccessSoft = Color(0xFFECFDF5);
const logbookWarning = Color(0xFFF97316);
const logbookWarningSoft = Color(0xFFFFF7ED);
const logbookDanger = Color(0xFFEF4444);
const logbookDangerSoft = Color(0xFFFEF2F2);
const logbookBackground = Color(0xFFF8FAFC);
const logbookInk = Color(0xFF0F172A);
const logbookBody = Color(0xFF334155);
const logbookMuted = Color(0xFF64748B);
const logbookBorder = Color(0xFFE2E8F0);

BoxDecoration logbookCardDecoration({double radius = 20}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: logbookBorder),
      boxShadow: const [
        BoxShadow(color: Color(0x080F172A), blurRadius: 14, offset: Offset(0, 6)),
      ],
    );

String logbookStatusLabel(LogbookStatus status) => switch (status) {
      LogbookStatus.draft => 'Draft',
      LogbookStatus.pending => 'Menunggu',
      LogbookStatus.revision => 'Revisi',
      LogbookStatus.approved => 'Disetujui',
    };

Color logbookStatusColor(LogbookStatus status) => switch (status) {
      LogbookStatus.draft => logbookMuted,
      LogbookStatus.pending => logbookWarning,
      LogbookStatus.revision => logbookDanger,
      LogbookStatus.approved => logbookSuccess,
    };

Color logbookStatusSoftColor(LogbookStatus status) => switch (status) {
      LogbookStatus.draft => const Color(0xFFF1F5F9),
      LogbookStatus.pending => logbookWarningSoft,
      LogbookStatus.revision => logbookDangerSoft,
      LogbookStatus.approved => logbookSuccessSoft,
    };

String shortMonth(DateTime value) => const [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGS',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ][value.month - 1];

String fullDate(DateTime value) => '${value.day} ${const [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ][value.month - 1]} ${value.year}';

String timeWib(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}.${value.minute.toString().padLeft(2, '0')} WIB';
