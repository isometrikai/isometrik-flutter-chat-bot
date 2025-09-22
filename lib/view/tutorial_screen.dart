import 'package:chat_bot/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/asset_path.dart';

class TutorialScreen extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  
  const TutorialScreen({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 6,
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
       Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ChatBloc()),
            BlocProvider(create: (context) => CartBloc()),
          ],
          child: const ChatScreen(),
        ),
      ),
    );
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
    return Scaffold(
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              // Step indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (_currentPage + 1).toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF8E2FFD),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      '.${widget.totalSteps.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF171212),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
          if (_currentPage != 5) ...[
          // Skip button
          GestureDetector(
            onTap: () {
              // Navigate to chat screen or main app
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (context) => ChatBloc()),
                      BlocProvider(create: (context) => CartBloc()),
                    ],
                    child: const ChatScreen(),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(80),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF6E4185),
                  height: 1.4,
                ),
              ),
            ),
          ),
          ]
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        const Text(
          'Welcome to your\nzAIn AI assistant!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your Personal Assistant for Everything',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
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
      case 3:
        return _buildConversationExamplesPage();
      case 4:
        return _buildFeaturesPage();
      case 5:
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
            _buildChatSection(),
            
            const SizedBox(height: 20),
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
            
            // Service Cards
            _buildServiceCards(),
            
            const SizedBox(height: 16),
            
            // Benefits Banner
            _buildBenefitsBanner(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTitleSection() {
    return Column(
      children: [
        const Text(
          'What can I help you with today?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Explore all available services',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCards() {
    return Column(
      children: [
        _buildServiceCard(
          title: 'Food',
          description: 'Order from 1000+ restaurants',
          emoji: '🍕',
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: 'Groceries',
          description: 'Fresh produce delivered',
          emoji: '🥑',
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: 'Pharmacy',
          description: 'Medicines & health products',
          emoji: '💊',
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required String emoji,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF242424),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF585C77),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE0FFEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Available 24/7 • Fast delivery • Secure payments',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 1.4,
          color: Color(0xFF37A03C),
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
        const Text(
          'How to chat with zAIn',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Simple ways to get what you need',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
          ),
        ),
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
            // Speech bubble emoji decoration
            Positioned(
              left: 2,
              top: 70,
              child: Transform.rotate(
                angle: 0.32, // 18.09 degrees in radians
                child: const Text(
                  '💬',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Second Card - Get personalized help
        Stack(
          children: [
            _buildPersonalizedHelpCard(),
            // Sparkles emoji decoration
            Positioned(
              right: 2,
              bottom: 0,
              child: Transform.rotate(
                angle: 0.22, // 12.55 degrees in radians
                child: const Text(
                  '✨',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeakNaturallyCard() {
    return Container(
      width: 327,
      padding: const EdgeInsets.fromLTRB(24, 24, 15, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Just speak naturally',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 12),
          
          // Chat examples
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left aligned bubble
              Row(
                children: [
                  _buildChatBubble("I'm hungry, order some pizza"),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 4),
              // Right aligned bubble
              Row(
                children: [
                  const Spacer(),
                  _buildChatBubble("Need groceries for the week"),
                ],
              ),
              const SizedBox(height: 4),
              // Left aligned bubble
              Row(
                children: [
                  _buildChatBubble("Book a haircut for tomorrow"),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedHelpCard() {
    return Container(
      width: 327,
      padding: const EdgeInsets.fromLTRB(24, 24, 15, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Get personalized help',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "I'll ask follow-up questions to understand exactly what you need",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF6E4185),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0DAFE).withOpacity(0.8),
        border: Border.all(color: const Color(0xFFE9DFFB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.3,
          color: Color(0xFF242424),
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
        const Text(
          'Example conversations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'See how easy it is to get things done',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
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
              const Text(
                'Food order',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF242424),
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
                        child: _buildUserMessage("I want to order dinner for 4 people"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage("Great! What type of cuisine are you in the mood for?"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // User message 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _buildUserMessage("Something spicy, maybe Arabic"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage("Perfect! I found 5 top-rated Arabic restaurants nearby. Here are your options..."),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Pizza emoji decoration (top right)
        Positioned(
          right: 2,
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
        Positioned(
          left: 2,
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
              const Text(
                'Grocery Shopping',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF242424),
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
                        child: _buildUserMessage("Need groceries for breakfast this week"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage("I can help! What do you usually have for breakfast?"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // User message 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _buildUserMessage("Bread, milk, eggs, and some fruits"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Bot response 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: _buildBotMessage("Added to cart: Whole wheat bread, fresh milk, free-range eggs, and seasonal fruits. Total: \$24.99"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Cucumber emoji decoration (top right)
        Positioned(
          right: 2,
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
        Positioned(
          left: 2,
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
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.3,
          color: Color(0xFF242424),
        ),
        textAlign: TextAlign.right,
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
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.3,
          color: Color(0xFF242424),
        ),
        textAlign: TextAlign.left,
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
        const Text(
          'Why choose zAIn AI?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Smart features that make life easier',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: '⏱️',
          title: 'Available 24/7',
          description: 'Order anytime, day or night. I never sleep!',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: '📍',
          title: 'Location Smart',
          description: 'Finds the best options near you automatically',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: '❤️',
          title: 'Learns Your Preferences',
          description: 'Remembers your favorite orders and suggests them',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: '⭐',
          title: 'Best Quality',
          description: 'Partners with top-rated stores only',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: '📞',
          title: 'Real-time Updates',
          description: 'Track your orders and get instant notifications',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: '🎁',
          title: 'Special Deals',
          description: 'Exclusive discounts and offers just for you',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 327,
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        border: Border.all(color: const Color(0xFFEEF4FF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF242424),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF585C77),
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToStartPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Title Section
            _buildReadyToStartTitleSection(),
            
            const SizedBox(height: 24),
            
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
      children: [
        const Text(
          'Ready to Get Started?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your AI assistant is ready to help!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Start chatting with Zain AI to order food, shop for groceries, book services, and more. Just type what you need!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }

  Widget _buildReadyToStartContent() {
    return Column(
      children: [
        // Try saying section
        Container(
          width: 327,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Try saying header
              Row(
                children: [
                  const Text(
                    'Try saying:',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.4,
                      color: Color(0xFF242424),
                    ),
                  ),
                  const Spacer(),
                  // Chat bubble emoji
                  Transform.rotate(
                    angle: 0.32, // 18.09 degrees in radians
                    child: const Text(
                      '💬',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Example messages
              _buildExampleMessages(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Pro tip section
        Container(
          width: 327,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Lightbulb emoji
              const Text(
                '💡',
                style: TextStyle(fontSize: 36),
              ),
              const SizedBox(width: 11),
              // Pro tip text
              Expanded(
                child: Text(
                  'Pro tip: The more specific you are, the better I can help you!',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF242424),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExampleMessages() {
    return Column(
      children: [
        _buildExampleMessage('Order me a healthy lunch'),
        const SizedBox(height: 4),
        _buildExampleMessage('I need cleaning service this weekend'),
        const SizedBox(height: 4),
        _buildExampleMessage('Show me electronics deals'),
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
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.4,
          color: Color(0xFF242424),
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
        const Text(
          'Meet zAIn AI',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.2,
            color: Color(0xFF171212),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your intelligent chatbot that can help you order food, shop for groceries, buy medicines, book services and much more - all through simple conversations!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF6E4185),
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
          const Expanded(
            child: Text(
              'Just chat naturally -\nI\'ll understand what you need!',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
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
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              _nextPage();
            },
            child: Container(
              width: 327,
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFD445EC),
                    Color(0xFFB02EFB),
                    Color(0xFF8E2FFD),
                    Color(0xFF5E3DFE),
                    Color(0xFF5186E0),
                  ],
                  stops: [0.0, 0.27, 0.48, 0.76, 1.0],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Let's get started",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Regular navigation for other pages
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back Button
          GestureDetector(
            onTap: _previousPage,
            child: SvgPicture.asset(
              AssetPath.get('images/ic_previous.svg'),
              width: 60,
              height: 60,
            ),
          ),
          
          const SizedBox(width: 48),
          
          // Next Button
          GestureDetector(
            onTap: _nextPage,
            child: _currentPage == 5 ? SvgPicture.asset(
              AssetPath.get('images/ic_final.svg'),
              width: 60,
              height: 60,
            ) : SvgPicture.asset(
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