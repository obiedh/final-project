import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/model/stadium.dart';

class AddFieldScreen extends ConsumerStatefulWidget {
  const AddFieldScreen({super.key, required this.stadium});
  final Stadium stadium;

  @override
  ConsumerState<AddFieldScreen> createState() {
    return _AddFieldScreenState();
  }
}

class _AddFieldScreenState extends ConsumerState<AddFieldScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}