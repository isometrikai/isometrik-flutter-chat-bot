import 'package:chat_bot/bloc/flight_search/flight_search_bloc.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_event.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/search_result_states.dart';
import 'widgets/search_screen_scaffold.dart';

const _defaultFlightSearchTitle = 'Choose from available flights';
const _noFlightsMessage = 'No Flights Found';

class FlightSearchScreen extends StatefulWidget {
  final WidgetAction actionData;
  final Map<String, dynamic>? flightBooking;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onFlightSelected;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onOpenInEazyApp;

  const FlightSearchScreen({
    super.key,
    required this.actionData,
    this.flightBooking,
    this.onFlightSelected,
    this.onOpenInEazyApp,
  });

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FlightSearchBloc>().add(
          FlightSearchFetchRequested(
            action: widget.actionData,
            flightBooking: widget.flightBooking,
            needToShowLoader: true,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;

    context.read<FlightSearchBloc>().add(
          FlightSearchLoadMoreRequested(
            action: widget.actionData,
            flightBooking: widget.flightBooking,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SearchScreenScaffold(
      title: searchScreenTitle(widget.actionData, _defaultFlightSearchTitle),
      subtitle: searchScreenSubtitle(widget.actionData),
      body: _FlightSearchList(
        scrollController: _scrollController,
        onFlightSelected: widget.onFlightSelected,
        onOpenInEazyApp: widget.onOpenInEazyApp,
      ),
    );
  }
}

class _FlightSearchList extends StatelessWidget {
  final ScrollController scrollController;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onFlightSelected;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onOpenInEazyApp;

  const _FlightSearchList({
    required this.scrollController,
    this.onFlightSelected,
    this.onOpenInEazyApp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlightSearchBloc, FlightSearchState>(
      builder: (context, state) {
        return switch (state) {
          FlightSearchInitial() || FlightSearchLoadInProgress() =>
            const SearchResultLoading(),
          FlightSearchLoadFailure() =>
            const SearchResultEmpty(message: _noFlightsMessage),
          FlightSearchLoadSuccess(:final flights) when flights.isEmpty =>
            const SearchResultEmpty(message: _noFlightsMessage),
          FlightSearchLoadSuccess(
            :final flights,
            :final isLoadingMore,
          ) =>
            ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                FlightsSearchWidget(
                  flights: flights,
                  onFlightSelected: onFlightSelected,
                  onOpenInApp: onOpenInEazyApp,
                ),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: SearchResultLoading(),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          _ => const SearchResultEmpty(message: _noFlightsMessage),
        };
      },
    );
  }
}
