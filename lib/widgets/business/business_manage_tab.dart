import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BusinessManageTab extends StatefulWidget {
  @override
  _BusinessManageTabState createState() => _BusinessManageTabState();
}

class _BusinessManageTabState extends State<BusinessManageTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _getAppBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAppBar() {
    return Consumer<CloudStore>(builder: (_, cloudStore, __) {
      return SliverAppBar(
        automaticallyImplyLeading: false,
      );
    });
  }
}
