import 'package:chat_bot/bloc/flight_search/flight_search_bloc.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_event.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  static const Color _accentPurple = Color(0xFF8E2FFD);
  static const String _noFlightsMessage = 'No Flights Found';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ScreenHeader(
                title: widget.actionData.title.isNotEmpty
                    ? widget.actionData.title
                    : 'Choose from available flights',
                subtitle: widget.actionData.subtitle.isNotEmpty
                    ? widget.actionData.subtitle
                    : null,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildFlightList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightList() {
    return BlocBuilder<FlightSearchBloc, FlightSearchState>(
      builder: (context, state) {
        if (state is FlightSearchInitial || state is FlightSearchLoadInProgress) {
          return const Center(
            child: CircularProgressIndicator(
              color: _accentPurple,
            ),
          );
        }

        if (state is FlightSearchLoadFailure ||
            (state is FlightSearchLoadSuccess && state.flights.isEmpty)) {
          return _buildNoFlightsFound();
        }

        if (state is FlightSearchLoadSuccess) {
          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              FlightsSearchWidget(
                flights: state.flights,
                onFlightSelected: widget.onFlightSelected,
                onOpenInApp: widget.onOpenInEazyApp,
              ),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _accentPurple,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          );
        }

        return _buildNoFlightsFound();
      },
    );
  }

  Widget _buildNoFlightsFound() {
    return Center(
      child: Text(
        _noFlightsMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyText.copyWith(
          color: const Color(0xFF979797),
        ),
      ),
    );
  }
}
