import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // ── Backgrounds ──
  static const background = Color(0xFF0D0D1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceDark = Color(0xFF16213E);
  static const surfaceDeepPurple = Color(0xFF3D0D6B);

  // ── Primary palette ──
  static const primary = Color(0xFF7B2FBE);
  static const secondary = Color(0xFFE8B86D);

  // ── Category colors ──
  static const categorySpace = Color(0xFF6C63FF);
  static const categoryAnimals = Color(0xFFFF6B6B);
  static const categoryHistory = Color(0xFFFFA726);
  static const categoryScience = Color(0xFF66BB6A);
  static const categoryGeography = Color(0xFF42A5F5);

  // ── Avatar colors ──
  static const avatarHero = Color(0xFF7B2FBE);
  static const avatarWizard = Color(0xFF42A5F5);
  static const avatarArcher = Color(0xFF43A047);
  static const avatarKnight = Color(0xFFE8B86D);
  static const avatarDragon = Color(0xFFE53935);
  static const avatarFox = Color(0xFFFF9800);
  static const avatarEagle = Color(0xFF795548);
  static const avatarWolf = Color(0xFF9E9E9E);

  // ── Difficulty ──
  static const difficultyEasy = Color(0xFF43A047);
  static const difficultyMedium = Color(0xFFFF9800);
  static const difficultyHard = Color(0xFFE53935);

  // ── Leaderboard medals ──
  static const medalGold = Color(0xFFE8B86D);
  static const medalSilver = Color(0xFFC0C0C0);
  static const medalBronze = Color(0xFFCD7F32);

  // ── Badge colors ──
  static const badgeGold = Color(0xFFFFD700);

  // ── Stats ──
  static const statCorrect = Color(0xFF43A047);
  static const statAnswered = Color(0xFF42A5F5);
  static const statAccuracy = Color(0xFFFF6B6B);

  // ── Misc ──
  static const errorSnackbar = Color(0xFF800000);
  static const successSnackbar = Color(0xFF7B2FBE);
}
