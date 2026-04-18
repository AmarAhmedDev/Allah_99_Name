import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/allah_name.dart';
import '../providers/names_provider.dart';
import '../providers/language_provider.dart';
import '../constants/app_strings.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerId;
  bool _isLoading = true;
  bool _showResults = false;

  // Slide animation controller
  late AnimationController _slideController;
  late Animation<Offset> _slideOutAnimation;
  late Animation<Offset> _slideInAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAnimating = false;

  // Result screen animation
  late AnimationController _resultController;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _resultFadeAnimation;

  // Confetti particles
  final List<_ConfettiParticle> _confettiParticles = [];
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();

    // Slide animation for question transitions
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideOutAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.2, 0)).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInCubic),
          ),
        );

    _slideInAnimation =
        Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 45),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 45),
    ]).animate(_slideController);

    // Result screen animation
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _resultScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _resultFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _resultController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQuestions();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _resultController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _generateConfettiParticles() {
    final random = Random();
    _confettiParticles.clear();

    // Paper confetti colors - vibrant and festive
    final colors = [
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFFE66D), // Yellow
      const Color(0xFFA8E6CF), // Mint
      const Color(0xFFFF8B94), // Pink
      const Color(0xFF6C5CE7), // Purple
      const Color(0xFF00B894), // Green
      const Color(0xFFFD79A8), // Rose
      const Color(0xFF74B9FF), // Blue
      const Color(0xFFE17055), // Orange
      const Color(0xFFD4AF37), // Gold
      const Color(0xFF55EFC4), // Aqua
    ];

    for (int i = 0; i < 80; i++) {
      final isLeft = random.nextBool();
      _confettiParticles.add(
        _ConfettiParticle(
          startX: isLeft ? -20.0 : MediaQuery.of(context).size.width + 20,
          startY: random.nextDouble() * -200 - 50,
          endX: random.nextDouble() * MediaQuery.of(context).size.width,
          endY: MediaQuery.of(context).size.height + 50,
          color: colors[random.nextInt(colors.length)],
          size: random.nextDouble() * 12 + 6,
          rotation: random.nextDouble() * 720 - 360,
          delay: random.nextDouble() * 0.4,
          isRect: random.nextBool(),
          width: random.nextDouble() * 10 + 4,
          height: random.nextDouble() * 14 + 6,
        ),
      );
    }
  }

  void _generateQuestions() {
    final namesProvider = context.read<NamesProvider>();

    if (namesProvider.isLoading) {
      Future.delayed(const Duration(milliseconds: 100), _generateQuestions);
      return;
    }

    final allNames = namesProvider.allNames;

    if (allNames.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final random = Random();
    final List<Question> newQuestions = [];

    for (int i = 0; i < 10; i++) {
      final correctName = allNames[random.nextInt(allNames.length)];
      final Set<int> usedIds = {correctName.id};
      final List<AllahName> choices = [correctName];

      while (choices.length < 4) {
        final distractor = allNames[random.nextInt(allNames.length)];
        if (!usedIds.contains(distractor.id)) {
          choices.add(distractor);
          usedIds.add(distractor.id);
        }
      }

      choices.shuffle();
      newQuestions.add(Question(correctName: correctName, choices: choices));
    }

    setState(() {
      _questions = newQuestions;
      _isLoading = false;
      _showResults = false;
    });
  }

  void _handleAnswer(int selectedId) {
    if (_isAnswered || _isAnimating) return;

    final isCorrect = selectedId == _questions[_currentIndex].correctName.id;

    setState(() {
      _isAnswered = true;
      _selectedAnswerId = selectedId;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_isAnimating) return;

    if (_currentIndex < _questions.length - 1) {
      _isAnimating = true;
      _slideController.forward().then((_) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswerId = null;
        });
        _slideController.reset();
        _isAnimating = false;
      });
    } else {
      _showResultsScreen();
    }
  }

  void _showResultsScreen() {
    _generateConfettiParticles();
    setState(() {
      _showResults = true;
    });
    _resultController.forward(from: 0);
    _confettiController.forward(from: 0);
  }

  void _restartQuiz() {
    _resultController.reset();
    _confettiController.reset();
    _slideController.reset();
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerId = null;
      _isLoading = true;
      _showResults = false;
      _isAnimating = false;
    });
    _generateQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Questions')),
        body: const Center(child: Text('No names available for questions.')),
      );
    }

    if (_showResults) {
      return _buildResultsScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),

          // Question content with slide animation
          Expanded(
            child: AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                final offset = _slideController.isAnimating
                    ? (_slideController.value < 0.5
                          ? _slideOutAnimation.value
                          : _slideInAnimation.value)
                    : Offset.zero;

                final opacity = _slideController.isAnimating
                    ? _fadeAnimation.value
                    : 1.0;

                return Transform.translate(
                  offset: Offset(
                    offset.dx * MediaQuery.of(context).size.width,
                    offset.dy * MediaQuery.of(context).size.height,
                  ),
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: _buildQuestionContent(currentQuestion),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_questions.length, (index) {
          final isCompleted = index < _currentIndex;
          final isCurrent = index == _currentIndex;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted
                    ? AppColors.gold
                    : isCurrent
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuestionContent(Question currentQuestion) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Card
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.bgCardDark
                      : AppColors.bgCardLight,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  AppStrings.whatIsNameFor(context.watch<LanguageProvider>().isAmharicAudio),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLG),
                Text(
                  currentQuestion.correctName.meaningEn,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.paddingMD),
                Text(
                  currentQuestion.correctName.meaningAm,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingXL),

          // 2x2 Grid Choices
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.paddingMD,
            crossAxisSpacing: AppSizes.paddingMD,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(currentQuestion.choices.length, (index) {
              final choice = currentQuestion.choices[index];
              return _buildChoiceCard(choice, currentQuestion);
            }),
          ),
          
          const Spacer(),

          // Next Button with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _isAnswered
                ? Padding(
                    key: const ValueKey('next_button'),
                    padding: const EdgeInsets.only(
                      top: AppSizes.paddingMD, 
                      bottom: AppSizes.padding2XL, // Pushed up to avoid navigation bar
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMD,
                            ),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentIndex < _questions.length - 1
                                  ? AppStrings.nextQuestion(context.watch<LanguageProvider>().isAmharicAudio)
                                  : AppStrings.seeResults(context.watch<LanguageProvider>().isAmharicAudio),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_currentIndex < _questions.length - 1) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard(AllahName choice, Question currentQuestion) {
    final isSelected = _selectedAnswerId == choice.id;
    final isCorrect = choice.id == currentQuestion.correctName.id;

    Color? cardColor;
    Color borderColor = Colors.transparent;
    IconData? feedbackIcon;

    if (_isAnswered) {
      if (isCorrect) {
        cardColor = const Color(0xFF00B894).withValues(alpha: 0.15);
        borderColor = const Color(0xFF00B894);
        feedbackIcon = Icons.check_circle_rounded;
      } else if (isSelected) {
        cardColor = const Color(0xFFFF6B6B).withValues(alpha: 0.15);
        borderColor = const Color(0xFFFF6B6B);
        feedbackIcon = Icons.cancel_rounded;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleAnswer(choice.id),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          splashColor: AppColors.gold.withValues(alpha: 0.2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: cardColor ?? Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: _isAnswered
                    ? borderColor
                    : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                width: _isAnswered && (isCorrect || isSelected) ? 2.5 : 1,
              ),
              boxShadow: [
                if (_isAnswered && isCorrect)
                  BoxShadow(
                    color: const Color(0xFF00B894).withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                if (_isAnswered && isSelected && !isCorrect)
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isAnswered && feedbackIcon != null && (isCorrect || isSelected))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(
                      feedbackIcon,
                      color: isCorrect
                          ? const Color(0xFF00B894)
                          : const Color(0xFFFF6B6B),
                      size: 16,
                    ),
                  ),
                Flexible(
                  child: Text(
                    choice.arabic,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== RESULTS SCREEN ==========
  Widget _buildResultsScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 50;

    String emoji;
    String message;
    Color accentColor;

    if (isExcellent) {
      emoji = '🎉';
      message = 'Excellent! Ma Sha Allah!';
      accentColor = const Color(0xFF00B894);
    } else if (isGood) {
      emoji = '👏';
      message = 'Good Job! Keep Learning!';
      accentColor = AppColors.gold;
    } else {
      emoji = '💪';
      message = 'Keep Practicing! You Can Do It!';
      accentColor = const Color(0xFFE17055);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _resultController,
              builder: (context, child) {
                return Opacity(
                  opacity: _resultFadeAnimation.value,
                  child: Transform.scale(
                    scale: _resultScaleAnimation.value,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.paddingXL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // Emoji
                            Text(emoji, style: const TextStyle(fontSize: 72)),
                            const SizedBox(height: AppSizes.paddingLG),

                            // Message
                            Text(
                              message,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.padding2XL),

                            // Score Circle
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor.withValues(alpha: 0.15),
                                    accentColor.withValues(alpha: 0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: accentColor,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.3),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_score/${_questions.length}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                      color: accentColor,
                                    ),
                                  ),
                                  Text(
                                    '$percentage%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: accentColor.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSizes.padding2XL),

                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  '✅',
                                  AppStrings.correctStats(context.watch<LanguageProvider>().isAmharicAudio),
                                  '$_score',
                                  const Color(0xFF00B894),
                                ),
                                _buildStatCard(
                                  '❌',
                                  AppStrings.wrongStats(context.watch<LanguageProvider>().isAmharicAudio),
                                  '${_questions.length - _score}',
                                  const Color(0xFFFF6B6B),
                                ),
                                _buildStatCard(
                                  '📝',
                                  AppStrings.totalStats(context.watch<LanguageProvider>().isAmharicAudio),
                                  '${_questions.length}',
                                  AppColors.gold,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.padding2XL),

                            // Action Buttons
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _restartQuiz,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(AppStrings.tryAgain(context.watch<LanguageProvider>().isAmharicAudio)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMD,
                                    ),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingMD),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.home_rounded),
                                label: Text(AppStrings.returnHome(context.watch<LanguageProvider>().isAmharicAudio)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: BorderSide(color: accentColor),
                                  foregroundColor: accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMD,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Confetti overlay from left and right
          if (_showResults)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return IgnorePointer(
                  child: CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _ConfettiPainter(
                      particles: _confettiParticles,
                      progress: _confettiController.value,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class Question {
  final AllahName correctName;
  final List<AllahName> choices;

  Question({required this.correctName, required this.choices});
}

// ========== CONFETTI SYSTEM ==========

class _ConfettiParticle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final Color color;
  final double size;
  final double rotation;
  final double delay;
  final bool isRect;
  final double width;
  final double height;

  _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.delay,
    required this.isRect,
    required this.width,
    required this.height,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Adjust progress based on particle delay
      final adjustedProgress =
          ((progress - particle.delay) / (1.0 - particle.delay)).clamp(
            0.0,
            1.0,
          );

      if (adjustedProgress <= 0) continue;

      // Ease out for natural motion
      final easedProgress = Curves.easeOutQuad.transform(adjustedProgress);

      final x =
          particle.startX +
          (particle.endX - particle.startX) * easedProgress +
          sin(adjustedProgress * 6 * pi) * 30; // Side-to-side wobble

      final y =
          particle.startY + (particle.endY - particle.startY) * easedProgress;

      // Fade out near the end
      final opacity = adjustedProgress > 0.7
          ? (1.0 - (adjustedProgress - 0.7) / 0.3)
          : 1.0;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation * adjustedProgress * pi / 180);

      if (particle.isRect) {
        // Draw small rectangular paper piece
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.width,
              height: particle.height,
            ),
            const Radius.circular(1),
          ),
          paint,
        );
      } else {
        // Draw circle confetti
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
