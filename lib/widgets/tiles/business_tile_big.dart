import 'package:bapp/config/constants.dart';
import 'package:bapp/stores/firebase_structures/business_branch.dart';
import 'package:flutter/material.dart';

import '../firebase_image.dart';

class BusinessTileBigWidget extends StatelessWidget {
  final BusinessBranch branch;
  final Widget tag;
  final Function onTap;

  const BusinessTileBigWidget({Key key, this.branch,@required this.tag, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, cons) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: cons.maxWidth,
              height: cons.maxWidth*(9/16),
              child: AspectRatio(
                aspectRatio: 9/16,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    FirebaseStorageImage(
                      storagePathOrURL: branch.images.isNotEmpty
                          ? branch.images.keys.elementAt(0)
                          : kTemporaryBusinessImage,
                    ),
                    Padding(padding: const EdgeInsets.only(left: 16,bottom: 8),child: tag,)
                  ],
                ),
              ),
            ),
            BusinessTileWidget(branch: branch,onTap: (){},padding: const EdgeInsets.symmetric(vertical: 8),),
          ],
        ),
      );
    });
  }
}

class BusinessTileWidget extends StatelessWidget {
   final BusinessBranch branch;
  final Function onTap;
  final EdgeInsets padding;

  const BusinessTileWidget({Key key, @required this.branch, @required this.onTap, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: padding??EdgeInsets.zero,
      title: Text(
        branch.name.value,
        maxLines: 1,
      ),
      subtitle: Text(
        branch.address.value,
        maxLines: 1,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star,color: Colors.yellow[500],),
          const SizedBox(
            height: 2,
          ),
          Text(
            branch.rating.value.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
    );
  }
}

