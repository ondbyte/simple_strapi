import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          slivers: [_getAppBar()],
        ),
      ),
    );
  }

  Widget _getAppBar() {
    return Consumer<BusinessStore>(
      builder: (_, businessStore, __) {
        return SliverAppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SizedBox(),
        );
      },
    );
  }

  Widget _getImageGallery(List<String> urls){
    return PageView(
      children: [
        ...List.generate(urls.length, (index) =>
        CachedNetworkImage(
          imageUrl: urls[index],
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          placeholder: (_,s){
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),),
      ],
    );
  }
}
