import 'package:chat_bot/chat_bot.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/complete_setup/complete_setup_step_pages.dart';
import 'package:chat_bot/view/complete_setup/setup_complete_screen.dart';

/// Single-screen Complete Setup flow (like TutorialScreen).
/// Manages all 10 steps in one route via PageView; header and footer are shared.
class CompleteSetupFlowScreen extends StatefulWidget {
  final Function(String) onCallback;
  const CompleteSetupFlowScreen({super.key, required this.onCallback});
  

  @override
  State<CompleteSetupFlowScreen> createState() =>
      _CompleteSetupFlowScreenState();
}

class _CompleteSetupFlowScreenState extends State<CompleteSetupFlowScreen> {
  static const int _totalSteps = 10;

  late final PageController _pageController;
  late final UserPreferenceBloc userPreferenceBloc;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    userPreferenceBloc = UserPreferenceBloc()
      ..add(const UserPreferenceLoadRequested());
  }

  @override
  void dispose() {
    _pageController.dispose();
    userPreferenceBloc.close();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      userPreferenceBloc.add(const UserPreferenceSubmitRequested());
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onSkip() {
    if(mounted) {
      if(ChatBot.isCompleteSetupShown == true) {
         // TODO: Handle button tap
        OrderService().triggerChatDismiss();
      }else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: userPreferenceBloc,
      child: BlocListener<UserPreferenceBloc, UserPreferenceState>(
        listenWhen: (prev, curr) => curr.submitStatus != prev.submitStatus,
        listener: (context, state) {
          if (state.isSubmitSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>  SetupCompleteScreen(onCallback: widget.onCallback),
              ),
            );
          }
          if (state.isSubmitFailure && state.submitMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.submitMessage!)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocBuilder<UserPreferenceBloc, UserPreferenceState>(
              buildWhen: (prev, curr) => prev.loadStatus != curr.loadStatus,
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemCount: _totalSteps,
                        itemBuilder: (context, index) {
                          return SizedBox.expand(
                            key: ValueKey<int>(index),
                            child: CompleteSetupStepPages.buildStep(context, index),
                          );
                        },
                      ),
                    ),
                    _buildBottomNavigation(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stepNum = (_currentPage + 1).toString().padLeft(2, '0');
    final isFirst = _currentPage == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: isFirst ? _onSkip : _previousPage,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                isFirst ? Icons.close : Icons.arrow_back,
                size: isFirst ? 20 : 24,
                color: const Color(0xFF242424),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                stepNum,
                style: AppTextStyles.body(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D8AFF),
                ),
              ),
              Text(
                AppTranslations.setupStepOfTen('10'),
                style: AppTextStyles.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF171212),
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onSkip,
              borderRadius: BorderRadius.circular(80),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(80),
                ),
                child: Text(
                  AppTranslations.skip,
                  style: AppTextStyles.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF414F85),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final stepNum = (_currentPage + 1).toString().padLeft(2, '0');
    final isLast = _currentPage == _totalSteps - 1;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                stepNum,
                style: AppTextStyles.body(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D8AFF),
                ),
              ),
              Text(
                AppTranslations.setupStepOfTen('10'),
                style: AppTextStyles.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F3C70),
                ),
              ),
            ],
          ),
          Material(
            color: const Color(0xFF007AFF),
            borderRadius: BorderRadius.circular(90),
            child: InkWell(
              onTap: _nextPage,
              borderRadius: BorderRadius.circular(90),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  isLast ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                  size: isLast ? 28 : 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
