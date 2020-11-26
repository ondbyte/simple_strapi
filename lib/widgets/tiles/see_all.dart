import 'package:flutter/material.dart';

class SeeAllListTile extends StatelessWidget {
  final String title,subTitle,seeAllLabel;
  final Function onSeeAll;
  final EdgeInsets padding;

  const SeeAllListTile({Key key, this.title="", this.subTitle="", this.seeAllLabel, this.onSeeAll, this.padding}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding?? const EdgeInsets.only(left: 16,right: 16, top: 10, bottom: 5),
      title: Text(title,style: Theme.of(context).textTheme.headline6),
      trailing: GestureDetector(
        child: Text(seeAllLabel??"See all",style: TextStyle(color: Theme.of(context).primaryColor),),
        onTap: onSeeAll,
      ),
    );
  }
}
