import 'package:flutter/material.dart';

import '../enums/component-type.dart';
import '../model/component.dart';

class ComponentToWidget {
  Widget convert(Component component) {
    switch (component.type) {
      case ComponentType.text:
        return Text("Text");

      case ComponentType.image:
        if (component.imageUrl != null) {
          return Image.network(component.imageUrl!);
        } else {
          return const SizedBox.shrink();
        }

      case ComponentType.button:
        return ElevatedButton(
          onPressed: () {},
          child: Text('Button'),
        );
    }
    // (No default needed since we've covered all enum values.)
  }

}