import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:flutter/material.dart';

import '../firebase_image.dart';

class BusinessTileBigWidget extends StatelessWidget {
  final BusinessBranch branch;
  final Widget tag;

  const BusinessTileBigWidget({Key key, this.branch, this.tag})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Stack(
              children: [
                FirebaseStorageImage(
                  storagePathOrURL: branch.images.isNotEmpty
                      ? branch.images.keys.elementAt(0)
                      : kTemporaryBusinessImage,
                ),
                tag
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            title: Text(
              branch.name.value,
              maxLines: 1,
            ),
            subtitle: Text(
              branch.address.value,
              maxLines: 1,
            ),
            trailing: Column(
              children: [
                Icon(Icons.star),
                SizedBox(
                  height: 2,
                ),
                Text(
                  branch.rating.value.toString(),
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}
