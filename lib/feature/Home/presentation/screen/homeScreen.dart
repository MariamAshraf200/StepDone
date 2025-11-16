import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/util/date_and_time/date_format_util.dart';
import '../../../PlanHome/presentation/screen/PlanTrack.dart';
import '../../../taskHome/presintation/bloc/taskBloc/bloc.dart';
import '../../../taskHome/presintation/bloc/taskBloc/event.dart';
import '../../../taskHome/presintation/bloc/taskBloc/state.dart';
import '../../../taskHome/presintation/screen/taskTrack.dart';
import '../wedgit/home_header.dart';
import '../wedgit/task_status_card.dart';
import '../wedgit/weekly_progress.dart';
import 'home_screen_form.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late String _viewDate;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _viewDate = DateFormatUtil.getCurrentDateFormatted();
    context.read<TaskBloc>().add(GetAllTasksEvent());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          PlanTrackerScreen(),
          HomeBodyWidget(viewDate: _viewDate),
          TaskTrack(),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeBodyWidget extends StatelessWidget {
  final String viewDate;
  const HomeBodyWidget({super.key, required this.viewDate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded) {
          final tasks = state.tasks;
          final today = viewDate;
          final tasksForToday = tasks.where((task) => task.date == today).toList();

          final doneTasksCount = tasksForToday
              .where((task) => task.status.trim().toLowerCase() == 'done')
              .length;
          final totalTasksCount = tasksForToday.length;
          final taskCompletionPercentage = totalTasksCount > 0
              ? doneTasksCount / totalTasksCount
              : 0.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                const HomeHeader(),
                TaskStatsCard(
                  doneTasks: doneTasksCount,
                  totalTasks: totalTasksCount,
                  completionPercentage: taskCompletionPercentage,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  // removed const so this widget rebuilds when bloc state changes
                  child: WeeklyProgressWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: HomeScreenForm(tasks: tasksForToday),
                ),
              ],
            ),
          );
        } else if (state is TaskError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const HomeBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.calendar_month), label: context.l10n.bottomNavPlan),
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: context.l10n.bottomNavHome),
        BottomNavigationBarItem(icon: const Icon(Icons.task), label: context.l10n.tasks),
      ],
    );
  }
}
