import 'package:bapp/route_manager.dart';
import 'package:flutter/material.dart';

class BusinessProductsPricingScreen extends StatefulWidget {
  @override
  _BusinessProductsPricingScreenState createState() =>
      _BusinessProductsPricingScreenState();
}

class _BusinessProductsPricingScreenState
    extends State<BusinessProductsPricingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add,color: Theme.of(context).primaryColorLight,),
          onPressed: (){
            final selected = DefaultTabController.of(context).index;
            if(selected==0){
              Navigator.of(context).pushNamed(RouteManager.businessAddAServiceScreen);
            } else
            if(selected==1){
              Navigator.of(context).pushNamed(RouteManager.businessAddAServiceCategoryScreen);
            }
          },
        ),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Manage services"),
          bottom: TabBar(
            indicator: UnderlineTabIndicator(),
            labelColor: Theme.of(context).primaryColor,
            tabs: [
              Text("Services"),
              Text("Categories"),
            ],
          ),
        ),
        body: Builder(
          builder: (_){

            return TabBarView(
              children: [
                _getServices(context),
                _getCategories(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _getServices(BuildContext context,) {
    return CustomScrollView(
      slivers: [],
    );
  }

  Widget _getCategories(BuildContext context) {
    return CustomScrollView(
      slivers: [],
    );
  }
}
