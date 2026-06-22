import 'package:chat_bot/bloc/hotel_search/hotel_search_bloc.dart';
import 'package:chat_bot/bloc/hotel_search/hotel_search_event.dart';
import 'package:chat_bot/bloc/hotel_search/hotel_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/search_result_states.dart';
import 'widgets/search_screen_scaffold.dart';

const _defaultHotelSearchTitle = 'Choose from top hotels and stays';
const _noHotelsMessage = 'No Hotels Found';
const _chipBorderIdle = Color(0xFFD8DEF3);

class HotelSearchScreen extends StatefulWidget {
  final WidgetAction actionData;
  final void Function(HotelProperty property)? onHotelSelected;
  final void Function(HotelProperty property)? onOpenInEazyApp;

  const HotelSearchScreen({
    super.key,
    required this.actionData,
    this.onHotelSelected,
    this.onOpenInEazyApp,
  });

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HotelSearchBloc>().add(
          HotelSearchFetchRequested(
            action: widget.actionData,
            needToShowLoader: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SearchScreenScaffold(
      title: searchScreenTitle(widget.actionData, _defaultHotelSearchTitle),
      subtitle: searchScreenSubtitle(widget.actionData),
      body: Column(
        children: [
          _HotelSearchBar(actionData: widget.actionData),
          const SizedBox(height: 16),
          Expanded(
            child: _HotelSearchList(
              nights: HotelsWidget.nightsFromDates(
                widget.actionData.checkinDate,
                widget.actionData.checkoutDate,
              ),
              onHotelSelected: widget.onHotelSelected,
              onOpenInEazyApp: widget.onOpenInEazyApp,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelSearchBar extends StatefulWidget {
  final WidgetAction actionData;

  const _HotelSearchBar({required this.actionData});

  @override
  State<_HotelSearchBar> createState() => _HotelSearchBarState();
}

class _HotelSearchBarState extends State<_HotelSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastQueryAt;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    final now = DateTime.now();
    _lastQueryAt = now;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_lastQueryAt != now) return;

      final bloc = context.read<HotelSearchBloc>();
      bloc.add(
        HotelSearchFetchRequested(
          action: widget.actionData,
          searchQuery: query,
          selectedFilter: _selectedFilter(bloc.state),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _chipBorderIdle),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: SearchResultTheme.emptyTextColor,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 17),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(54),
            ),
            child: const Icon(
              Icons.search,
              size: 17,
              color: Color(0xFF585C77),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelSearchList extends StatelessWidget {
  final int? nights;
  final void Function(HotelProperty property)? onHotelSelected;
  final void Function(HotelProperty property)? onOpenInEazyApp;

  const _HotelSearchList({
    this.nights,
    this.onHotelSelected,
    this.onOpenInEazyApp,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelSearchBloc, HotelSearchState>(
      builder: (context, state) {
        return switch (state) {
          HotelSearchInitial() || HotelSearchLoadInProgress() =>
            const SearchResultLoading(),
          HotelSearchLoadFailure() =>
            const SearchResultEmpty(message: _noHotelsMessage),
          HotelSearchLoadSuccess(:final filteredHotels)
              when filteredHotels.isEmpty =>
            const SearchResultEmpty(message: _noHotelsMessage),
          HotelSearchLoadSuccess(:final filteredHotels) => ListView(
              padding: EdgeInsets.zero,
              children: [
                HotelsWidget(
                  properties: filteredHotels,
                  nights: nights,
                  onHotelSelected: onHotelSelected,
                  onOpenInApp: onOpenInEazyApp,
                ),
                const SizedBox(height: 24),
              ],
            ),
          _ => const SearchResultEmpty(message: _noHotelsMessage),
        };
      },
    );
  }
}

String _selectedFilter(HotelSearchState state) => switch (state) {
      HotelSearchLoadSuccess(:final selectedFilter) => selectedFilter,
      HotelSearchLoadInProgress(:final selectedFilter) => selectedFilter,
      _ => 'All',
    };
