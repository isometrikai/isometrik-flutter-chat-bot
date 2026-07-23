import 'package:chat_bot/bloc/car_search/car_search_bloc.dart';
import 'package:chat_bot/bloc/car_search/car_search_event.dart';
import 'package:chat_bot/bloc/car_search/car_search_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastQueryAt;

  // static const Color _accentPurple = Color(0xFF8E2FFD);
  static const Color _chipBorderIdle = Color(0xFFD8DEF3);

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

      context.read<CarSearchBloc>().add(CarSearchQueryChanged(query));
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
                    : AppTranslations.chooseFromAvailableCars,
                subtitle: widget.actionData.subtitle.isNotEmpty
                    ? widget.actionData.subtitle
                    : null,
                onClose: () => Navigator.of(context).pop(),
              ),
              // const SizedBox(height: 16),
              // _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(child: _buildCarList()),
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
                hintText: AppTranslations.search,
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
            margin: const EdgeInsetsDirectional.only(end: 10),
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

  Widget _buildCarList() {
    return BlocBuilder<CarSearchBloc, CarSearchState>(
      builder: (context, state) {
        if (state is CarSearchInitial || state is CarSearchLoadInProgress) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.appThemeColor,
            ),
          );
        }

        if (state is CarSearchLoadFailure ||
            (state is CarSearchLoadSuccess &&
                state.filteredRentals.isEmpty)) {
          return _buildNoCarsFound();
        }

        if (state is CarSearchLoadSuccess) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              CarRentalsSearchWidget(
                rentals: state.filteredRentals,
                onCarRentalSelected: widget.onCarRentalSelected,
                onOpenInApp: widget.onOpenInEazyApp,
              ),
              const SizedBox(height: 24),
            ],
          );
        }

        return _buildNoCarsFound();
      },
    );
  }

  Widget _buildNoCarsFound() {
    return Center(
      child: Text(
        AppTranslations.noCarsFound,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyText.copyWith(
          color: const Color(0xFF979797),
        ),
      ),
    );
  }
}
