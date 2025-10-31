import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../utils/app_textstyles.dart';

class CustomSearchDropdown<T> extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  final RxBool isLoading;
  final String Function(T) itemLabel;
  final Function(T) onItemSelected;
  final void Function(String)? onSearch;
  final PagingController<int, T> pagingController;
  const CustomSearchDropdown({
    super.key,
    required this.title,
    required this.isLoading,
    required this.itemLabel,
    required this.onItemSelected,
    required this.searchController,
    this.onSearch,
    required this.pagingController,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SearchBar(
              controller: searchController,
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
              hintText: 'Search $title',
              onChanged: (value) async {
                if (onSearch != null) {
                  onSearch!(value);
                  // await fetchItems(isInitial: true);
                }
              },
              hintStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
              elevation: const WidgetStatePropertyAll(0.0),
              side: const WidgetStatePropertyAll(
                BorderSide(width: 1, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PagingListener(
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, T>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) => GestureDetector(
                          onTap: () {
                            onItemSelected(item);
                            Get.back(); // Close dropdown
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    itemLabel(item),
                                    style: AppTextStyle.regularTextstyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                controller: pagingController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
