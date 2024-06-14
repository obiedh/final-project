import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SportsCategoriesScreen extends ConsumerStatefulWidget {
  const SportsCategoriesScreen({super.key});

  @override
  ConsumerState<SportsCategoriesScreen> createState() {
    return _SportsCategoriesState();
  }
}

class _SportsCategoriesState extends ConsumerState<SportsCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    
    return const Stack(children: [
      Center(child: Column(children: [

      ]),)
    ],);
  }
  

}