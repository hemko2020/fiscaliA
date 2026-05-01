import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/education_provider.dart';
import '../content_sheet_screen.dart';

class GuidesTab extends ConsumerWidget {
  const GuidesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheets = ref.watch(educationalSheetsProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sheets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sheet = sheets[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentSheetScreen(sheetId: sheet.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.primaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sheet.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sheet.shortDescription,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}