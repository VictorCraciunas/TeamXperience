import 'package:flutter/material.dart';
import '../../../../../../../enums/component-type.dart';
import '../../../../../../../model/component.dart';
import '../../../../../../../model/puzzle.dart';
import '../../../../../../../utils/component_conversion/component_to_widget.dart';
import 'package:teamxperience/ui/components/buttons/app_button.dart';
import 'package:teamxperience/ui/components/misc/slider_widget.dart';
import '../../../../common_widgets/upload_image.dart';
import '../../../controller/add_missions_controller.dart';
import 'create_image_controller.dart';

class ImageComponentFieldsWidget extends StatefulWidget {
  final Function(Widget) refreshUI;
  final Component component;
  final bool edit;
  final Puzzle puzzle;

  const ImageComponentFieldsWidget({
    super.key,
    required this.refreshUI,
    required this.component,
    required this.edit,
    required this.puzzle,
  });

  @override
  State<ImageComponentFieldsWidget> createState() =>
      _ImageComponentFieldsWidgetState();
}

class _ImageComponentFieldsWidgetState
    extends State<ImageComponentFieldsWidget> {
  late final ImageComponentController controller;

  @override
  void initState() {
    super.initState();
    controller = ImageComponentController();

    // Initialize controller with existing data if in edit mode
    if (widget.edit && widget.component.type == ComponentType.image) {
      controller.initializeFromComponent(widget.component);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildImageUploadSection(),
        const SizedBox(height: 20),
        _buildImagePreview(),
        const SizedBox(height: 20),
        _buildRadiusSlider(),
        const SizedBox(height: 20),
        _buildHeightSlider(),
        const SizedBox(height: 20),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () async {
        await controller.pickImage();
        setState(() {}); // Update the UI after picking an image
      },
      child: UploadImage(
        labelText: 'Adaugă imagine',
        imageUrl: controller.image?.path,
      ),
    );
  }

  Widget _buildImagePreview() {
    if (controller.image == null) {
      return const SizedBox.shrink();
    }

    // Create a temporary Component for preview
    final previewComponent = Component();
    controller.updateComponentFields(previewComponent);

    // Use ComponentToWidget to convert to widget
    final previewWidget = ComponentToWidget().convert(previewComponent);

    return Padding(padding: const EdgeInsets.all(10), child: previewWidget);
  }

  Widget _buildRadiusSlider() {
    return SliderWidget(
      title: 'Rotunjire imagine',
      min: 0,
      max: 50,
      divisions: 50,
      value: controller.radius,
      label: controller.radius.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.radius = value),
    );
  }

  Widget _buildHeightSlider() {
    return SliderWidget(
      title: 'Înălțime imagine',
      min: 150,
      max: 500,
      divisions: 500,
      value: controller.height,
      label: controller.height.toStringAsFixed(0),
      onChanged: (value) => setState(() => controller.height = value),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: SizedBox(
        width: 270,
        child: AppButton(
          label: 'Salvează componenta',
          onPressed: () {
            controller.saveComponent(
              context: context,
              puzzle: widget.puzzle,
              component: widget.component,
              refreshUI: widget.refreshUI,
              isEditMode: widget.edit,
            );
          },
        ),
      ),
    );
  }
}
