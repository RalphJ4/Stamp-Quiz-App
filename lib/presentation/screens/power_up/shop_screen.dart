import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/entities/power_up.dart';
import 'package:quiz_app/presentation/screens/power_up/bloc/power_up_bloc.dart';
import 'package:quiz_app/presentation/screens/quiz/bloc/quiz_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:quiz_app/presentation/theme/app_colors.dart';

final _log = Logger();

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final powerUpState = context.watch<PowerUpBloc>().state;
    final quizState = context.watch<QuizBloc>().state;
    final balance = quizState.stamps;
    final inventory = powerUpState.inventory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_bag, color: AppColors.secondary, size: 22.sp),
            SizedBox(width: 2.w),
            Text('Power-Up Shop',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        toolbarHeight: 7.h,
        backgroundColor: AppColors.surface,
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on,
                      color: AppColors.secondary, size: 6.w),
                  SizedBox(width: 2.w),
                  Text('Balance: ',
                      style: TextStyle(
                          fontSize: 16.sp, color: Colors.white70)),
                  Text(
                    '$balance',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Boost your quiz with power-ups!',
              style: TextStyle(fontSize: 16.sp, color: Colors.white54),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 3.w,
                childAspectRatio: 0.78,
                children: PowerUpType.values.map((type) {
                  final owned = inventory[type] ?? 0;
                  final canAfford = balance >= type.cost;

                  return _PowerUpCard(
                    type: type,
                    owned: owned,
                    canAfford: canAfford,
                    onPurchase: () {
                      _log.i('Purchasing ${type.label}');
                      context.read<PowerUpBloc>().add(PowerUpPurchase(type: type));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${type.label} purchased!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerUpCard extends StatelessWidget {
  final PowerUpType type;
  final int owned;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _PowerUpCard({
    required this.type,
    required this.owned,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final locked = !canAfford;

    return Container(
      decoration: BoxDecoration(
        color: locked
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked ? Colors.white12 : color.withValues(alpha: 0.5),
          width: locked ? 1 : 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locked)
              Opacity(
                opacity: 0.4,
                child: Icon(type.icon, color: color, size: 10.w),
              )
            else
              Icon(type.icon, color: color, size: 10.w),
            SizedBox(height: 0.8.h),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: locked ? Colors.white38 : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.3.h),
            Text(
              type.description,
              style: TextStyle(
                fontSize: 11.sp,
                color: locked ? Colors.white24 : Colors.white54,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            if (owned > 0)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Owned: $owned',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      locked ? Colors.white12 : AppColors.primary,
                  foregroundColor: locked ? Colors.white38 : Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 0.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white24,
                ),
                onPressed: locked ? null : onPurchase,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on,
                        size: 4.5.w, color: locked ? Colors.white24 : AppColors.secondary),
                    SizedBox(width: 1.w),
                    Text(
                      cost,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get cost => type.cost.toString();
}
