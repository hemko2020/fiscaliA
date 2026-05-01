import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'tabs/guides_tab.dart';
import 'tabs/faq_tab.dart';
import 'tabs/glossary_tab.dart';

class EducationalCenterScreen extends ConsumerStatefulWidget {
  const EducationalCenterScreen({super.key});

  @override
  ConsumerState<EducationalCenterScreen> createState() =>
      _EducationalCenterScreenState();
}

class _EducationalCenterScreenState
    extends ConsumerState<EducationalCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre Éducatif'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accentGreen,
          tabs: const [
            Tab(icon: Icon(Icons.library_books), text: 'Guides'),
            Tab(icon: Icon(Icons.question_answer), text: 'FAQ'),
            Tab(icon: Icon(Icons.sort_by_alpha), text: 'Glossaire'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [GuidesTab(), FaqTab(), GlossaryTab()],
      ),
    );
  }
}
