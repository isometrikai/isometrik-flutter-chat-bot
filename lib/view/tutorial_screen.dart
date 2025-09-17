import 'package:flutter/material.dart';
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
      // Navigate to chat screen when tutorial is complete
      Navigator.pushReplacementNamed(context, '/chat');
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
          
          // Skip button
          GestureDetector(
            onTap: () {
              // Navigate to chat screen or main app
              Navigator.pushReplacementNamed(context, '/chat');
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
            const SizedBox(height: 10),
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
              bottom: 20,
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
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChatBubble("I'm hungry, order some pizza"),
              const SizedBox(height: 4),
              _buildChatBubble("Need groceries for the week"),
              const SizedBox(height: 4),
              _buildChatBubble("Book a haircut for tomorrow"),
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
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF8E2FFD),
                size: 24,
              ),
            ),
          ),
          
          const SizedBox(width: 48),
          
          // Next Button
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              width: 60,
              height: 60,
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
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}