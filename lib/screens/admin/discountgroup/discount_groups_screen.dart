import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/discount_group_controller.dart';
import '../../../model/discount_group_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/confirm_dialog.dart';
import 'add_edit_descount_group.dart';

class DiscountGroupsScreen extends StatelessWidget {
  DiscountGroupsScreen({super.key});
  final DiscountGroupController discountGroupController = Get.put(
    DiscountGroupController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text('Discount groups')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          discountGroupController.clearControllers();
          Get.to(() => AddEditDiscountGroup());
        },
        shape: CircleBorder(),
        backgroundColor: primary,
        child: Icon(Icons.add, color: white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              backgroundColor: WidgetStatePropertyAll(bg),
              hintText: 'Search',
              onChanged: (value) async {
                discountGroupController.searchQuery = value.trim();
                // discountGroupController.fetchAllGroups(isInitial: true);

                // await discountGroupController.fetchAllGroups(isInitial: true);
              },
              hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
              elevation: WidgetStatePropertyAll(0.0),
              side: WidgetStatePropertyAll(BorderSide(width: 1, color: grey)),
            ),
            Text(
              'All groups',
              style: AppTextStyle.boldTextstyle.copyWith(
                fontSize: 16,
                height: 4.0,
              ),
            ),
            Expanded(
              child: PagingListener(
                controller: discountGroupController.pagingController,
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, DiscountGroupModel>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, group, index) => Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border:
                                index !=
                                    discountGroupController.groups.length - 1
                                ? Border(
                                    bottom: BorderSide(width: 0.6, color: grey),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.groupName,
                                  style: AppTextStyle.regularTextstyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  Get.to(
                                    () => AddEditDiscountGroup(
                                      groupID: group.groupId!,
                                    ),
                                  );

                                  await discountGroupController.fetchGroupByID(
                                    groupID: group.groupId!,
                                  );
                                },
                                icon: Icon(Icons.edit, color: grey),
                                tooltip: 'edit',
                              ),
                              IconButton(
                                onPressed: () async {
                                  showDeleteConfirmationDialog(
                                    title: 'Delete group',
                                    message: 'Are you sure ?',
                                    onConfirm: () async {
                                      if (group.groupId != null) {
                                        await discountGroupController
                                            .deleteGroup(
                                              id: group.groupId!,
                                              index: index,
                                            );
                                      }
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.delete_outlined,
                                  color: primary,
                                ),
                                tooltip: 'delete',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
