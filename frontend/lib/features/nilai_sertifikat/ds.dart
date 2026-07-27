import 'package:flutter/material.dart';

// Colors
const kBlue = Color(0xFF2563EB);
const kBlueDark = Color(0xFF1D4ED8);
const kBlueLight = Color(0xFFEFF6FF);
const kBlueMid = Color(0xFFDBEAFE);
const kGreen = Color(0xFF22C55E);
const kGreenLight = Color(0xFFDCFCE7);
const kOrange = Color(0xFFD97706);
const kOrangeLight = Color(0xFFFEF3C7);
const kRed = Color(0xFFDC2626);
const kInk = Color(0xFF0F172A);
const kInkMid = Color(0xFF334155);
const kGray = Color(0xFF64748B);
const kGrayLight = Color(0xFF94A3B8);
const kBorder = Color(0xFFE5E7EB);
const kBg = Color(0xFFF8FAFC);
const kWhite = Colors.white;

// Radius
const kRadiusCard = 20.0;
const kRadiusBtn = 16.0;
const kRadiusChip = 12.0;

// Spacing
const kPadH = 20.0;
const kSpaceSection = 20.0;

// Text styles
const kStyleTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kInk);
const kStyleSubtitle = TextStyle(fontSize: 13, color: kGray, height: 1.4);
const kStyleLabel = TextStyle(fontSize: 11, color: kGray, fontWeight: FontWeight.w500);
const kStyleBody = TextStyle(fontSize: 14, color: kInkMid, height: 1.5);
const kStyleCaption = TextStyle(fontSize: 12, color: kGray);

final BoxDecoration kCardDecoration = BoxDecoration(
  color: kWhite,
  borderRadius: BorderRadius.circular(kRadiusCard),
  border: Border.all(color: kBorder),
  boxShadow: const [
    BoxShadow(color: Color(0x080F172A), blurRadius: 14, offset: Offset(0, 6)),
  ],
);
