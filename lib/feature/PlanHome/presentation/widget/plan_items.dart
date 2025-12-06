import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/bloc.dart';
import '../bloc/state.dart';
import 'plan_items_card.dart';


class PlanItems extends StatefulWidget {
  const PlanItems({super.key});

  @override
  State<PlanItems> createState() => _PlanItemsState();
}

class _PlanItemsState extends State<PlanItems> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlanBloc, PlanState>(
      builder: (context, state) {
        if (state is PlanLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlanLoaded) {
          final plans = state.plans;
          return plans.isEmpty
              ? Center(child: Text(l10n.noPlansAvailable))
              : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            controller: _scrollController,
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PlanItemCard(plan: plan),
              );
            },
          );
        } else if (state is PlanError) {
          return Center(child: Text(state.message));
        }
        return Center(child: Text(l10n.unexpectedState));
      },
    );
  }
}
