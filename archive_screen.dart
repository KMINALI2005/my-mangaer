import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../widgets/debt_card.dart';

class ArchiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الأرشيف')),
      body: Consumer<DebtProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.archivedDebts.length,
            itemBuilder: (context, index) => DebtCard(
              debt: provider.archivedDebts[index],
              isArchived: true,
            ),
          );
        },
      ),
    );
  }
}
