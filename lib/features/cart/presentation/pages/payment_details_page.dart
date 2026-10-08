import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:provider/provider.dart';

class PaymentDetails extends StatefulWidget {
  final int id;
  const PaymentDetails({super.key, required this.id});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  @override
  void initState() {
    super.initState();
    // Call fetch here
    Future.microtask(() {
      Provider.of<CartViewModel>(context, listen: false)
          .getPaymentDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text("my_payments_title".tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20)),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/bottomNav'),

            // onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 30.0),
                child: Consumer<CartViewModel>(
                  builder: (context, vm, child) {
                    if (vm.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (vm.errorMessage != null) {
                      return Center(child: Text(vm.errorMessage!));
                    }
                    if (vm.paymentData == null) {
                      return const Center(child: Text("No data found"));
                    }

                    final data = vm.paymentData!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.payments.length,
                      itemBuilder: (context, index) {
                        final payment = data.payments[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20.0),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRow("number".tr(), payment.id.toString()),
                                if (payment.discount.isNotEmpty)
                                  _buildRow("discount_label".tr(), payment.discount),
                                if (payment.amount.isNotEmpty)
                                  _buildRow("total_label".tr(), payment.amount),
                                if (payment.subPayments.isNotEmpty)
                                  _buildRow("total_items".tr(),
                                      payment.subPayments.length.toString()),
                                if (payment.subPayments.isNotEmpty) ...[
                                  const Divider(),
                                  ...payment.subPayments
                                      .asMap()
                                      .entries
                                      .expand((entry) {
                                    final index = entry.key;
                                    final sub = entry.value;

                                    final item = Column(
                                      children: [
                                        if (sub.id.toString().isNotEmpty)
                                          _buildRow("number".tr(), sub.id.toString()),
                                        if (sub.amount.isNotEmpty)
                                          _buildRow("price_label".tr(), sub.amount),
                                        if (sub.paymentMethod != null &&
                                            sub.paymentMethod is String &&
                                            (sub.paymentMethod as String)
                                                .isNotEmpty)
                                          _buildRow("payment_method".tr(),
                                              sub.paymentMethod as String),
                                        if (sub.referenceNum != null &&
                                            sub.referenceNum is String &&
                                            (sub.referenceNum as String)
                                                .isNotEmpty)
                                          _buildRow("ref_number".tr(),
                                              sub.referenceNum as String),
                                        if (sub.paid.isNotEmpty)
                                          _buildRow("paid_status".tr(), sub.paid),
                                        if (sub.paymentDate != null)
                                          _buildRow(
                                            "payment_date".tr(),
                                            sub.paymentDate!
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                          ),
                                      ],
                                    );

                                    // Add divider except after last item
                                    return [
                                      item,
                                      if (index !=
                                          payment.subPayments.length - 1)
                                        const Divider(thickness: 1, height: 20),
                                    ];
                                  }).toList(),

                                  // ...payment.subPayments.map((sub) {
                                  //   return Column(
                                  //     children: [
                                  //       if (sub.id.toString().isNotEmpty)
                                  //         _buildRow("رقم", sub.id.toString()),
                                  //       if (sub.amount.isNotEmpty)
                                  //         _buildRow("السعر", sub.amount),
                                  //       if (sub.paymentMethod != null &&
                                  //           sub.paymentMethod is String &&
                                  //           (sub.paymentMethod as String)
                                  //               .isNotEmpty)
                                  //         _buildRow("طريقة الدفع",
                                  //             sub.paymentMethod as String),
                                  //       if (sub.referenceNum != null &&
                                  //           sub.referenceNum is String &&
                                  //           (sub.referenceNum as String)
                                  //               .isNotEmpty)
                                  //         _buildRow("طريقة الدفع",
                                  //             sub.referenceNum as String),
                                  //       if (sub.paid.isNotEmpty)
                                  //         _buildRow("تم دفع", sub.paid),
                                  //       if (sub.paymentDate != null)
                                  //         _buildRow(
                                  //           "تاريخ الدفع",
                                  //           sub.paymentDate!
                                  //               .toLocal()
                                  //               .toString()
                                  //               .split(' ')[0],
                                  //         ),
                                  //     ],
                                  //   );
                                  // }).toList(),
                                ] else
                                  const Text("No sub-payments"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: getBoldStyle(color: blackColors, fontSize: FontSize.s20)),
          Text(value,
              style: getRegularStyle(color: grey, fontSize: FontSize.s20)),
        ],
      ),
    );
  }
}
