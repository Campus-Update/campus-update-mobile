import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/domain/content_source.dart';
import '../../../../shared/widgets/back_button_circle.dart';
import '../../data/notifications_providers.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chips.dart';
import '../widgets/alerts_empty_state.dart';
import '../widgets/alerts_search_bar.dart';

/// Active Alerts — the full-screen alerts list the user reaches from the
/// notification bell.
///
/// Implements all three visual states matching the design:
///   1. **Empty** — sleeping bell icon + "No notifications yet"
///   2. **Populated** — urgency filter chips + styled alert cards
///   3. **Search** — search bar with back arrow, results counter banner,
///                   filtered cards, and search hint footer.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Filter state.
  String _selectedCategory = 'All';
  Urgency? get _urgencyFilter => switch (_selectedCategory) {
    'Normal' => Urgency.normal,
    'Important' => Urgency.important,
    'Urgent' => Urgency.urgent,
    _ => null,
  };

  // Search state.
  bool _searchActive = false;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _searchQuery = '';

  static const _categories = ['All', 'Normal', 'Important', 'Urgent'];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// The bell opens this screen above the tab bar, so it needs its own way
  /// back. Opened cold — a notification deep link — there is nothing to pop,
  /// so fall back to home rather than leaving a dead button.
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  void _openSearch() {
    setState(() => _searchActive = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocus.requestFocus();
      }
    });
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _searchActive = false;
      _searchQuery = '';
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim());
  }

  AlertsFilter get _currentFilter => AlertsFilter(
    urgency: _urgencyFilter,
    search: _searchQuery.isNotEmpty ? _searchQuery : null,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertsAsync = ref.watch(alertsFeedProvider(_currentFilter));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // While searching, the search bar's own arrow cancels the search,
            // so only one back affordance is ever on screen.
            if (!_searchActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: BackButtonCircle(onPressed: _goBack),
                ),
              ),

            // Top Header: Active Alerts title + subtitle + search icon.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Alerts',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontFamily: AppFonts.family,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.graphite,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time emergency and advisory updates for your area.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: AppFonts.family,
                            fontSize: 13.5,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      size: 24,
                      color: AppColors.graphite,
                    ),
                    splashRadius: 22,
                    tooltip: 'Search alerts',
                    onPressed: _openSearch,
                  ),
                ],
              ),
            ),

            // Search Bar Row (shown when search is active).
            if (_searchActive)
              AlertsSearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                onCancel: _closeSearch,
              )
            else
              const SizedBox(height: 14),

            // Search results counter banner.
            if (_searchActive && _searchQuery.isNotEmpty)
              alertsAsync.when(
                data: (items) => Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'result' : 'results'} for "$_searchQuery"',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: AppFonts.family,
                        fontSize: 13,
                        fontWeight: AppFonts.medium,
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            // Priority / Urgency filter chips.
            AlertFilterChips(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 14),

            // Alert cards list / empty / loading / error states.
            Expanded(
              child: RefreshIndicator(
                color: AppColors.indigo,
                onRefresh: () =>
                    ref.refresh(alertsFeedProvider(_currentFilter).future),
                child: alertsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: AlertsEmptyState(
                              isSearch: _searchQuery.isNotEmpty,
                            ),
                          ),
                        ],
                      );
                    }

                    final showFooter = _searchActive;
                    final totalCount = items.length + (showFooter ? 1 : 0);

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: totalCount,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index < items.length) {
                          final item = items[index];
                          return AlertCard(
                            item: item,
                            onTap: () => context.push(
                              '${Routes.announcements}/${item.id}',
                            ),
                          );
                        }

                        // Search hint footer at the bottom of search results.
                        return Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Search by title, or keywords',
                                style: TextStyle(
                                  fontFamily: AppFonts.family,
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.indigo),
                  ),
                  error: (error, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Could not load alerts.\nPull down to retry.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: AppFonts.family,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
