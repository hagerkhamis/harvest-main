import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class CustomDropdownButtonFormFieldCustom<T> extends StatefulWidget {
  final String hintText;
  final List<T> items;
  final String Function(T)? itemToString;
  final ValueChanged<List<T>>? onChanged;
  final List<T>? initialValues;
  final String? labelText;

  const CustomDropdownButtonFormFieldCustom({
    super.key,
    required this.hintText,
    required this.items,
    this.itemToString,
    this.onChanged,
    this.initialValues,
    this.labelText,
  });

  @override
  _CustomDropdownButtonFormFieldCustomState<T> createState() =>
      _CustomDropdownButtonFormFieldCustomState<T>();
}

class _CustomDropdownButtonFormFieldCustomState<T>
    extends State<CustomDropdownButtonFormFieldCustom<T>> {
  List<T> selectedItems = [];
  bool isDropdownOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      selectedItems = List.from(widget.initialValues!);
    }
  }

  void _toggleDropdown() {
    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      isDropdownOpen = true;
    });
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        isDropdownOpen = false;
      });
    }
  }

  void _selectItem(T item) {
    setState(() {
      if (!selectedItems.contains(item)) {
        selectedItems.add(item);
      }
    });
    widget.onChanged?.call(selectedItems);
    _removeDropdown();
  }

  void _removeItem(T item) {
    setState(() {
      selectedItems.remove(item);
    });
    widget.onChanged?.call(selectedItems);
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
            child: Container(
              constraints: BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ListTile(
                    title: Text(
                        widget.itemToString?.call(item) ?? item.toString()),
                    onTap: () => _selectItem(item),
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: InputDecorator(
          decoration: InputDecoration(
            fillColor: whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: grey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                width: 1,
                color: grey,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(width: 1, color: grey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide:
                  BorderSide(style: BorderStyle.solid, color: discountRed),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(width: 1, color: grey),
            ),
            suffixIcon: Icon(Icons.arrow_drop_down),
            labelText: widget.labelText,
            filled: true,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start, // Center items horizontally
            children: selectedItems.isNotEmpty
                ? selectedItems.map((item) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: selectClip,
                        borderRadius:
                            BorderRadius.circular(20), // Rounded border
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Shrink to fit content
                        children: [
                          Text(
                            widget.itemToString?.call(item) ?? item.toString(),
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () => _removeItem(item),
                            child: Icon(Icons.close,
                                size: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                : [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        widget.hintText,
                        style: getMediumStyle(color: grey),
                        textAlign: TextAlign.center, 
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}
