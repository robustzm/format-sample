import 'package:bank_management/provider/AppProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomFilterSheet extends StatefulWidget {
  @override
  _CustomFilterSheetState createState() => _CustomFilterSheetState();
}

class _CustomFilterSheetState extends State<CustomFilterSheet> {
  var titleType = ['All', 'Credit', 'Debit'];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    return ListView(
      shrinkWrap: true,
      children: List<Widget>.generate(
        3,
        (index) {
          return RadioListTile(
            value: index,
            groupValue: provider.transactionIndex,
            onChanged: (index) {
              provider.setTransactionIndex(index);
              Navigator.pop(context);
            },
            title: Text(
              titleType[index],
              style: TextStyle(
                fontWeight: index == provider.transactionIndex
                    ? FontWeight.w400
                    : FontWeight.w300,
              ),
            ),
          );
        },
      ),
    );
  }
}
