import 'package:flutter/material.dart';
import 'package:mobile_app/balance/balance_page.dart';
import 'package:mobile_app/common/blocs/config_bloc.dart';
import 'package:mobile_app/common/pages/receive_page.dart';
import 'package:mobile_app/common/pages/send_page.dart';
import 'package:mobile_app/routes.dart';

class FinancePage extends StatefulWidget {
  static IconData icon = Icons.all_inclusive;
  static String appBarText = "Finances";

  @override
  _FinancePageState createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  int _bottomNavbarIndex = 0;
  BottomNavbarPagesFin _page = BottomNavbarPagesFin.balance;
  List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(
        title: const Text("Balance"),
        icon: const Icon(Icons.account_balance_wallet)),
    BottomNavigationBarItem(
        title: const Text("Send"), icon: const Icon(Icons.send)),
    BottomNavigationBarItem(
        title: const Text("Receive"), icon: const Icon(Icons.get_app))
  ];

  void nav(int index) {
    setState(() {
      _bottomNavbarIndex = index;
      switch (index) {
        case 0:
          _page = BottomNavbarPagesFin.balance;
          break;
        case 1:
          _page = BottomNavbarPagesFin.send;
          break;
        case 2:
          _page = BottomNavbarPagesFin.receive;
          break;
        default:
          _page = BottomNavbarPagesFin.balance;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_page) {
      case BottomNavbarPagesFin.balance:
        body = BalancesPage(ConfigurationBloc().config.testnet);
        break;
      case BottomNavbarPagesFin.send:
        body = SendPage();
        break;
      case BottomNavbarPagesFin.receive:
        body = ReceivePage();
        break;
      default:
        body = Center(child: Text("implement me $_page"));
    }
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavbarIndex,
        onTap: nav,
        items: navItems,
      ),
    );
  }
}
