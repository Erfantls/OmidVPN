import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';

class DisconnectAlertDialog extends ConsumerWidget {
  const DisconnectAlertDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);

    return AlertDialog(
      title: Text(lang.areYouSureYouWantToContinue),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(lang.no),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(lang.yes),
        ),
      ],
      content: Text(lang.yourCurrentSessionWillBeTerminated),
    );
  }
}
