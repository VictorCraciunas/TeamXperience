import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/enums/component-type.dart';
import 'package:teamxperience/model/component.dart';
import 'package:teamxperience/model/puzzle.dart';

import 'package:teamxperience/ui/components/inputs/app_dropdown.dart';
import '../../controller/add_missions_controller.dart';
import 'create_button/create_button_component.dart';
import 'create_code/create_code_component.dart';
import 'create_image/create_image_component.dart';
import 'create_text/create_text_component.dart';
import 'box_shadow_controls.dart';
import 'opacity_slider.dart';
import 'space_below_slider.dart';

class AddComponentWidget extends StatefulWidget {
  final Puzzle puzzle;
  final Function(Widget) refreshUI; // callback to notify parent
  final Component component;
  final bool edit;

  const AddComponentWidget({
    super.key,
    required this.puzzle,
    required this.refreshUI,
    required this.component,
    required this.edit,
  });

  @override
  State<AddComponentWidget> createState() => _AddComponentWidgetState();
}

class _AddComponentWidgetState extends State<AddComponentWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.edit) {
      type = widget.component.type;
    }
  }

  ComponentType? type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.page,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: 60),
              AppDropdown<ComponentType>(
                label: 'Tip de componenta',
                items:
                    ComponentType.values
                        .map(
                          (type) => AppDropdownItem<ComponentType>(
                            value: type,
                            label: type.toString().split('.').last,
                          ),
                        )
                        .toList(),
                value: type,
                onChanged: (value) {
                  setState(() {
                    type = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a component type' : null,
                hint: "Selecteaza tipul de componenta",
              ),
              if (type != null) ...[
                const SizedBox(height: 20),
                SpaceBelowSlider(
                  value: widget.component.spaceBelow,
                  onChanged: (value) => setState(() => widget.component.spaceBelow = value),
                ),
                const SizedBox(height: 20),
                OpacitySlider(
                  value: widget.component.opacity,
                  // Fully visible is "not set", so the component stays as it was.
                  onChanged: (value) => setState(() => widget.component.opacity = value >= 1 ? null : value),
                ),
                // A text has its own shadow controls in its editor.
                if (type != ComponentType.text) ...[
                  const SizedBox(height: 20),
                  BoxShadowControls(
                    component: widget.component,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ],
              if (type == ComponentType.text) ...[
                TextComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component: widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,
                ),
              ],
              if (type == ComponentType.image) ...[
                ImageComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component: widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,
                ),
              ],
              if (type == ComponentType.button) ...[
                ButtonComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component: widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,
                ),
              ],
              if (type == ComponentType.code) ...[
                CodeComponentFieldsWidget(
                  refreshUI: widget.refreshUI,
                  component: widget.component,
                  edit: widget.edit,
                  puzzle: widget.puzzle,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
