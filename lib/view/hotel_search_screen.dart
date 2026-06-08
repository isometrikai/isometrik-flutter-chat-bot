import 'package:chat_bot/bloc/hotel_search/hotel_search_bloc.dart';
import 'package:chat_bot/bloc/hotel_search/hotel_search_event.dart';
import 'package:chat_bot/bloc/hotel_search/hotel_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastQueryAt;

  static const Color _accentPurple = Color(0xFF8E2FFD);
  static const Color _chipBorderIdle = Color(0xFFD8DEF3);
  static const String _noHotelsMessage = 'No Hotels Found';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int? get _nights => HotelsWidget.nightsFromDates(
        widget.actionData.checkinDate,
        widget.actionData.checkoutDate,
      );

  void _onSearchChanged(String value) {
    final query = value.trim();
    final now = DateTime.now();
    _lastQueryAt = now;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_lastQueryAt != now) return;

      final bloc = context.read<HotelSearchBloc>();
      final filter = bloc.state is HotelSearchLoadSuccess
          ? (bloc.state as HotelSearchLoadSuccess).selectedFilter
          : 'All';

      bloc.add(
        HotelSearchFetchRequested(
          action: widget.actionData,
          searchQuery: query,
          selectedFilter: filter,
        ),
      );
    });
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
                    : 'Choose from top hotels and stays',
                subtitle: widget.actionData.subtitle.isNotEmpty
                    ? widget.actionData.subtitle
                    : null,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              // const SizedBox(height: 16),
              // _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(child: _buildHotelList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
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
                  color: const Color(0xFF979797),
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

  Widget _buildFilterChips() {
    return BlocBuilder<HotelSearchBloc, HotelSearchState>(
      buildWhen: (previous, current) =>
          current is HotelSearchLoadSuccess ||
          current is HotelSearchLoadInProgress,
      builder: (context, state) {
        final selectedFilter = state is HotelSearchLoadSuccess
            ? state.selectedFilter
            : state is HotelSearchLoadInProgress
                ? state.selectedFilter
                : 'All';

        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: HotelSearchBloc.filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = HotelSearchBloc.filterOptions[index];
              final isSelected = selectedFilter == label;

              return GestureDetector(
                onTap: () {
                  context
                      .read<HotelSearchBloc>()
                      .add(HotelSearchFilterChanged(label));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? _accentPurple : _chipBorderIdle,
                    ),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? _accentPurple : const Color(0xFF242424),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHotelList() {
    return BlocBuilder<HotelSearchBloc, HotelSearchState>(
      builder: (context, state) {
        if (state is HotelSearchInitial ||
            state is HotelSearchLoadInProgress) {
          return const Center(
            child: CircularProgressIndicator(
              color: _accentPurple,
            ),
          );
        }

        if (state is HotelSearchLoadFailure ||
            (state is HotelSearchLoadSuccess &&
                state.filteredHotels.isEmpty)) {
          return _buildNoHotelsFound();
        }

        if (state is HotelSearchLoadSuccess) {

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              HotelsWidget(
                properties: state.filteredHotels,
                nights: _nights,
                onHotelSelected: widget.onHotelSelected,
                onOpenInApp: widget.onOpenInEazyApp,
              ),
              const SizedBox(height: 24),
            ],
          );
        }

        return _buildNoHotelsFound();
      },
    );
  }

  Widget _buildNoHotelsFound() {
    return Center(
      child: Text(
        _noHotelsMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyText.copyWith(
          color: const Color(0xFF979797),
        ),
      ),
    );
  }
}
