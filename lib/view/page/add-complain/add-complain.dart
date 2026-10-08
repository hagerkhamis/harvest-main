import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/model/inquiry_viewmodel.dart';
import 'package:hatvest/shared/widgets/custom%D9%80dropdown_custom.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';

class AddComplain extends StatefulWidget {
  final List<LabelType> labelTypes;

  const AddComplain({super.key, required this.labelTypes});

  @override
  State<AddComplain> createState() => _AddComplainState();
}

class _AddComplainState extends State<AddComplain> {
  List<LabelType> selected = [];
  final _inquiriesText = TextEditingController();

  String? selectedFileName;
  File? selectedFile;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      if (!mounted) return; // ✅ safety
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "add_complaint".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
          ),
        ],
      ),
      body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            child: Column(
              children: [
                CustomDropdownButtonFormFieldCustom<LabelType>(
                  initialValues: selected,
                  hintText: "choose_complaint_type".tr(),
                  items: widget.labelTypes,
                  itemToString: (label) => label.name,
                  onChanged: (newSelectedList) {
                    if (!mounted) return; // ✅ avoid setState on dispose
                    setState(() {
                      selected = newSelectedList;
                    });
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  controller: _inquiriesText,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "your_message".tr(),
                    filled: true,
                    fillColor: whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // file selector
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: grey),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            selectedFileName ?? "no_file_selected".tr(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _selectFile,
                        child: Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                            color: dividerColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: grey),
                          ),
                          child: Center(
                            child: Text(
                              "choose_file".tr(),
                              style: getMediumStyle(color: grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // ✅ Button with ViewModel loader
                Consumer<ProfileViewModel>(
                  builder: (context, viewModel, _) {
                    return CustomButtons(
                      text: viewModel.isLoading
                          ? "sending".tr()
                          : "add_inquiry".tr(),
                      isLoading: viewModel.isLoading,
                      onTap: viewModel.isLoading
                          ? null
                          : () async {
                              if (selected.isEmpty ||
                                  _inquiriesText.text.trim().isEmpty) {
                                if (!mounted) return;
                                showAwesomeSnackBar(
                                  title: "Error!",
                                  message: 'يرجى تعبئة جميع الحقول',
                                  type: SnackbarType.info,
                                );
                                return;
                              }

                              final success = await viewModel.submitComplain(
                                labelId: selected.first.id,
                                message: _inquiriesText.text.trim(),
                                file: selectedFile,
                                displayName: selectedFileName ?? "",
                              );

                              if (!mounted) return; // ✅ safety

                              if (success) {
                                showAwesomeSnackBar(
                                  title: "Success",
                                  message: 'تم إرسال الاستفسار بنجاح',
                                  type: SnackbarType.success,
                                );
                                await Future.delayed(
                                    const Duration(milliseconds: 300));
                                if (mounted) Navigator.pop(context);
                              } else {
                                showAwesomeSnackBar(
                                  title: "خطأ",
                                  message: 'فشل إرسال الاستفسار',
                                  type: SnackbarType.error,
                                );
                              }
                            },
                    );
                  },
                ),
              ],
            ),
      ),
    );
  }
}
