import 'package:chat_bot/bloc/car_search/car_search_bloc.dart';
import 'package:chat_bot/bloc/car_search/car_search_event.dart';
import 'package:chat_bot/bloc/car_search/car_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/search_result_states.dart';
import 'widgets/search_screen_scaffold.dart';

const _defaultCarSearchTitle = 'Choose from available cars';
const _noCarsMessage = 'No Cars Found';

class CarSearchScreen extends StatefulWidget {
  final WidgetAction actionData;
  final void Function(CarRentalSearch rental)? onCarRentalSelected;
  final void Function(CarRentalSearch rental)? onOpenInEazyApp;

  const CarSearchScreen({
    super.key,
    required this.actionData,
    this.onCarRentalSelected,
    this.onOpenInEazyApp,
  });

  @override
  State<CarSearchScreen> createState() => _CarSearchScreenState();
}

class _CarSearchScreenState extends State<CarSearchScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CarSearchBloc>().add(
          CarSearchFetchRequested(
            action: widget.actionData,
            needToShowLoader: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SearchScreenScaffold(
      title: searchScreenTitle(widget.actionData, _defaultCarSearchTitle),
      subtitle: searchScreenSubtitle(widget.actionData),
      body: _CarSearchList(
        onCarRentalSelected: widget.onCarRentalSelected,
        onOpenInEazyApp: widget.onOpenInEazyApp,
      ),
    );
  }
}

class _CarSearchList extends StatelessWidget {
  final void Function(CarRentalSearch rental)? onCarRentalSelected;
  final void Function(CarRentalSearch rental)? onOpenInEazyApp;

  const _CarSearchList({
    this.onCarRentalSelected,
    this.onOpenInEazyApp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarSearchBloc, CarSearchState>(
      builder: (context, state) {
        return switch (state) {
          CarSearchInitial() || CarSearchLoadInProgress() =>
            const SearchResultLoading(),
          CarSearchLoadFailure() =>
            const SearchResultEmpty(message: _noCarsMessage),
          CarSearchLoadSuccess(:final filteredRentals)
              when filteredRentals.isEmpty =>
            const SearchResultEmpty(message: _noCarsMessage),
          CarSearchLoadSuccess(:final filteredRentals) => ListView(
              padding: EdgeInsets.zero,
              children: [
                CarRentalsSearchWidget(
                  rentals: filteredRentals,
                  onCarRentalSelected: onCarRentalSelected,
                  onOpenInApp: onOpenInEazyApp,
                ),
                const SizedBox(height: 24),
              ],
            ),
          _ => const SearchResultEmpty(message: _noCarsMessage),
        };
      },
    );
  }
}
