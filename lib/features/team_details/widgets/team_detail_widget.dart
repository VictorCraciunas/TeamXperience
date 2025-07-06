import 'package:flutter/cupertino.dart';
import 'package:teamxperience/constants/colors.dart';

class TeamDetailWidget extends StatelessWidget {
  final String text1;
  final String text2;
  const TeamDetailWidget({super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color:MyColors.blackColor),),
        SizedBox(height: 10,),
        Text(text2, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13,color:MyColors.blackColor),),
      ],
    );
  }
}
