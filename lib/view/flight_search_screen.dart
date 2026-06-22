import 'package:chat_bot/bloc/flight_search/flight_search_bloc.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_event.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/search_paginated_scroll.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<FlightSearchBloc>().add(
          FlightSearchFetchRequested(
            action: widget.actionData,
            flightBooking: widget.flightBooking,
            needToShowLoader: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SearchScreenScaffold(
      title: searchScreenTitle(widget.actionData, _defaultFlightSearchTitle),
      subtitle: searchScreenSubtitle(widget.actionData),
      body: _FlightSearchList(
        actionData: widget.actionData,
        flightBooking: widget.flightBooking,
        onFlightSelected: widget.onFlightSelected,
        onOpenInEazyApp: widget.onOpenInEazyApp,
      ),
    );
  }
}

class _FlightSearchList extends StatefulWidget {
  final WidgetAction actionData;
  final Map<String, dynamic>? flightBooking;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onFlightSelected;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onOpenInEazyApp;

  const _FlightSearchList({
    required this.actionData,
    this.flightBooking,
    this.onFlightSelected,
    this.onOpenInEazyApp,
  });

  @override
  State<_FlightSearchList> createState() => _FlightSearchListState();
}

class _FlightSearchListState extends State<_FlightSearchList> {
  late final SearchPaginatedScrollController _pagination =
      SearchPaginatedScrollController(onNearBottom: _loadMore);

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  void _loadMore() {
    context.read<FlightSearchBloc>().add(
          FlightSearchLoadMoreRequested(
            action: widget.actionData,
            flightBooking: widget.flightBooking,
          ),
        );
  }

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
              controller: _pagination.controller,
              padding: EdgeInsets.zero,
              children: [
                FlightsSearchWidget(
                  flights: flights,
                  onFlightSelected: widget.onFlightSelected,
                  onOpenInApp: widget.onOpenInEazyApp,
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
