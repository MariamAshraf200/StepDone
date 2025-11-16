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
    return Scaffold(
      body: CustomCard(
        margin: const EdgeInsets.symmetric(vertical: 0.0),
        padding: const EdgeInsets.all(12),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // 🔹 Header
            _PlanHeader(
              onBack: () => Navigator.of(context).pop(),
              onAdd: () {
                navigateToScreenWithSlideTransition(
                  context,
                  const AddPlanScreen(),
                );
              },
            ),
            const SizedBox(height: 12),

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
    );
  }
}

// ---------------- Header ----------------
class _PlanHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAdd;

  const _PlanHeader({required this.onBack, required this.onAdd});

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22,),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton(icon: Icons.arrow_back_ios_new, onPressed: onBack),
          Text(
            l10n.myPlans,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _circleIconButton(icon: Icons.add, onPressed: onAdd),
        ],
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
