import 'package:flutter/material.dart';

const _loadMoreThreshold = 200.0;

class SearchPaginatedScrollController {
  SearchPaginatedScrollController({required VoidCallback onNearBottom})
      : _onNearBottom = onNearBottom {
    _controller.addListener(_handleScroll);
  }

  final VoidCallback _onNearBottom;
  final ScrollController _controller = ScrollController();

  ScrollController get controller => _controller;

  void dispose() {
    _controller
      ..removeListener(_handleScroll)
      ..dispose();
  }

  void _handleScroll() {
    if (!_controller.hasClients) return;

    final position = _controller.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) {
      return;
    }

    _onNearBottom();
  }
}
