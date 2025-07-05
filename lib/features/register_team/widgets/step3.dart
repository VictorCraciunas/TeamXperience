// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../../constants/colors.dart';
//
// class Step3 extends StatefulWidget {
//   bool checkBox1;
//   bool checkBox2 ;
//   bool checkBox3;
//   const Step3({super.key, required this.checkBox1, required this.checkBox2, required this.checkBox3});
//
//   @override
//   State<Step3> createState() => _Step3State();
// }
//
// class _Step3State extends State<Step3> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Transform.scale(
//               scale: 1.5,
//               child: Checkbox(
//                 value: checkBox1,
//                 onChanged:
//                     (value) => setState(
//                       () => controller.checkBox1 = value!,
//                 ),
//                 activeColor: MyColors.yellow,
//                 checkColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 side: const BorderSide(
//                   width: 1.5,
//                   color: Color(0xFFE6E6E6),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 5),
//             const Expanded(
//               child: Text(
//                 "Sunt de acord cu Regulamentul Specific al activității.",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: MyColors.blackColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         Row(
//           children: [
//             Transform.scale(
//               scale: 1.5,
//               child: Checkbox(
//                 value: controller.checkBox2,
//                 onChanged:
//                     (value) => setState(
//                       () => controller.checkBox2 = value!,
//                 ),
//                 activeColor: MyColors.yellow,
//                 checkColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 side: const BorderSide(
//                   width: 1.5,
//                   color: Color(0xFFE6E6E6),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 5),
//             const Expanded(
//               child: Text(
//                 "Sunt de acord cu folosirea datelor cu caracter personal.",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: MyColors.blackColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Transform.scale(
//               scale: 1.5,
//               child: Checkbox(
//                 value: controller.checkBox3,
//                 onChanged:
//                     (value) => setState(
//                       () => controller.checkBox3 = value!,
//                 ),
//                 activeColor: MyColors.yellow,
//                 checkColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 side: const BorderSide(
//                   width: 1.5,
//                   color: Color(0xFFE6E6E6),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 5),
//             const Expanded(
//               child: Text(
//                 "Sunt de acord ca imaginile și  video-urile care sunt realizate de organizatori sau de membrii echipei  mele în timpul activității să îmi fie trimise după eveniment. În același timp ASOCIAȚIA VBE SIBIU poate folosi aceste resurse pentru promovare.",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: MyColors.blackColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
