import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:provider/provider.dart';

class RunningGroupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final groupVM = Provider.of<ProfileViewModel>(context);

    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..fetchGroups(1),
      child: Scaffold(
        appBar: AppBar(title: Text("groups".tr())),
        body: Stack(
          children: [
            Consumer<ProfileViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (viewModel.groups.isEmpty) {
                  return Center(child: Text("no_running_groups".tr()));
                }

                return ListView.builder(
                  itemCount: viewModel.groups.length,
                  itemBuilder: (context, index) {
                    final group = viewModel.groups[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _RowWidget("group_code".tr(), text2: group.code),
                              _RowWidget("group_days".tr(), text2: group.days),
                              _RowWidget("group_room".tr(),
                                  text2: "${"group_room".tr()} ${group.room}"),
                              _RowWidget("group_branch".tr(),
                                  text2: group.branch),
                              _RowWidget("group_teacher".tr(),
                                  text2: group.instructor),
                              _RowWidget("group_time".tr(), text2: group.time),
                              // _RowWidget("المستوى", text2: group.levels),
                              _RowWidget("group_start".tr(),
                                  text2: group.start),
                              _RowWidget("group_end".tr(), text2: group.end),
                              _RowWidget(
                                "join_group".tr(),
                                text2: "join".tr(),
                                color: darkGreen,
                                onTap2: () async {
                                  final success = await groupVM.joinGroup(
                                      groupId: group.id.toString());

                                  if (success) {
                                    showAwesomeSnackBar(
                                      // context: context,
                                      title: "Success!",
                                      message: "join_group_success".tr(),
                                      type: SnackbarType.success,
                                    );
                                  } else {
                                    showAwesomeSnackBar(
                                      // context: context,
                                      title: "Success!",
                                      message: "join_group_failed".tr(),
                                      type: SnackbarType.error,
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _RowWidget(
    String text, {
    String? text2,
    String? text3,
    Color? color,
    TextStyle? text2Style,
    TextStyle? text3Style,
    VoidCallback? onTap2,
    VoidCallback? onTap3,
  }) {
    final effectiveColor = color ?? grey;

    Widget buildTextOrButton(
        String? text, TextStyle? style, VoidCallback? onTap) {
      if (text == null) return SizedBox.shrink();
      final baseStyle = style ??
          getRegularStyle(
            color: effectiveColor,
            fontSize: FontSize.s20,
          );
      return onTap != null
          ? TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                text,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    decorationColor: darkGreen,
                    fontFamily: FontConstants.fontFamily,
                    fontSize: FontSize.s18),
              ),
            )
          : Text(text, style: baseStyle);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: getBoldStyle(color: grey, fontSize: FontSize.s20),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text2 != null) buildTextOrButton(text2, text2Style, onTap2),
              if (text3 != null) ...[
                const SizedBox(width: 8),
                buildTextOrButton(text3, text3Style, onTap3),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
