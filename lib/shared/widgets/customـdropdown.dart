import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/values_manager.dart';

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final String Function(T)? itemToString;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final List<Widget>? prefixRowIcons;
  final Color? enabledBorderColor;
  final double? width;
  final double? height;
  final Color? fillColor;
  final String? Function(T?)? validator;
  final bool isRequired;

  const CustomDropdownButtonFormField({
    super.key,
    required this.hintText,
    this.fillColor,
    required this.items,
    this.itemToString,
    this.onChanged,
    this.value,
    this.prefixRowIcons,
    this.enabledBorderColor,
    this.width,
    this.height,
    this.validator,
    this.isRequired = false,
  });

  @override
  _CustomDropdownButtonFormFieldState<T> createState() =>
      _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T>
    extends State<CustomDropdownButtonFormField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isDropdownOpen = false;
  bool _isTouched = false;
  bool _isDisposed = false;

  String? get _errorText {
    if (widget.validator != null) {
      return widget.validator!(widget.value);
    }
    if (widget.isRequired && widget.value == null && _isTouched) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  void _toggleDropdown() {
    setState(() {
      _isTouched = true;
    });
    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isDropdownOpen = false;
    if (!mounted || _isDisposed) return;

    setState(() {
      isDropdownOpen = false;
    });
  }

  void _showDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    // Close when tapping outside
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _removeDropdown(),
      );
    });

    setState(() {
      isDropdownOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.items.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return InkWell(
                    onTap: () {
                      widget.onChanged?.call(item);
                      _removeDropdown();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Text(
                        widget.itemToString?.call(item) ?? item.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? 340,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 20,
                bottom: 20,
                right: 20.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide(color: widget.enabledBorderColor ?? Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: widget.enabledBorderColor ?? Colors.deepPurple),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
              ),
              suffixIcon: SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/arrow_drop_down.svg",
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
              fillColor: widget.fillColor ?? Colors.transparent,
              filled: true,
              prefixIcon: widget.prefixRowIcons != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.prefixRowIcons!,
                    )
                  : null,
              errorText: _errorText,
            ),
            child: Text(
              widget.value != null
                  ? (widget.itemToString != null
                      ? widget.itemToString!(widget.value!)
                      : widget.value.toString())
                  : widget.hintText,
              style: getRegularStyle(
                color: grey,
                fontSize: AppSize.s16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;
    isDropdownOpen = false;
    super.dispose();
  }
}
