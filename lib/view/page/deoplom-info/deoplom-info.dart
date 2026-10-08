import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/model/offer_model.dart' as offer_model;
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:hatvest/services/app-service.dart' show ProfileService;
import 'package:hatvest/shared/widgets/loading_indicator.dart' show LoadingIndicator;

class DeoplomInfo extends StatefulWidget {
  final int offerId;
  final offer_model.Offer? offerData;

  const DeoplomInfo({super.key, required this.offerId, this.offerData});

  @override
  State<DeoplomInfo> createState() => _DeoplomInfoState();
}

class _DeoplomInfoState extends State<DeoplomInfo> {
  bool _descExpanded = false;
  offer_model.Offer? _localOfferData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.offerData != null) {
      _localOfferData = widget.offerData;
    } else if (widget.offerId != 0) {
      _fetchOfferDetails();
    }
  }

  Future<void> _fetchOfferDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ProfileService();
      final detailModel = await service.fetchOfferDetailsById(widget.offerId);
      final o = detailModel.offer;
      setState(() {
        _localOfferData = offer_model.Offer(
          id: o.id.toString(),
          image: o.image,
          courseTitle: o.course,
          title: o.title,
          titleEn: o.titleEn,
          titleAr: o.titleAr,
          itemType: o.itemType,
          fees: o.fees,
          oldFees: '',
          desc: o.track,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ أثناء تحميل تفاصيل العرض";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: context.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: LoadingIndicator(color: primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: context.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_localOfferData != null) {
      return _buildOfferContent(context, _localOfferData!);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(child: Text("offer_no_data".tr())),
    );
  }

  Widget _buildOfferContent(BuildContext context, offer_model.Offer offer) {
    final cleanDesc = offer.desc.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Image ──
                  Stack(
                    children: [
                      offer.image.isNotEmpty
                          ? Image.network(
                              offer.image,
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                "assets/images/slid-re.png",
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              "assets/images/slid-re.png",
                              width: double.infinity,
                              height: 260,
                              fit: BoxFit.cover,
                            ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                            ),
                          ),
                        ),
                      ),
                      // Back & Share buttons
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _circleBtn(Icons.arrow_forward, () => Navigator.pop(context), context),
                              _circleBtn(Icons.share_outlined, () {}, context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Title & Level badge ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                offer.title,
                                style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                offer.courseTitle,
                                style: getMediumStyle(color: primaryColor, fontSize: FontSize.s12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          offer.courseTitle,
                          style: getRegularStyle(color: context.textSecondary, fontSize: FontSize.s14),
                        ),

                        const SizedBox(height: 20),

                        // ── Description ──
                        if (cleanDesc.isNotEmpty) ...[
                          _sectionTitle(context, "الوصف"),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cleanDesc,
                                  maxLines: _descExpanded ? null : 4,
                                  overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style: getRegularStyle(color: context.textSecondary, fontSize: FontSize.s14),
                                ),
                                if (cleanDesc.length > 150) ...[
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () => setState(() => _descExpanded = !_descExpanded),
                                    child: Text(
                                      _descExpanded ? "أقل" : "المزيد",
                                      style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Information ──
                        _sectionTitle(context, "المعلومات"),
                        const SizedBox(height: 12),
                        _infoGrid(context, offer),

                        const SizedBox(height: 20),

                        // ── Details ──
                        _sectionTitle(context, "تفاصيل الكورس"),
                        const SizedBox(height: 12),
                        _detailsCard(context, offer),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Add to Cart ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            decoration: BoxDecoration(
              color: context.cardBg,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("price_label".tr(), style: getRegularStyle(color: context.textSecondary, fontSize: FontSize.s12)),
                    Text(
                      "${offer.fees} ج.م",
                      style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
                    ),
                    if (offer.oldFees.isNotEmpty && offer.oldFees != '0')
                      Text(
                        offer.oldFees,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Consumer<CartViewModel>(
                    builder: (context, cartVM, _) {
                      final isLoading = cartVM.isItemLoading(offer.id);
                      return GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => cartVM.addItemToCart(
                                  context: context,
                                  itemId: offer.id,
                                  itemType: offer.itemType,
                                  itemTitleEn: offer.titleEn,
                                  itemTitleAr: offer.titleAr,
                                ),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("add_to_arabic".tr(), style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.cardBg.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: context.textPrimary, size: 24),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s18));
  }

  Widget _infoGrid(BuildContext context, offer_model.Offer offer) {
    final items = [
      _InfoItem(Icons.attach_money_rounded, "السعر", "${offer.fees} ج.م"),
      _InfoItem(Icons.school_outlined, "الكورس", offer.courseTitle),
      if (offer.oldFees.isNotEmpty && offer.oldFees != '0')
        _InfoItem(Icons.local_offer_outlined, "السعر الأصلي", offer.oldFees),
      _InfoItem(Icons.category_outlined, "النوع", offer.itemType),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: items.map((item) => _infoChip(context, item)).toList(),
    );
  }

  Widget _infoChip(BuildContext context, _InfoItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.divider),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.label, style: getRegularStyle(color: context.textSecondary, fontSize: FontSize.s12)),
                Text(item.value, style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context, offer_model.Offer offer) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.divider),
      ),
      child: Column(
        children: [
          _detailRow(context, "الدبلومة", _getFirstWords(offer.title, 3), showDivider: false),
          _detailRow(context, "الكورس", offer.courseTitle),
          if (offer.oldFees.isNotEmpty && offer.oldFees != '0')
            _detailRow(context, "السعر الأصلي", "${offer.oldFees} ج.م"),
          _detailRow(context, "السعر الحالي", "${offer.fees} ج.م"),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        if (showDivider) Divider(height: 1, color: context.divider),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(label, style: getMediumStyle(color: context.textSecondary, fontSize: FontSize.s14)),
              const Spacer(),
              Text(value, style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s14)),
            ],
          ),
        ),
      ],
    );
  }

  String _getFirstWords(String text, int wordCount) {
    final words = text.trim().split(RegExp(r'\s+'));
    return words.take(wordCount).join(' ');
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
