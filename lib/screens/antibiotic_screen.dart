import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/data.dart';
import '../utils/theme.dart';

class AntibioticScreen extends StatefulWidget {
  const AntibioticScreen({super.key});

  @override
  State<AntibioticScreen> createState() => _AntibioticScreenState();
}

class _AntibioticScreenState extends State<AntibioticScreen> {
  String _query = '';
  String _filter = 'all';
  int? _expandedIdx;

  List<AntibioticEntry> get _filtered {
    return antibioticData.where((e) {
      final matchCat = _filter == 'all' || e.category == _filter;
      final matchQuery = _query.isEmpty ||
          e.disease.toLowerCase().contains(_query.toLowerCase()) ||
          e.agent.toLowerCase().contains(_query.toLowerCase()) ||
          e.firstLine.toLowerCase().contains(_query.toLowerCase()) ||
          e.alternative.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() { _query = v; _expandedIdx = null; }),
            decoration: InputDecoration(
              hintText: 'Rechercher…',
              hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
              filled: true, fillColor: AppTheme.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.teal, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            _chip('all', 'Toutes'), const SizedBox(width: 8),
            _chip('bacterial', 'Bactériennes'), const SizedBox(width: 8),
            _chip('parasitic', 'Parasitaires'), const SizedBox(width: 8),
            _chip('viral', 'Virales'),
          ]),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Aucun résultat',
                  style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) => _EntryCard(
                    entry: items[i],
                    isExpanded: _expandedIdx == i,
                    onTap: () => setState(() =>
                        _expandedIdx = _expandedIdx == i ? null : i),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String value, String label) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() { _filter = value; _expandedIdx = null; }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navy : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.navy : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textPrimary)),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final AntibioticEntry entry;
  final bool isExpanded;
  final VoidCallback onTap;

  const _EntryCard({required this.entry, required this.isExpanded, required this.onTap});

  Color get _catColor {
    switch (entry.category) {
      case 'bacterial': return AppTheme.categoryBact;
      case 'parasitic': return AppTheme.categoryPara;
      case 'viral': return AppTheme.categoryViral;
      default: return AppTheme.textSecondary;
    }
  }

  Color get _catBg {
    switch (entry.category) {
      case 'bacterial': return AppTheme.categoryBactBg;
      case 'parasitic': return AppTheme.categoryParaBg;
      case 'viral': return AppTheme.categoryViralBg;
      default: return AppTheme.border;
    }
  }

  String get _catLabel {
    switch (entry.category) {
      case 'bacterial': return 'Bact';
      case 'parasitic': return 'Para';
      case 'viral': return 'Viral';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpanded
            ? AppTheme.teal.withOpacity(0.4) : AppTheme.border),
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _catBg,
                    borderRadius: BorderRadius.circular(4)),
                child: Text(_catLabel, style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w700, color: _catColor)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.disease, style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppTheme.navy)),
                  Text(entry.agent, style: const TextStyle(fontSize: 11,
                      fontStyle: FontStyle.italic, color: AppTheme.teal)),
                ],
              )),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.textSecondary),
            ]),
          ),
        ),
        if (isExpanded) ...[
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('1ère intention', entry.firstLine, AppTheme.teal, AppTheme.tealSurface),
              const SizedBox(height: 10),
              _section('Alternative', entry.alternative, AppTheme.gold, const Color(0xFFFEF6E0)),
              const SizedBox(height: 10),
              _infoRow(Icons.schedule, 'Durée', entry.duration),
              if (entry.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _infoRow(Icons.info_outline, 'Remarques', entry.notes),
              ],
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _section(String title, String content, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(), style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Text(content, style: const TextStyle(fontSize: 13,
            color: AppTheme.textPrimary, height: 1.5)),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppTheme.textSecondary),
      const SizedBox(width: 6),
      Text('$label : ', style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12,
          color: AppTheme.textSecondary, height: 1.4))),
    ]);
  }
}
