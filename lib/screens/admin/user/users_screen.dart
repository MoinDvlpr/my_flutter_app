import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../controllers/discount_group_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../model/usermodel.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/debouncer.dart';
import 'user_info_screen.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key});
  final userController = Get.find<UserController>();
  final discountGroupController = Get.find<DiscountGroupController>();
  final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customers')),
      backgroundColor: bg,
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
                _debouncer.run(
                  () => userController.updateSearchQuery(value.trim()),
                );
              },
              hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
              elevation: WidgetStatePropertyAll(0.0),
              side: WidgetStatePropertyAll(BorderSide(width: 1, color: grey)),
            ),
            Text(
              'All Customers',
              style: AppTextStyle.boldTextstyle.copyWith(
                fontSize: 16,
                height: 4.0,
              ),
            ),
            Expanded(
              child: PagingListener(
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, UserModel>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, user, index) {
                          return GestureDetector(
                            onTap: () async {
                              discountGroupController.clearControllers();
                              discountGroupController.clearControllers();
                              if (user.groupId != null) {
                                await discountGroupController.fetchGroupByID(
                                  groupID: user.groupId!,
                                );
                              }

                              Get.to(() => UserInfoScreen(user: user));
                            },
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: index != userController.users.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                          width: 0.6,
                                          color: grey,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: grey.withValues(
                                      alpha: 0.2,
                                    ),
                                    radius: 25,
                                    child: Icon(
                                      Icons.person,
                                      color: white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      user.userName,
                                      style: AppTextStyle.regularTextstyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                controller: userController.pagingController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
