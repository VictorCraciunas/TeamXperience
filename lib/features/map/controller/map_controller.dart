import 'package:flutter/cupertino.dart';
import 'package:teamxperience/model/team.dart';

class MyMapController{
  late Stream<List<Team>> teams;
  late BuildContext context;

  MyMapController({required this.context, required this.teams});
}