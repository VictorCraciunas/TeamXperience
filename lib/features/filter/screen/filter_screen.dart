import 'package:flutter/material.dart';
import 'package:teamxperience/enums/event_type.dart';
import 'package:teamxperience/widgets/my_appbar.dart';
import 'package:teamxperience/widgets/my_dropdown.dart';


class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBarText: "Filtrare"),
      body: SafeArea(child: Column(
        children: [
        ],
      )),
    );
  }
}
