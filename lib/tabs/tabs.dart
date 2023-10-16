import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:timebrew/tabs/tags.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'timer.dart';
import '../popups/create_tag.dart';
import '../popups/create_task.dart';

class TabEntry {
  String title;
  IconData icon;
  TabEntry({required this.title, required this.icon});
}

enum Dialog { tag, task }

class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
  });

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  late TabController _tcontroller;
  String currentTitle = "";

  List<TabEntry> tabs = [
    TabEntry(title: 'Timer', icon: Icons.hourglass_bottom_rounded),
    TabEntry(title: 'Logs', icon: Icons.history_rounded),
    TabEntry(title: 'Tasks', icon: Icons.checklist_rounded),
    TabEntry(title: 'Tags', icon: Icons.tag_rounded),
    TabEntry(title: 'Stats', icon: Icons.analytics_rounded),
  ];

  @override
  void initState() {
    currentTitle = tabs[0].title;
    _tcontroller = TabController(length: 5, vsync: this);
    _tcontroller.addListener(changeTitle); // Registering listener
    super.initState();
  }

  // This function is called, every time active tab is changed
  void changeTitle() {
    setState(() {
      // get index of active tab & change current appbar title
      currentTitle = tabs[_tcontroller.index].title;
    });
  }

  void _showAction(BuildContext context, Dialog dialog) {
    showDialog<void>(
      context: context,
      builder: (context) {
        switch (dialog) {
          case Dialog.tag:
            return const CreateTagDialog();
          case Dialog.task:
            return const CreateTaskDialog();
        }
      },
    );
  }

  TabBar buildTabBar(BuildContext context) {
    List<Tab> tabWidgets = [];
    bool minimal = MediaQuery.of(context).size.width < 550;

    for (TabEntry tab in tabs) {
      tabWidgets.add(
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tab.icon),
              ...(minimal
                  ? []
                  : [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(tab.title)
                    ]),
            ],
          ),
        ),
      );
    }

    return TabBar(
      controller: _tcontroller,
      splashBorderRadius: BorderRadius.circular(50),
      indicator: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(50),
      ),
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: tabWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentTitle),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Settings'),
                ),
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Send feedback'),
                ),
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Help'),
                ),
              ],
            )
          ],
          bottom: PreferredSize(
            preferredSize: buildTabBar(context).preferredSize,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: buildTabBar(context),
            ),
          ),
        ),
        body: TabBarView(
          dragStartBehavior: DragStartBehavior.down,
          controller: _tcontroller,
          children: const [
            Center(child: Timer()),
            Tab(icon: Icon(Icons.history_rounded)),
            Tasks(),
            Tags(),
            Tab(icon: Icon(Icons.analytics_rounded)),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            if (currentTitle != 'Timer' && currentTitle != 'Stats') {
              return FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onPressed: () {
                  switch (currentTitle) {
                    case 'Tasks':
                      _showAction(context, Dialog.task);
                      break;
                    case 'Tags':
                      _showAction(context, Dialog.tag);
                      break;
                  }
                },
                label: Text(
                    'Add ${currentTitle.substring(0, currentTitle.length - 1)}'),
                icon: const Icon(Icons.add_rounded),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}