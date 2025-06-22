import 'package:flutter/material.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/constants/padding.dart';
import 'package:teamxperience/model/stire.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Stire stire = ModalRoute.of(context)!.settings.arguments as Stire;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: 317,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(stire.principalImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White card overlay
          Positioned(
            top: 250, // Start overlapping the image
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child:  Padding(
                padding:  EdgeInsets.symmetric(horizontal: MyPaddings.appHorizontalPadding),
                child: Column(
                  children: [
                    Container(
                      width: 205,
                      height: 24,
                      color: MyColors.transparentLightBlue,
                      child: Row(
                        children: [
                          Text("Evenimente")
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}