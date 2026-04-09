import 'package:flutter/material.dart';
import 'package:hokkien_dictionary/features/dictionary/domain/dictionary_models.dart';

class EntryListItem extends StatelessWidget {
  const EntryListItem({super.key, required this.entry, required this.onTap});

  final DictionaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        label: _semanticLabel(entry),
        hint: '雙擊開啟詞條詳細資料',
        child: ExcludeSemantics(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              titleAlignment: ListTileTitleAlignment.top,
              title: Text(
                entry.hanji.isEmpty ? '未標記漢字' : entry.hanji,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF18363C),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.romanization.isNotEmpty)
                    Text(
                      entry.romanization,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFC9752D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (entry.briefSummary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.briefSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5A6D71),
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF708286),
              ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

String _semanticLabel(DictionaryEntry entry) {
  final parts = <String>[
    entry.hanji.isEmpty ? '未標記漢字' : entry.hanji,
  ];
  if (entry.romanization.isNotEmpty) {
    parts.add('白話字 ${entry.romanization}');
  }
  if (entry.briefSummary.isNotEmpty) {
    parts.add('釋義 ${entry.briefSummary}');
  }
  return parts.join('。');
}
