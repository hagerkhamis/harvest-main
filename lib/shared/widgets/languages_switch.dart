import 'package:flutter/material.dart';

class LanguageSwitch extends StatefulWidget {
  final String seletedLangCode;
  final void Function(String langCode)? onChange;
  const LanguageSwitch({super.key, this.seletedLangCode = "ar", this.onChange});

  @override
  State<LanguageSwitch> createState() => _LanguageSwitchState();
}

class _LanguageSwitchState extends State<LanguageSwitch>
    with TickerProviderStateMixin {
  late String languageCode;
  late AnimationController _animationController;
  late Animation<Offset> _move;

  @override
  void initState() {
    assert(widget.seletedLangCode == "ar" || widget.seletedLangCode == "en");
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _move = Tween<Offset>(begin: const Offset(02, 0), end: const Offset(60, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut));
    languageCode = widget.seletedLangCode;
    if (languageCode == 'en') _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (_move.value.dx == 60.0) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          });
          Future.delayed(const Duration(milliseconds: 250), () {
            if (languageCode == 'ar') {
              languageCode = 'en';
              setState(() {});
              if (widget.onChange != null) widget.onChange!(languageCode);
              return;
            }
            if (languageCode == 'en') {
              languageCode = 'ar';
              if (widget.onChange != null) widget.onChange!(languageCode);
              setState(() {});
              return;
            }
          });
        },
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          height: 40.0,
          width: 130.0,
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _move.value,
                      child: Container(
                        height: 40.0,
                        width: 66.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            ),
                      ),
                    );
                  }),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 11.0,
                    ),
                    child: Text("English",
                        style: TextStyle(
                            color: languageCode == 'en'
                                ? Colors.black
                                : Colors.grey.shade700,
                            fontWeight: languageCode == 'en'
                                ? FontWeight.bold
                                : FontWeight.w500)),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 13.0,
                    ),
                    child: Text(
                      "العربية",
                      style: TextStyle(
                          color: languageCode == 'ar'
                              ? Colors.black
                              : Colors.grey.shade700,
                          fontWeight: languageCode == 'ar'
                              ? FontWeight.bold
                              : FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
