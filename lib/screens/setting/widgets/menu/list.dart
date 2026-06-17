import 'package:flutter/material.dart';

import '../../../../data/menu.dart';
import '../common/section.dart';
import 'dialog.dart';

class MenuList extends StatelessWidget {
  const MenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: globalMenuItemsNotifier,
      builder: (context, menuItems, child) {
        return SettingCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(menuItems.length, (index) {
              final item = menuItems[index];
              final volumeStr = item['volume'].toString();
              final abvValue = item['abv'] as double;
              final abvStr = abvValue == abvValue.toInt()
                  ? abvValue.toInt().toString()
                  : abvValue.toString();

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    title: Text(
                      item['name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      '${volumeStr}ml ・ $abvStr%',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: const Color(0xFF6B7280),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddMenuDialog(
                                editIndex: index,
                                initialItem: item,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: const Color(0xFF6B7280),
                          onPressed: () {
                            final newList = List<Map<String, dynamic>>.from(
                              globalMenuItemsNotifier.value,
                            );
                            newList.removeAt(index);
                            saveMenuItems(newList);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (index != menuItems.length - 1)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFE5E7EB),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
