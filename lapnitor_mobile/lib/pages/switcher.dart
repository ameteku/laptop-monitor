import 'package:flutter/material.dart';
import 'package:lapnitor_mobile/pages/scanPage.dart';
import 'package:lapnitor_mobile/services/databaseService.dart';
import "package:provider/provider.dart";

import 'feedPage.dart';

class PageDelegator extends StatefulWidget {
  const PageDelegator({Key? key}) : super(key: key);

  @override
  _PageDelegatorState createState() => _PageDelegatorState();
}

class _PageDelegatorState extends State<PageDelegator> {
  @override
  late FeedPage _feedPage;
  late ScanPage _scanPage;
  late Pages currentPage = Pages.scanPage;
  late DatabaseService db;

  @override
  void initState() {
    super.initState();
    _feedPage = FeedPage(
      onSwitchPage: togglePage,
    );
    _scanPage = ScanPage(
      onSwitchPage: togglePage,
    );
    db = DatabaseService();
  }

  Widget build(BuildContext context) {
    return Provider(
      create: (BuildContext context) => db,
      builder: (context, child) => Scaffold(
        body: getCurrentPage(currentPage),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Activity',
              activeIcon: Icon(Icons.home_filled),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2),
              label: "Connect",
              activeIcon: Icon(Icons.qr_code_2_outlined),
            )
          ],
          onTap: (index) {
            setState(() {
              currentPage = Pages.values[index];
            });
          },
          currentIndex: currentPage.index,
        ),
      ),
    );
  }

  Widget getCurrentPage(Pages currentPage) {
    switch (currentPage) {
      case Pages.feedPage:
        return _feedPage;
      case Pages.scanPage:
        return _scanPage;
      default:
        return _feedPage;
    }
  }

  void togglePage(Pages toPage) {
    setState(() {
      currentPage = toPage;
    });
  }
}

enum Pages { feedPage, scanPage }
