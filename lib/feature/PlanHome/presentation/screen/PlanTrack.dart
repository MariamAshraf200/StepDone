import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection_imports.dart';
import '../../../../core/util/custom_builders/navigate_to_screen.dart';
import 'addPlan.dart';
import '../widget/plan_filters_widget.dart';

class PlanTrackerScreen extends StatefulWidget {
  const PlanTrackerScreen({super.key});

  @override
  State<PlanTrackerScreen> createState() => _PlanTrackerScreenState();
}

class _PlanTrackerScreenState extends State<PlanTrackerScreen> {
  String? selectedCategory;
  PlanStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategoriesEvent());
    context.read<PlanBloc>().add(GetAllPlansEvent());
  }

  void _onCategoryChanged(String? category) {
    setState(() => selectedCategory = category);
    if (category == null) {
      context.read<PlanBloc>().add(GetAllPlansEvent());
    } else {
      context.read<PlanBloc>().add(GetPlansByCategoryEvent(category));
    }
  }

  void _onStatusChanged(PlanStatus? status) {
    setState(() => selectedStatus = status);
    if (status == null || status == PlanStatus.all) {
      context.read<PlanBloc>().add(GetAllPlansEvent());
    } else {
      context.read<PlanBloc>().add(GetPlansByStatusEvent(status));
    }
  }

  // ✅ بدون then
  void _openDetails(PlanDetails plan) {
    navigateToScreenWithSlideTransition(
      context,
      PlanDetailsScreen( id: plan.id,),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomCard(
        margin: const EdgeInsets.symmetric(vertical: 0.0),
        padding: const EdgeInsets.all(12),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // header removed
            const SizedBox(height: 8),

            // 🔹 Filters
            PlanFiltersWidget(
              selectedCategory: selectedCategory,
              selectedStatus: selectedStatus,
              onCategoryChanged: _onCategoryChanged,
              onStatusChanged: _onStatusChanged,
            ),

            const SizedBox(height: 16),

            // 🔹 Plan list
            _PlanListSection(key: const Key('plan_list_section'), onItemTap: _openDetails),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'plan_tracker_add_fab',
        onPressed: () {
          navigateToScreenWithSlideTransition(
            context,
            const AddPlanScreen(),
          );
        },
        tooltip: l10n.addPlan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------- Plan List ----------------
class _PlanListSection extends StatelessWidget {
  final ValueChanged<PlanDetails> onItemTap;

  const _PlanListSection({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, state) {
          if (state is PlanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlanLoaded || state is PlanAndTasksLoaded) {
            final plans = state is PlanLoaded ? state.plans : (state as PlanAndTasksLoaded).plans;
            if (plans.isEmpty) {
              return Center(
                child: Text(
                  l10n.noPlansMatchFilters,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return PlanItemCard(
                  plan: plans[index],
                  onTap: () => onItemTap(plans[index]),
                );
              },
            );
          } else if (state is PlanError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red)),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
