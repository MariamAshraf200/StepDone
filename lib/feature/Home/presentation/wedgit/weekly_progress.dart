import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../bloc/home_event.dart';
import '../../../taskHome/presintation/bloc/taskBloc/bloc.dart';
import '../../../taskHome/presintation/bloc/taskBloc/state.dart' as taskState;
import 'package:mapperapp/l10n/l10n_extension.dart';

class WeeklyProgressWidget extends StatelessWidget {
  const WeeklyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Listen to TaskBloc updates and notify HomeBloc to recompute weekly progress when tasks change
    return BlocListener<TaskBloc, taskState.TaskState>(
      listener: (context, tState) {
        if (tState is taskState.TaskLoaded) {
          // Forward updated tasks to HomeBloc so it can recompute daily/weekly progress
          context.read<HomeBloc>().add(HomeTasksUpdated(tState.tasks));
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is! HomeLoaded) return const SizedBox.shrink();
          final days = state.days;
          final dailyProgress = state.dailyProgress;
          final avgProgress = state.avgProgress;
          final bestDayName = state.bestDayName;
          final todayIndex = state.todayIndex;

          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.surface, colorScheme.primary.withAlpha(15)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weeklyProgressTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                AspectRatio(
                  aspectRatio: 1.7,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 1,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withAlpha(25),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withAlpha(20),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) => Text(
                              "${(value * 100).toInt()}%",
                              style:
                              TextStyle(fontSize: 10, color: colorScheme.onSurface.withAlpha(153)),
                            ),
                            interval: 0.25,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= days.length) {
                                return const SizedBox.shrink();
                              }
                              final day = days[index];
                              final locale = Localizations.localeOf(context).toString();
                              final label = DateFormat('E', locale).format(day);
                              final isToday = index == todayIndex;
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isToday
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withAlpha(217),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(days.length, (i) {
                            final progress = dailyProgress[days[i]] ?? 0.0;
                            return FlSpot(i.toDouble(), progress);
                          }),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [colorScheme.secondary, colorScheme.primary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withAlpha(60),
                                colorScheme.secondary.withAlpha(20),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 4,
                              // Map progress ranges to the app color scheme
                              color: spot.y >= 0.7
                                  ? colorScheme.secondary
                                  : spot.y >= 0.4
                                  ? colorScheme.primary
                                  : colorScheme.error,
                              strokeWidth: 1.5,
                              strokeColor: colorScheme.surface,
                            ),
                          ),
                        ),
                      ],
                      extraLinesData: ExtraLinesData(verticalLines: [
                        if (todayIndex >= 0)
                          VerticalLine(
                            x: todayIndex.toDouble(),
                            color: colorScheme.primary.withAlpha(128),
                            strokeWidth: 1.5,
                            dashArray: [4, 4],
                          ),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  avgProgress > 0.7
                      ? l10n.weeklyBestDayMessage(bestDayName)
                      : avgProgress > 0.4
                      ? l10n.weeklyGoodEffortMessage
                      : l10n.weeklyBackOnTrackMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withAlpha(230),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
