import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/entities/leaderboard_entry.dart';
import 'package:quiz_app/domain/entities/leaderboard_period.dart';
import 'package:quiz_app/presentation/screens/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:quiz_app/presentation/screens/auth/bloc/auth_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LeaderboardBloc>().state;

    return DefaultTabController(
        length: 3,
        initialIndex: LeaderboardPeriod.values.indexOf(state.selectedTab),
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          appBar: AppBar(
            title: const Text('Leaderboard',
                style: TextStyle(color: Color(0xFFE8B86D))),
            centerTitle: true,
            backgroundColor: const Color(0xFF1A1A2E),
            toolbarHeight: 7.h,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(8.h),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  onTap: (index) {
                    final period = LeaderboardPeriod.values[index];
                    context.read<LeaderboardBloc>().add(LeaderboardSelectTab(period: period));
                  },
                  indicator: BoxDecoration(
                    color: const Color(0xFF7B2FBE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: LeaderboardPeriod.values.map((p) => Tab(text: p.label)).toList(),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildTabContent(context, state),
                ),
              ),
              if (state.currentUserRank > 0) _buildYourRank(context, state),
            ],
          ),
        ),
    );
  }

  Widget _buildTabContent(BuildContext context, LeaderboardState state) {
    final period = state.selectedTab;
    final entries = state.currentEntries;
    final loading = state.isLoading(period);

    if (loading && entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE8B86D)),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined,
                color: Colors.white24, size: 12.h),
            SizedBox(height: 2.h),
            Text(
              'No entries yet',
              style: TextStyle(fontSize: 17.sp, color: Colors.white54),
            ),
            SizedBox(height: 1.h),
            Text(
              'Play quizzes to earn XP and appear here!',
              style: TextStyle(fontSize: 14.sp, color: Colors.white24),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: ValueKey(period),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = entry.uid == context.read<AuthBloc>().state.user?.id;
        return _buildRow(context, entry, isMe);
      },
    );
  }

  Widget _buildRow(BuildContext context, LeaderboardEntry entry, bool isMe) {
    final medal = entry.rank == 1
        ? const Color(0xFFE8B86D)
        : entry.rank == 2
            ? const Color(0xFFC0C0C0)
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : null;

    final period = context.read<LeaderboardBloc>().state.selectedTab;
    final xp = entry.xpForPeriod(period);

    return Container(
      margin: EdgeInsets.only(bottom: 0.8.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isMe
            ? const Color(0xFF7B2FBE).withValues(alpha: 0.2)
            : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: const Color(0xFF7B2FBE), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 8.w,
            child: medal != null
                ? Icon(Icons.emoji_events, color: medal, size: 6.w)
                : Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
          CircleAvatar(
            radius: 3.w,
            backgroundColor: isMe
                ? const Color(0xFFE8B86D)
                : const Color(0xFF7B2FBE),
            child: Text(
              entry.displayName.isNotEmpty
                  ? entry.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: const Color(0xFF0D0D1A),
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              isMe ? '${entry.displayName} (You)' : entry.displayName,
              style: TextStyle(
                fontSize: 15.sp,
                color: isMe ? const Color(0xFFE8B86D) : Colors.white,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B86D).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$xp XP',
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFFE8B86D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourRank(BuildContext context, LeaderboardState state) {
    final rank = state.currentUserRank;
    final entry = state.currentUserEntry;
    final xp = entry?.xpForPeriod(state.selectedTab) ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: const Border(
          top: BorderSide(color: Color(0xFF7B2FBE), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF7B2FBE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Your Rank',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white70,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B86D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$xp XP',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFFE8B86D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
