
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../model/event.dart';

class AddMissionsController{
    int selectedIndex = 0;
    List<Column> missions = [];
    Event? event;

    Widget mission(int index, Function callBack) {
        return GestureDetector(
            onTap: (){
                callBack();
            },
            child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Colors.blue[100]
                        : Colors.red[200],
                    borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    'Mission ${index + 1}',
                    style: const TextStyle(fontSize: 16),
                ),
            ),
        );
    }

}