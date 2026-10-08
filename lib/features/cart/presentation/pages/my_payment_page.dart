import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/features/cart/data/models/invoice_response.dart';
import 'package:hatvest/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _accentGreen = Color(0xFF2E7D32);
const _softGreen = Color(0xFFE8F5E9);
const _softGrey = Color(0xFFF5F6FA);
const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.harvest.harvest';
const _appStoreUrl = 'https://harvestcollege.co.uk/';

class MyPayment extends StatefulWidget {
  const MyPayment({super.key});

  @override
  State<MyPayment> createState() => _MyPaymentState();
}

class _MyPaymentState extends State<MyPayment> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartViewModel>(context, listen: false).fetchInvoices();
      final profile = Provider.of<ProfileViewModel>(context, listen: false);
      if (profile.profile == null) {
        profile.getProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "invoice_title".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/bottomNav'),
            icon: Icon(Icons.arrow_forward, color: blackColors, size: 30),
          ),
        ],
      ),
      body: Consumer2<CartViewModel, ProfileViewModel>(
        builder: (context, cart, profileVm, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.invoices.isEmpty) {
            return Center(child: Text("no_invoices".tr()));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
            itemCount: cart.invoices.length,
            itemBuilder: (context, index) {
              return _WebStyleInvoiceCard(
                invoice: cart.invoices[index],
                clientName: profileVm.profile?.name ?? '',
                clientPhone: profileVm.profile?.mobile1 ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class _WebStyleInvoiceCard extends StatefulWidget {
  final Invoice invoice;
  final String clientName;
  final String clientPhone;

  const _WebStyleInvoiceCard({
    required this.invoice,
    required this.clientName,
    required this.clientPhone,
  });

  @override
  State<_WebStyleInvoiceCard> createState() => _WebStyleInvoiceCardState();
}

class _WebStyleInvoiceCardState extends State<_WebStyleInvoiceCard> {
  bool _termsOpen = false;

  Invoice get invoice => widget.invoice;

  bool get _isFullyPaid {
    final status = invoice.paymentStatus.toLowerCase();
    if (status.contains('paid') ||
        status == 'مدفوع' ||
        status.contains('بالكامل')) {
      return true;
    }
    final remaining = _remainingAmount;
    return remaining <= 0.009;
  }

  double get _remainingAmount {
    final payments = invoice.leadPayments ?? [];
    if (payments.isEmpty) return 0;
    return payments.fold<double>(0, (sum, lp) {
      return sum + (double.tryParse(lp.rest) ?? 0);
    });
  }

  double get _totalPaid {
    double sum = 0;
    for (final lp in invoice.leadPayments ?? []) {
      for (final sp in lp.subPayments ?? []) {
        final paid = sp.paid == '1' || sp.paid == 'نعم';
        if (paid) sum += double.tryParse(sp.amount) ?? 0;
      }
    }
    return sum;
  }

  double get _gross {
    return double.tryParse(invoice.totalPrice) ?? 0;
  }

  double get _discount {
    return double.tryParse(invoice.totalDiscount ?? '0') ?? 0;
  }

  double get _net => (_gross - _discount).clamp(0, double.infinity);

  String _money(num value) {
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$text EGP';
  }

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
      return DateFormat('dd MMMM yyyy', context.locale.languageCode).format(dt);
    } catch (_) {
      return raw.split(' ').first;
    }
  }

  Future<void> _openPdf() async {
    final url = invoice.uploadBill.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invoice_pdf_unavailable'.tr())),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareInvoice() async {
    final text = [
      '${"invoice_number".tr()}: #${invoice.id}',
      if (widget.clientName.isNotEmpty) '${"client".tr()}: ${widget.clientName}',
      '${"branch".tr()}: ${invoice.branchName}',
      '${"net_total".tr()}: ${_money(_net)}',
      if (invoice.uploadBill.isNotEmpty) invoice.uploadBill,
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('invoice_copied'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
            child: _buildHeader(),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: _buildMetaGrid(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildOrderDetails(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: _buildPricing(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildPaymentHistory(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: _buildStatusBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildTermsOnly(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            child: _buildActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 42,
                errorBuilder: (_, __, ___) => Text(
                  'HARVEST',
                  style: getBoldStyle(color: primaryColor, fontSize: FontSize.s16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isFullyPaid
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isFullyPaid
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Text(
                  _isFullyPaid
                      ? 'invoice_fully_paid'.tr()
                      : 'invoice_not_fully_paid'.tr(),
                  style: getBoldStyle(
                    color: _isFullyPaid
                        ? _accentGreen
                        : Colors.orange.shade800,
                    fontSize: FontSize.s12,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${"remaining".tr()}: ${_money(_remainingAmount)}',
                style: getBoldStyle(
                  color: _accentGreen,
                  fontSize: FontSize.s13,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                _QrBlock(label: 'Android', data: _playStoreUrl),
                const SizedBox(width: 8),
                _QrBlock(label: 'iOS', data: _appStoreUrl),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'invoice_number'.tr(),
              style: getBoldStyle(color: _accentGreen, fontSize: FontSize.s12),
            ),
            Text(
              '#${invoice.id}',
              style: getBoldStyle(color: primaryColor, fontSize: FontSize.s22),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatDate(invoice.createdAt),
                  style: getRegularStyle(
                      color: Colors.grey.shade700, fontSize: FontSize.s12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaGrid() {
    final paymentMethod = invoice.paymentMethod.trim().isEmpty
        ? '—'
        : invoice.paymentMethod;
    final reference = invoice.referenceNum.trim().isEmpty
        ? '—'
        : invoice.referenceNum;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MetaCell(
            icon: Icons.person_outline,
            title: 'client'.tr(),
            value: widget.clientName.isEmpty ? '—' : widget.clientName,
            subtitle: widget.clientPhone.isEmpty ? null : widget.clientPhone,
            subtitleIcon: Icons.phone_outlined,
          ),
        ),
        Expanded(
          child: _MetaCell(
            icon: Icons.location_on_outlined,
            title: 'branch'.tr(),
            value: invoice.branchName.isEmpty ? '—' : invoice.branchName,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _MetaCell(
                icon: Icons.credit_card_outlined,
                title: 'payment_method'.tr(),
                value: paymentMethod,
              ),
              const SizedBox(height: 8),
              _MetaCell(
                icon: Icons.bookmark_border,
                title: 'reference_number'.tr(),
                value: reference,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    final rows = invoice.leadPayments ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.shopping_bag_outlined,
          title: 'order_details'.tr(),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('label_course'.tr(),
                          style: getBoldStyle(
                              color: primaryColor, fontSize: FontSize.s12)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('exam_level'.tr(),
                          style: getBoldStyle(
                              color: primaryColor, fontSize: FontSize.s12)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('price_label'.tr(),
                          textAlign: TextAlign.end,
                          style: getBoldStyle(
                              color: primaryColor, fontSize: FontSize.s12)),
                    ),
                  ],
                ),
              ),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('no_data'.tr(),
                      style: getRegularStyle(
                          color: Colors.grey, fontSize: FontSize.s13)),
                )
              else
                ...rows.map((lp) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            lp.typeTitle.isEmpty ? '—' : lp.typeTitle,
                            style: getMediumStyle(
                                color: blackColors, fontSize: FontSize.s13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            lp.paymentPlan.isEmpty ? '—' : lp.paymentPlan,
                            style: getRegularStyle(
                                color: Colors.black54, fontSize: FontSize.s12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _money(double.tryParse(lp.amount) ?? 0),
                            textAlign: TextAlign.end,
                            style: getBoldStyle(
                                color: blackColors, fontSize: FontSize.s13),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricing() {
    return Column(
      children: [
        _PriceRow(label: 'total_price'.tr(), value: _money(_gross)),
        if (_discount > 0)
          _PriceRow(
            label: 'discount_label'.tr(),
            value: _money(_discount),
            valueColor: _accentGreen,
          ),
        _PriceRow(
          label: 'net_total'.tr(),
          value: _money(_net),
          valueColor: _accentGreen,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPaymentHistory() {
    final items = <SubPayment>[];
    for (final lp in invoice.leadPayments ?? []) {
      items.addAll(lp.subPayments ?? []);
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _SectionHeader(
          icon: Icons.account_balance_wallet_outlined,
          title: 'payment_history'.tr(),
        ),
        const SizedBox(height: 8),
        ...items.map((sp) {
          final paid = sp.paid == '1' || sp.paid == 'نعم';
          final date = sp.paymentDate.isNotEmpty
              ? sp.paymentDate
              : (sp.dueDate.isNotEmpty ? sp.dueDate : '');
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPaymentDetailsSheet(sp),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _money(double.tryParse(sp.amount) ?? 0),
                            style: getBoldStyle(
                                color: blackColors, fontSize: FontSize.s14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (sp.paymentMethod.trim().isNotEmpty)
                                sp.paymentMethod,
                              if (date.isNotEmpty) _formatDate(date),
                            ].join('  '),
                            style: getRegularStyle(
                                color: Colors.black54, fontSize: FontSize.s12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      paid ? Icons.check_circle : Icons.schedule,
                      size: 18,
                      color: paid ? _accentGreen : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      paid ? 'paid'.tr() : 'unpaid'.tr(),
                      style: getBoldStyle(
                        color: paid ? _accentGreen : Colors.orange.shade800,
                        fontSize: FontSize.s13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showPaymentDetailsSheet(SubPayment sp) {
    final paid = sp.paid == '1' || sp.paid == 'نعم';
    final paymentDate = sp.paymentDate.isNotEmpty ? sp.paymentDate : '';
    final dueDate = sp.dueDate.isNotEmpty ? sp.dueDate : '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'payment_details_title'.tr(),
                        style: getBoldStyle(
                            color: primaryColor, fontSize: FontSize.s16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: paid
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        paid ? 'paid'.tr() : 'unpaid'.tr(),
                        style: getBoldStyle(
                          color: paid ? _accentGreen : Colors.orange.shade800,
                          fontSize: FontSize.s12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${"invoice_number".tr()} #${invoice.id}',
                  style: getMediumStyle(
                      color: Colors.black54, fontSize: FontSize.s13),
                ),
                const Divider(height: 24),
                _sheetRow('amount'.tr(),
                    _money(double.tryParse(sp.amount) ?? 0)),
                if (sp.paymentMethod.trim().isNotEmpty)
                  _sheetRow('payment_method'.tr(), sp.paymentMethod),
                if (sp.referenceNum.trim().isNotEmpty)
                  _sheetRow('reference_number'.tr(), sp.referenceNum),
                if (paymentDate.isNotEmpty)
                  _sheetRow('payment_date'.tr(), _formatDate(paymentDate)),
                if (dueDate.isNotEmpty)
                  _sheetRow('due_date'.tr(), _formatDate(dueDate)),
                if (sp.id.toString().trim().isNotEmpty)
                  _sheetRow('number'.tr(), sp.id.toString()),
                if (sp.uploadBill.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.tryParse(sp.uploadBill.trim());
                      if (uri == null) return;
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white),
                    label: Text(
                      'download_invoice_pdf'.tr(),
                      style: getBoldStyle(
                          color: Colors.white, fontSize: FontSize.s14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('close'.tr()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: getMediumStyle(
                  color: Colors.black54, fontSize: FontSize.s13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: getBoldStyle(color: blackColors, fontSize: FontSize.s13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined, color: _accentGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  '${"total_paid".tr()}: ${_money(_totalPaid > 0 ? _totalPaid : (_isFullyPaid ? _net : 0))}',
                  style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12),
                ),
                Text(
                  '${"remaining".tr()}: ${_money(_remainingAmount)}',
                  style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12),
                ),
                Text(
                  '${"payment_status".tr()}: ${_isFullyPaid ? "invoice_fully_paid".tr() : "invoice_not_fully_paid".tr()}',
                  style: getBoldStyle(
                      color: _accentGreen, fontSize: FontSize.s12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Terms only — intentionally no "معلومات الفاتورة".
  Widget _buildTermsOnly() {
    return Column(
      children: [
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _termsOpen = !_termsOpen),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'terms_and_conditions'.tr(),
                    style: getBoldStyle(
                        color: primaryColor, fontSize: FontSize.s14),
                  ),
                ),
                Icon(
                  _termsOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (_termsOpen)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'invoice_terms_offers_title'.tr(),
                  textAlign: TextAlign.right,
                  style: getBoldStyle(
                    color: blackColors,
                    fontSize: FontSize.s13,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
                const SizedBox(height: 6),
                Text(
                  'invoice_terms_offers_body'.tr(),
                  textAlign: TextAlign.right,
                  style: getRegularStyle(
                    color: Colors.black87,
                    fontSize: FontSize.s13,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'invoice_terms_note_title'.tr(),
                  textAlign: TextAlign.right,
                  style: getBoldStyle(
                    color: const Color(0xFFB71C1C),
                    fontSize: FontSize.s13,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
                const SizedBox(height: 6),
                Text(
                  'invoice_terms_note_line1'.tr(),
                  textAlign: TextAlign.right,
                  style: getRegularStyle(
                    color: Colors.black87,
                    fontSize: FontSize.s13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'invoice_terms_note_line2'.tr(),
                  textAlign: TextAlign.right,
                  style: getRegularStyle(
                    color: Colors.black87,
                    fontSize: FontSize.s13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        SizedBox(
          width: 72,
          height: 48,
          child: OutlinedButton(
            onPressed: _shareInvoice,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_outlined, size: 18, color: primaryColor),
                Text('share'.tr(),
                    style: getMediumStyle(
                        color: primaryColor, fontSize: FontSize.s12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openPdf,
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: Text(
                'download_invoice_pdf'.tr(),
                style: getBoldStyle(color: Colors.white, fontSize: FontSize.s14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QrBlock extends StatelessWidget {
  final String label;
  final String data;
  const _QrBlock({required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=90x90&data=${Uri.encodeComponent(data)}';
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            qrUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade200,
              child: const Icon(Icons.qr_code_2, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: getMediumStyle(color: Colors.black54, fontSize: FontSize.s12)),
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final IconData? subtitleIcon;

  const _MetaCell({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.subtitleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(height: 4),
          Text(title,
              textAlign: TextAlign.center,
              style: getBoldStyle(color: primaryColor, fontSize: FontSize.s11)),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: getMediumStyle(color: blackColors, fontSize: FontSize.s12)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (subtitleIcon != null) ...[
                  Icon(subtitleIcon, size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                ],
                Flexible(
                  child: Text(subtitle!,
                      textAlign: TextAlign.center,
                      style: getRegularStyle(
                          color: Colors.black54, fontSize: FontSize.s11)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _accentGreen, size: 20),
        const SizedBox(width: 6),
        Text(title,
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s15)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? getBoldStyle(color: blackColors, fontSize: FontSize.s14)
                : getRegularStyle(color: Colors.black54, fontSize: FontSize.s13),
          ),
          Text(
            value,
            style: isBold
                ? getBoldStyle(
                    color: valueColor ?? blackColors, fontSize: FontSize.s15)
                : getBoldStyle(
                    color: valueColor ?? blackColors, fontSize: FontSize.s13),
          ),
        ],
      ),
    );
  }
}
