import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mimory/features/book/models/book_page_data.dart';
import 'package:mimory/features/book/presentation/widgets/book_navigation.dart';

// Import the actual pages (we will create these next)
import 'package:mimory/features/today/presentation/today_page.dart';
import 'package:mimory/features/goals/presentation/goals_page.dart';
import 'package:mimory/features/achievements/presentation/achievements_page.dart';
import 'package:mimory/features/moments/presentation/moments_page.dart';
import 'package:mimory/features/chapters/presentation/chapters_page.dart';
import 'package:mimory/features/world/presentation/world_page.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  
  final List<BookPageData> _pages = [
    const BookPageData(
      id: '01',
      title: 'TODAY',
      pageNumber: 1,
      content: TodayPage(),
    ),
    const BookPageData(
      id: '02',
      title: 'GOALS',
      pageNumber: 2,
      content: GoalsPage(),
    ),
    const BookPageData(
      id: '03',
      title: 'LITTLE WINS',
      pageNumber: 3,
      content: AchievementsPage(),
    ),
    const BookPageData(
      id: '04',
      title: 'MOMENTS',
      pageNumber: 4,
      content: MomentsPage(),
    ),
    const BookPageData(
      id: '05',
      title: 'CHAPTERS',
      pageNumber: 5,
      content: ChaptersPage(),
    ),
    BookPageData(
      id: '06',
      title: 'MEMORY ECHO',
      pageNumber: 6,
      content: const Center(child: Text('MEMORY ECHO (Coming Soon)')),
    ),
    const BookPageData(
      id: '07',
      title: 'MY WORLD',
      pageNumber: 7,
      content: WorldPage(),
    ),
    BookPageData(
      id: '08',
      title: 'MEMORY CLOUD',
      pageNumber: 8,
      content: const Center(child: Text('MEMORY CLOUD (Coming Soon)')),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPageIndex != next) {
        setState(() {
          _currentPageIndex = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800; // arbitrary threshold for tablet/desktop
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _nextPage();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _previousPage();
              } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Column(
            children: [
              Expanded(
                child: isDesktop 
                    ? _buildDesktopSpread() 
                    : _buildMobileView(),
              ),
              BookNavigation(
                currentPage: isDesktop ? (_currentPageIndex * 2) + 1 : _currentPageIndex + 1,
                totalPages: _pages.length,
                onPrevious: _previousPage,
                onNext: _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSpread() {
    // For desktop, each "page" in the controller shows 2 physical pages.
    // Calculate total spreads
    int totalSpreads = (_pages.length / 2).ceil();
    
    // We recreate a local page controller if the main one is for mobile
    // Actually, to make it simple without rebuilding the controller, we can just use the same controller
    // but the item count is halved.
    
    return PageView.builder(
      controller: _pageController,
      itemCount: totalSpreads,
      itemBuilder: (context, index) {
        final leftPageIndex = index * 2;
        final rightPageIndex = leftPageIndex + 1;
        
        final leftPage = leftPageIndex < _pages.length ? _pages[leftPageIndex] : null;
        final rightPage = rightPageIndex < _pages.length ? _pages[rightPageIndex] : null;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Row(
            children: [
              Expanded(
                child: _BookPageWidget(
                  pageData: leftPage, 
                  isLeft: true,
                ),
              ),
              Expanded(
                child: _BookPageWidget(
                  pageData: rightPage, 
                  isLeft: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _BookPageWidget(
            pageData: _pages[index],
            isLeft: true, // For mobile, styling is simpler
          ),
        );
      },
    );
  }
}

class _BookPageWidget extends StatelessWidget {
  final BookPageData? pageData;
  final bool isLeft;

  const _BookPageWidget({
    this.pageData,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    if (pageData == null) {
      return const SizedBox.expand(); // Empty page
    }

    // A subtle shadow and border to mimic a book page
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: isLeft 
            ? const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16))
            : const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(isLeft ? -2 : 2, 4),
          ),
        ],
        border: Border(
          right: isLeft ? BorderSide(color: Colors.black.withOpacity(0.05), width: 1) : BorderSide.none,
          left: !isLeft ? BorderSide(color: Colors.black.withOpacity(0.05), width: 1) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.all(32.0),
      child: pageData!.content,
    );
  }
}
