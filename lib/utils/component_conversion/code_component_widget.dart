import 'package:flutter/material.dart';
import 'package:teamxperience/model/component.dart';

class CodeComponentWidget extends StatefulWidget {
  final Component component;
  final Function(String)? onTextChanged;

  const CodeComponentWidget({
    super.key,
    required this.component,
    this.onTextChanged
  });

  @override
  CodeComponentWidgetState createState() => CodeComponentWidgetState();
}

class CodeComponentWidgetState extends State<CodeComponentWidget> with SingleTickerProviderStateMixin {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  late AnimationController glowController;
  late Animation<double> glowAnimation;

  // Keep track of the length we last built for
  late int _lastLength;

  @override
  void initState() {
    super.initState();
    _lastLength = widget.component.codeLength ?? 5;
    _initControllers(_lastLength);
    glowController = AnimationController(vsync: this,duration: const Duration(milliseconds: 1000));
    glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        glowController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        glowController.forward();
      }
    });
    if (widget.component.enableGlow == true) {
      glowController.forward();
    }
  }

  @override
  void dispose() {
    glowController.dispose();
    _disposeControllers();
    super.dispose();
  }

  Color _hexToColor(String? hex, {Color defaultColor = Colors.black}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    final hexColor = hex.replaceFirst('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16)); // Full opacity
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16)); // With alpha
    } else {
      return defaultColor;
    }
  }

  void _initControllers(int length) {
    controllers = List.generate(length, (_) => TextEditingController());
    focusNodes  = List.generate(length, (_) => FocusNode());

    // Add listeners to all controllers to detect changes
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].addListener(() => _onTextChanged());
    }
  }

  void _disposeControllers() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
  }

  // New method to handle text changes and notify parent
  void _onTextChanged() {
    String combinedText;

    if (widget.component.inputType == 'Separated') {
      // Concatenate all controller texts for separated mode
      combinedText = controllers.map((controller) => controller.text).join('');
    } else {
      // For free mode, just use the first controller
      combinedText = controllers.isNotEmpty ? controllers[0].text : '';
    }

    // Notify parent widget
    if (widget.onTextChanged != null) {
      widget.onTextChanged!(combinedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int codeLength = widget.component.codeLength ?? 5;
    final String? inputType = widget.component.inputType;
    final double frameCornerRadius = widget.component.frameCornerRadius ?? 15.0;
    final double inputCornerRadius = widget.component.inputCornerRadius ?? 15.0;
    final Color frameBackgroundColor = _hexToColor(widget.component.frameBackgroundColor, defaultColor: const Color(0x00f5e8c7));
    final Color inputBackgroundColor = _hexToColor(widget.component.inputBackgroundColor, defaultColor: const Color(0x00f5e8c7));
    final Color colorBorderContainer = _hexToColor(widget.component.colorBorderContainer, defaultColor: Colors.black);
    final Color colorBorderInput = _hexToColor(widget.component.colorBorderInput, defaultColor: Colors.black);
    final bool enableGlow = widget.component.enableGlow ?? false;
    final Color glowColor = _hexToColor(widget.component.glowColor, defaultColor: Colors.black);
    final double widthInput = widget.component.width ?? 50;
    final double fontSize = widget.component.fontSize ?? 16.0;
    final double heightInput = fontSize * 1.5;
    final fontFamily = widget.component.fontFamily;
    final textColor = _hexToColor(widget.component.textColor);
    final capsLock = widget.component.capsLock ?? "Fără";

    if (codeLength != _lastLength) {
      _disposeControllers();
      _initControllers(codeLength);
      _lastLength = codeLength;
    }

    const int maxPerRow = 5;

    // Determine how many rows we need (ceil)
    final int rowCount = (codeLength + maxPerRow - 1) ~/ maxPerRow;

    // Distribute items as evenly as possible across rows
    final int basePerRow = codeLength ~/ rowCount;
    final int extra = codeLength % rowCount;

    Widget content;
    if (inputType == 'Separated') {
      // Build rows with evenly distributed cell counts for Separated mode
      int currentIndex = 0;
      final rows = List<Widget>.generate(rowCount, (rowIndex) {
        final countInRow = basePerRow + (rowIndex < extra ? 1 : 0);
        final rowCells = List<Widget>.generate(countInRow, (_) {
          final index = currentIndex;
          currentIndex++;
          return Expanded(
            child: _buildCell(index, heightInput, widthInput, inputCornerRadius, inputBackgroundColor,
                colorBorderInput,fontSize,fontFamily!,textColor, capsLock),
          );
        });

        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex == rowCount - 1 ? 0 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowCells,
          ),
        );
      });

      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      );
    } else {
      // Single input for Free mode
      content = _buildFreeCell(heightInput, widthInput, inputCornerRadius, inputBackgroundColor,
          colorBorderInput, fontSize,fontFamily!,textColor, capsLock);
    }

    // Wrap in outer Container only for Separated mode
    return inputType == 'Separated'
        ? AnimatedBuilder(
      animation: glowAnimation,
      builder: (context,child)=>
          IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: frameBackgroundColor,
                borderRadius: BorderRadius.circular(frameCornerRadius),
                border: Border.all(color: colorBorderContainer, width: 1.5),
                boxShadow: enableGlow == true
                    ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: (0.6 +glowAnimation.value * 0.2)),
                    blurRadius: 10.0,
                    spreadRadius: 2.0 + (glowAnimation.value * 3.0),
                    offset: const Offset(0, 0),
                  ),
                ]
                    : null,
              ),
              child: content,
            ),
          ),
    )
        : content;
  }

  Widget _buildCell(int index, double heightInput, double widthInput, double? inputCornerRadius,
      Color inputBackgroundColor, Color colorBorderInput,double fontSize, String fontFamily, Color textColor, String capsLock) {
    return Container(
      height: heightInput,
      width: widthInput,
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: capsLock == 'Fără' ? TextCapitalization.none : TextCapitalization.characters,
        maxLength: 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: inputBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
            borderSide: BorderSide(color: colorBorderInput, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
            borderSide: BorderSide(color: colorBorderInput, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
            borderSide: BorderSide(color: colorBorderInput, width: 1),
          ),
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
        onChanged: (value) {
          if (value.length == 1 && index < controllers.length - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
          // Note: _onTextChanged() is called automatically via the listener
        },
        style:  TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: textColor
        ),
      ),
    );
  }

  Widget _buildFreeCell(double heightInput, double widthInput, double? inputCornerRadius,
      Color inputBackgroundColor, Color colorBorderInput, double fontSize, String fontFamily, Color textColor, String capsLock) {
    return Container(
      height: heightInput,
      width: widthInput,
      decoration: BoxDecoration(
        color: inputBackgroundColor,
        borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controllers.isNotEmpty ? controllers[0] : TextEditingController(),
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: capsLock == 'Fără' ? TextCapitalization.none : TextCapitalization.characters,
        decoration: InputDecoration(
          filled: true,
          fillColor: inputBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
            borderSide: BorderSide(color: colorBorderInput, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
            borderSide: BorderSide(color: colorBorderInput, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputCornerRadius ?? 25),
            borderSide: BorderSide(color: colorBorderInput, width: 1),
          ),
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
        style:  TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: textColor
        ),
        // Note: _onTextChanged() is called automatically via the listener for free mode too
      ),
    );
  }
}