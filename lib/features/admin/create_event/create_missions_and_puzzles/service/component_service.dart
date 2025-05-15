import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';

class ComponentService{
  Component createComponent(ComponentType type){
    Component component = Component(type: type);
    return component;
  }
}