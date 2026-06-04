import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/domain/entities/leaderboard_entry.dart';
import 'package:quiz_app/domain/entities/leaderboard_period.dart';
import 'package:quiz_app/presentation/provider/leaderboard_provider.dart';
import 'package:quiz_app/services/auth_mode_manager.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().syncCurrentUser();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final period = LeaderboardPeriod.values[_tabController.index];
      context.read<LeaderboardProvider>().selectTab(period);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return Scaffold(
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
              controller: _tabController,
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
              child: _buildTabContent(provider),
            ),
          ),
          if (provider.currentUserRank > 0) _buildYourRank(provider),
        ],
      ),
    );
  }

  Widget _buildTabContent(LeaderboardProvider provider) {
    final period = provider.selectedTab;
    final entries = provider.currentEntries;
    final loading = provider.isLoading(period);

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
        final isMe = entry.uid == context.read<AuthModeManager>().user?.id;
        return _buildRow(entry, isMe);
      },
    );
  }

  Widget _buildRow(LeaderboardEntry entry, bool isMe) {
    final medal = entry.rank == 1
        ? const Color(0xFFE8B86D)
        : entry.rank == 2
            ? const Color(0xFFC0C0C0)
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : null;

    final period = context.read<LeaderboardProvider>().selectedTab;
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

  Widget _buildYourRank(LeaderboardProvider provider) {
    final rank = provider.currentUserRank;
    final entry = provider.currentUserEntry;
    final xp = entry?.xpForPeriod(provider.selectedTab) ?? 0;

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
