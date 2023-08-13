import 'package:flutter/material.dart';

import '../reusable_widgets/loading.dart';
import 'generic.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenericPage(scrollable: false, body: LoadingFuture());
  }
}