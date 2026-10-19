import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teamxperience/constants/colors.dart';
import 'package:teamxperience/model/event.dart';

import 'menu.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String appBarText;
  final String? subtitle;
  final String? iconString;
  final bool showDropdown;
  final Event? event;
  final Widget? trailing;

  const MyAppBar({
    super.key,
    required this.appBarText,
    this.subtitle,
    this.iconString,
    this.showDropdown = false,
    this.event,
    this.trailing,
  });

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  final GlobalKey _menuButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = _menuButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to close menu when tapping outside
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),
          // Dropdown menu positioned below the menu button
          Positioned(
            top: offset.dy + size.height + 8,
            right: MediaQuery.of(context).size.width - offset.dx - size.width,
            child: Material(
              color: Colors.transparent,
              child: MenuWidget(
                onClose: _removeOverlay,
                event: widget.event
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: const Color(0x1A000000),
      backgroundColor: MyColors.barColor,
      title: widget.subtitle != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.appBarText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: MyColors.blackColor,
                  ),
                ),
                Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: MyColors.greyText,
                  ),
                ),
              ],
            )
          : Text(
              widget.appBarText,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: MyColors.blackColor,
              ),
            ),
      centerTitle: true,
      actions: [
        if (widget.trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: widget.trailing!,
          )
        else if (widget.iconString != null)
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              key: _menuButtonKey,
              onTap: widget.showDropdown ? _toggleMenu : null,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _isMenuOpen
                      ? MyColors.transparentLightBlue.withValues(alpha: 0.8)
                      : MyColors.transparentLightBlue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    widget.iconString!,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}