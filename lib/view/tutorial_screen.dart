import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/asset_path.dart';
import '../utils/utils.dart';

class TutorialScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  
  const TutorialScreen({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 5,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentStep - 1);
    _currentPage = widget.currentStep - 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      OrderService().triggerTutorialDismiss();
    //    Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MultiBlocProvider(
    //       providers: [
    //         BlocProvider(create: (context) => ChatBloc()),
    //         BlocProvider(create: (context) => CartBloc()),
    //       ],
    //       child: const ChatScreen(),
    //     ),
    //   ),
    // );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLocale.wrap(
      Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              
              _buildHeader(),
              
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),// Disable Swipe Horizontal Scroll
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: widget.totalSteps,
                  itemBuilder: (context, index) {
                    return _buildTutorialPage(index);
                  },
                ),
              ),
              
              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_currentPage > 0)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                onTap: _previousPage,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: SvgPicture.asset(
                    AssetPath.get('images/ic_previous.svg'),
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          // Step indicator (centered)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (_currentPage + 1).toString().padLeft(2, '0'),
                  style:
                  AppTextStyles.restaurantTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.appThemeColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    '.${widget.totalSteps.toString().padLeft(2, '0')}',
                    style:
                    AppTextStyles.restaurantDescription.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF171212),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentPage != 4)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GestureDetector(
            onTap: () {
              OrderService().triggerTutorialDismiss();
              // Navigate to chat screen or main app
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MultiBlocProvider(
              //       providers: [
              //         BlocProvider(create: (context) => ChatBloc()),
              //         BlocProvider(create: (context) => CartBloc()),
              //       ],
              //       child: const ChatScreen(),
              //     ),
              //   ),
              // );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(80),
              ),
              child:  Text(
                AppTranslations.skip,
                style:
                AppTextStyles.restaurantDescription.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF414F85),
                  height: 1.4,
                ),),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
         Text(
          AppTranslations.welcomeEazyAssistant,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantTitle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171212),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
         Text(
          AppTranslations.aiPersonalAssistantTagline,
          textAlign: TextAlign.center,
          style: 
          AppTextStyles.restaurantDescription.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7085AE),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialPage(int index) {
    switch (index) {
      case 0:
        return _buildWelcomePage();
      case 1:
        return _buildServiceSelectionPage();
      case 2:
        return _buildChatTutorialPage();
      // case 3:
      //   return _buildConversationExamplesPage();
      case 3:
        return _buildFeaturesPage();
      case 4:
        return _buildReadyToStartPage();
      default:
        return _buildWelcomePage();
    }
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Welcome Section
            _buildWelcomeSection(),
            
            const SizedBox(height: 40),
            
            // Central Image with gradient background
            _buildCentralImage(),
            
            const SizedBox(height: 40),
            
            // Meet zAIn AI Section
            _buildMeetZainSection(),
            
            const SizedBox(height: 24),
            
            // Chat naturally section
            // _buildChatSection(),
            
            const SizedBox(height: 20),
            
            // Bottom decorative star
            SvgPicture.asset(
              AssetPath.get('images/ic_first_star.svg'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelectionPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Title Section
            _buildServiceTitleSection(),
            
            const SizedBox(height: 24),

             // Benefits Banner
            _buildBenefitsBanner(),
            
            const SizedBox(height: 20),
            
            // Service Cards
            _buildServiceCards(),
            
            const SizedBox(height: 16),
            
            // Benefits Banner
            // _buildBenefitsBanner(),
            
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTitleSection() {
    return Column(
      children: [
         Text(
          AppTranslations.whatCanIHelpToday,
          textAlign: TextAlign.center,
          style: 
          AppTextStyles.restaurantTitle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171212),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
         Text(
          AppTranslations.exploreAllServices,
          textAlign: TextAlign.center,
          style: 
          AppTextStyles.restaurantDescription.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7085AE),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCards() {
    return Column(
      children: [
        _buildServiceCard(
          title: AppTranslations.labelFood,
          description: AppTranslations.svcDescFood,
          emoji: '🍕',
          iconPath: 'ic_food.svg',
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: AppTranslations.labelGroceries,
          description: AppTranslations.svcDescGroceries,
          emoji: '🥑',
          iconPath: 'ic_Groceries.svg',
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: AppTranslations.labelPharmacy,
          description: AppTranslations.svcDescPharmacy,
          emoji: '💊',
          iconPath: 'ic_pharmacy.svg',
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: AppTranslations.labelShopping,
          description: AppTranslations.svcDescShopping,
          emoji: '🛍️',
          iconPath: 'ic_shopping_s.svg',
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: AppTranslations.labelServices,
          description: AppTranslations.svcDescServices,
          emoji: '🔧',
          iconPath: 'ic_services.svg',
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    String? emoji,
    String? iconPath,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFE0EBFF), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: iconPath != null
                  ? SvgPicture.asset(
                      AssetPath.get('images/$iconPath'),
                      // width: 24,
                      // height: 24,
                      fit: BoxFit.scaleDown,
                    )
                  : Text(
                      emoji ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Expanded(
                    //   child: 
                      Text(
                        title,
                        style: AppTextStyles.restaurantTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF414F85),
                          height: 1.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    // ),
                    if ((emoji ?? '').isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        emoji!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTextStyles.restaurantDescription.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF7085AE),
                    height: 1.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsBanner() {
    const green = Color(0xFF13A755);
    const dividerColor = Color(0xFFA9BCE3);
    final textStyle = AppTextStyles.restaurantDescription.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: green,
      height: 1.4,
    );

    Widget _benefitItem(IconData icon, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: green),
          const SizedBox(width: 6),
          Text(label, style: textStyle),
        ],
      );
    }

    Widget _divider() {
      return Container(
        width: 1,
        height: 9,
        color: dividerColor,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _benefitItem(Icons.check_circle, AppTranslations.benefitActive247),
            const SizedBox(width: 12),
            _divider(),
            const SizedBox(width: 12),
            _benefitItem(Icons.schedule, AppTranslations.benefitUnder2s),
            const SizedBox(width: 12),
            _divider(),
            const SizedBox(width: 12),
            _benefitItem(Icons.people, AppTranslations.benefit50kAssisted),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTutorialPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Title Section
            _buildChatTitleSection(),
            
            const SizedBox(height: 32),
            
            // Chat Tutorial Cards
            _buildChatTutorialCards(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTitleSection() {
    return Column(
      children: [
         Text(
          AppTranslations.askAnythingYouWant,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantTitle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171212),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
           Text(
          AppTranslations.naturalConversation,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantDescription.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7085AE),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
           Text(
          AppTranslations.askNaturallyBody,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantDescription.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2F3C70),
            height: 1.4,
          ),
        )
      ],
    );
  }

  Widget _buildChatTutorialCards() {
    return Column(
      children: [
        // First Card - Just speak naturally
        Stack(
          children: [
            _buildSpeakNaturallyCard(),
            // // Speech bubble emoji decoration
            // Positioned(
            //   left: 2,
            //   top: 70,
            //   child: Transform.rotate(
            //     angle: 0.32, // 18.09 degrees in radians
            //     child:  Text(
            //       '💬',
            //       style: TextStyle(fontSize: 36),
            //     ),
            //   ),
            // ),
          ],
        ),
        
        // const SizedBox(height: 24),
        
        // // Second Card - Get personalized help
        // Stack(
        //   children: [
        //     _buildPersonalizedHelpCard(),
        //     // Sparkles emoji decoration
        //     Positioned(
        //       right: 2,
        //       bottom: 0,
        //       child: Transform.rotate(
        //         angle: 0.22, // 12.55 degrees in radians
        //         child: const Text(
        //           '✨',
        //           style: TextStyle(fontSize: 36),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildSpeakNaturallyCard() {
    final bubbleTexts = [
      AppTranslations.exampleNeedGroceries,
      AppTranslations.exampleBookHaircut,
      AppTranslations.exampleElectronicsDeals,
      AppTranslations.exampleHealthyDinner,
      AppTranslations.exampleMedicineHeadache,
    ];

    return Container(
      width: 327,
      padding: const EdgeInsetsDirectional.fromSTEB(15, 24, 15, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFE0EBFF), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < bubbleTexts.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            Row(
              mainAxisAlignment: i.isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (i.isOdd) const Spacer(),
                _buildChatBubble(bubbleTexts[i], alignRight: i.isOdd),
                if (i.isEven) const Spacer(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalizedHelpCard() {
    return Container(
      width: 327,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 15, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(
            AppTranslations.getPersonalizedHelp,
            style: 
            AppTextStyles.restaurantTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF242424),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
           Text(
            AppTranslations.followUpQuestions,
            textAlign: TextAlign.center,
            style: 
            AppTextStyles.restaurantDescription.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6E4185),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, {bool alignRight = true}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(color: const Color(0xFFF0F4FF), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.end : TextAlign.start,
        style: AppTextStyles.restaurantDescription.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2F3C70),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildConversationExamplesPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Title Section
            _buildConversationTitleSection(),
            
            const SizedBox(height: 24),
            
            // Conversation Examples
            _buildConversationExamples(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTitleSection() {
    return Column(
      children: [
         Text(
          AppTranslations.exampleConversations,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantTitle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 12),
         Text(
          AppTranslations.seeHowEasy,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantDescription.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6E4185),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildConversationExamples() {
    return Column(
      children: [
        // Food Order Conversation
        _buildFoodOrderConversation(),
        
        const SizedBox(height: 16),
        
        // Grocery Shopping Conversation
        _buildGroceryShoppingConversation(),
      ],
    );
  }

  Widget _buildFoodOrderConversation() {
    return Stack(
      children: [
        Container(
          width: 327,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            border: Border.all(color: const Color(0xFFEEF4FF)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
                AppTranslations.foodOrder,
                style: AppTextStyles.restaurantTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242424),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              
              // Conversation flow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User message 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _buildUserMessage(AppTranslations.demoUserOrderDinner),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage(AppTranslations.demoBotCuisine),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // User message 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _buildUserMessage(AppTranslations.demoUserSpicyArabic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage(AppTranslations.demoBotFoundRestaurants),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Pizza emoji decoration (top right)
        PositionedDirectional(
          end: 2,
          top: 65,
          child: Transform.rotate(
            angle: 0.32, // 18.09 degrees in radians
            child: const Text(
              '🍕',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
        
        // Hamburger emoji decoration (bottom left)
        PositionedDirectional(
          start: 2,
          bottom: 60,
          child: Transform.rotate(
            angle: 0.32, // 18.09 degrees in radians
            child: const Text(
              '🍔',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroceryShoppingConversation() {
    return Stack(
      children: [
        Container(
          width: 327,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            border: Border.all(color: const Color(0xFFEEF4FF)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                 Text(
                AppTranslations.groceryShopping,
                style: AppTextStyles.restaurantTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242424),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              
              // Conversation flow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User message 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _buildUserMessage(AppTranslations.demoUserBreakfastGroceries),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage(AppTranslations.demoBotBreakfast),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // User message 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _buildUserMessage(AppTranslations.demoUserBreadMilk),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage(AppTranslations.demoBotAddedCart),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Cucumber emoji decoration (top right)
        PositionedDirectional(
          end: 2,
          top: 70,
          child: Transform.rotate(
            angle: 0.33, // 18.65 degrees in radians
            child: const Text(
              '🥒',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
        
        // Avocado emoji decoration (bottom left)
        PositionedDirectional(
          start: 2,
          bottom: 60,
          child: Transform.rotate(
            angle: 0.32, // 18.09 degrees in radians
            child: const Text(
              '🥑',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DAFE).withOpacity(0.8),
        border: Border.all(color: const Color(0xFFE9DFFB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.restaurantDescription.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF242424),
          height: 1.3,
        ),
        textAlign: TextAlign.end,
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
          style: AppTextStyles.restaurantDescription.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.3,
          color: Color(0xFF242424)
        ),
        textAlign: TextAlign.start,
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Title Section
            _buildFeaturesTitleSection(),
            
            const SizedBox(height: 24),
            
            // Features List
            _buildFeaturesList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesTitleSection() {
    return Column(
      children: [
         Text(
          AppTranslations.whyChooseEazy,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantTitle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 12),
         Text(
          AppTranslations.smartFeaturesEasier,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantDescription.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: Color(0xFF7085AE),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureCard(
          icon: 'ic_available.svg',
          title: AppTranslations.featureAvailable247,
          description: AppTranslations.featureAvailable247Desc,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: 'ic_real_time.svg',
          title: AppTranslations.featureRealtimeUpdates,
          description: AppTranslations.featureRealtimeUpdatesDesc,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: 'ic_location.svg',
          title: AppTranslations.featureLocationSmart,
          description: AppTranslations.featureLocationSmartDesc,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: 'ic_learns.svg',
          title: AppTranslations.featureLearnsPrefs,
          description: AppTranslations.featureLearnsPrefsDesc,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: 'ic_best_quality.svg',
          title: AppTranslations.featureBestQuality,
          description: AppTranslations.featureBestQualityDesc,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: 'ic_special_deals.svg',
          title: AppTranslations.featureSpecialDeals,
          description: AppTranslations.featureSpecialDealsDesc,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          // width: 40,
          // height: 40,
          // padding: const EdgeInsets.all(6),
          // decoration: BoxDecoration(
          //   color: const Color(0xFFF8FAFF),
          //   border: Border.all(color: const Color(0xFFE0EBFF), width: 1),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: Center(
            child: SvgPicture.asset(
              AssetPath.get('images/$icon'),
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.restaurantTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: const Color(0xFF2F3C70),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: AppTextStyles.restaurantDescription.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: const Color(0xFF7085AE),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadyToStartPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Logo
            SvgPicture.asset(
              AssetPath.get('images/ic_LogoTutorial.svg'),
              width: 120,
              height: 120,
            ),
            
            const SizedBox(height: 32),
            
            // Title Section
            _buildReadyToStartTitleSection(),
            
            const SizedBox(height: 32),
            
            // Main Content
            _buildReadyToStartContent(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyToStartTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppTranslations.registerCreateAccount,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantTitle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: const Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppTranslations.toGetFullAccess,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantDescription.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: const Color(0xFF7085AE),
          ),
        ),
      ],
    );
  }

  Widget _buildReadyToStartContent() {
    final features = [
      AppTranslations.benefitOrderRestaurants,
      AppTranslations.benefitShopGroceries,
      AppTranslations.benefitBookAppointments,
      AppTranslations.benefitSecurePayments,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(51, 24, 51, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < features.length; i++) ...[
            if (i > 0) const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient icon
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2D8AFF),
                      Color(0xFF4EC4F8),
                    ],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    features[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.restaurantTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.2,
                      color: const Color(0xFF2F3C70),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleMessages() {
    return Column(
      children: [
        _buildExampleMessage(AppTranslations.exampleHealthyLunch),
        const SizedBox(height: 4),
        _buildExampleMessage(AppTranslations.exampleCleaningWeekend),
        const SizedBox(height: 4),
        _buildExampleMessage(AppTranslations.exampleElectronicsDeals),
      ],
    );
  }

  Widget _buildExampleMessage(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DAFE).withOpacity(0.8),
        border: Border.all(color: const Color(0xFFE9DFFB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: AppTextStyles.restaurantDescription.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF242424),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCentralImage() {
    return SvgPicture.asset(
      AssetPath.get('images/ic_LogoTutorial.svg'),
      fit: BoxFit.contain,
    );
  }

  Widget _buildMeetZainSection() {
    return Column(
      children: [
        //  Text(
        //   'Meet AI assistant',
        //   style: AppTextStyles.restaurantTitle.copyWith(
        //     fontWeight: FontWeight.w700,
        //     fontSize: 20,
        //     height: 1.2,
        //     color: Color(0xFF171212),
        //   ),
        // ),
        // const SizedBox(height: 8),
         Text(
          AppTranslations.tutorialHeroBody,
          textAlign: TextAlign.center,
          style: AppTextStyles.restaurantDescription.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF2F3C70),
          ),
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Chat icon placeholder (you can replace with actual icon)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF8E2FFD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 11),
           Expanded(
            child: Text(
              AppTranslations.justChatNaturally,
              style: AppTextStyles.restaurantDescription.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF242424),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    // Show "Let's get started" button on the first page
    if (_currentPage == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              _nextPage();
            },
            child: Container(
              width: 60,
              height: 60,
              child: SvgPicture.asset(
              AssetPath.get('images/ic_next.svg'),
                width: 60,
                height: 60,
              ),
            ),
          ),
        ),
      );
    }
    
    // Regular navigation for other pages
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: _currentPage == 4
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: double.infinity,
                  height: 62,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppConstants.appThemeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTranslations.register,
                        style: AppTextStyles.restaurantTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      // const SizedBox(width: 8),
                      // SvgPicture.asset(
                      //   AssetPath.get('images/ic_next.svg'),
                      //   width: 20,
                      //   height: 20,
                      //   colorFilter: const ColorFilter.mode(
                      //     Colors.white,
                      //     BlendMode.srcIn,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Back Button
                // GestureDetector(
                //   onTap: _previousPage,
                //   child: SvgPicture.asset(
                //     AssetPath.get('images/ic_previous.svg'),
                //     width: 60,
                //     height: 60,
                //   ),
                // ),
                
                // const SizedBox(width: 48),
                
                // Next Button
                GestureDetector(
                  onTap: _nextPage,
                  child: SvgPicture.asset(
                    AssetPath.get('images/ic_next.svg'),
                    width: 60,
                    height: 60,
                  ),
                ),
              ],
            ),
    );
  }
}