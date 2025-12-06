import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable horizontal date picker that shows a range of days and
/// allows selecting one. This widget exposes a DateTime-based API and
/// extracts private builders for clarity.
class DataFormat extends StatefulWidget {
  /// The selected date (compares only year/month/day).
  final DateTime selectedDate;

  /// Called when the user taps a date tile.
  final ValueChanged<DateTime> onDateSelected;

  /// Number of days to show before today (inclusive). Defaults to 7.
  final int daysBefore;

  /// Number of days to show after today. Defaults to 22 to keep existing ~30 items.
  final int daysAfter;

  /// Compact item width (defaults to smaller size)
  final double itemWidth;

  /// Spacing between items
  final double itemSpacing;

  const DataFormat({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysBefore = 7,
    this.daysAfter = 22,
    this.itemWidth = 72.0,
    this.itemSpacing = 8.0,
  });

  @override
  State<DataFormat> createState() => _DataFormatState();
}

class _DataFormatState extends State<DataFormat> {
  late final DateTime _today;
  late final List<DateTime> _days;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _buildDays();
    _scrollController = ScrollController();

    // Center the selected date after first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelectedDate());
  }

  void _buildDays() {
    final start = DateTime(_today.year, _today.month, _today.day)
        .subtract(Duration(days: widget.daysBefore));
    final total = widget.daysBefore + widget.daysAfter + 1;
    _days = List.generate(total, (i) => start.add(Duration(days: i)));
  }

  @override
  void didUpdateWidget(covariant DataFormat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysBefore != widget.daysBefore || oldWidget.daysAfter != widget.daysAfter) {
      _buildDays();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelectedDate());
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _centerSelectedDate() {
    if (!_scrollController.hasClients) return;
    final selectedIndex = _days.indexWhere((d) => _isSameDate(d, widget.selectedDate));
    if (selectedIndex == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final sidePadding = (screenWidth - widget.itemWidth) / 2;
    final itemExtent = widget.itemWidth + widget.itemSpacing;
    final rawTarget = selectedIndex * itemExtent - sidePadding;
    final scrollOffset = rawTarget.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(scrollOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final sidePadding = (screenWidth - widget.itemWidth) / 2;
    final itemExtent = widget.itemWidth + widget.itemSpacing;
    final rawTarget = index * itemExtent - sidePadding;
    final target = rawTarget.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.ease);
  }

  Widget _buildDayItem(int index, ThemeData theme) {
    final date = _days[index];
    final locale = Localizations.localeOf(context).toString();
    final isSelected = _isSameDate(date, widget.selectedDate);

    return SizedBox(
      width: widget.itemWidth,
      child: GestureDetector(
        onTap: () {
          widget.onDateSelected(date);
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToIndex(index));
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: index == 0 ? 0 : 6),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE', locale).format(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMM', locale).format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(ThemeData theme) {
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: _days.length,
      separatorBuilder: (_, __) => SizedBox(width: widget.itemSpacing),
      itemBuilder: (context, index) => _buildDayItem(index, theme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 78,
        child: _buildListView(theme),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
