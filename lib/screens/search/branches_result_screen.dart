import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business/business_profile/business_profile.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
class BranchesResultScreen extends StatefulWidget {
  final Future<List<BusinessBranch>> futureBranchList;
  final String title, subTitle, placeName, categoryName, categoryImage;

  const BranchesResultScreen(
      {Key key,
      this.futureBranchList,
      this.title,
      this.subTitle,
      this.placeName,
      this.categoryName,
      this.categoryImage
      })
      : super(key: key);
  @override
  _BranchesResultScreenState createState() => _BranchesResultScreenState();
}

class _BranchesResultScreenState extends State<BranchesResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).accentColor,
            expandedHeight: 120,
            brightness: Brightness.dark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height:100,
                decoration: BoxDecoration(
                  image:widget.categoryImage != null ? DecorationImage(image: CachedNetworkImageProvider(widget.categoryImage), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply)):null
                  
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${widget.title}s",
                      style: Theme.of(context).textTheme.headline1.apply(
                            color: Colors.white,
                          ),
                    ),
                    
                    Text(
                      widget.subTitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .apply(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FutureBuilder<List<BusinessBranch>>(
                  future: widget.futureBranchList,
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const LinearProgressIndicator();
                    }
                    return snap.data.isNotEmpty
                        ? ListView.builder(
                          padding: EdgeInsets.fromLTRB(0,16,0,0),
                            shrinkWrap: true,
                            itemCount: snap.data.length,
                            itemBuilder: (_, i) {
                              return BusinessTileWidget(
                                titleStyle: Theme.of(context).textTheme.subtitle1,
                                withImage: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                branch: snap.data[i],
                              
                                onTap: () async {
                                  flow.branch = snap.data[i];
                                  BappNavigator.push(
                                    context,
                                    BusinessProfileScreen(),
                                  );
                                },
                              );
                            },
                          )
                        : ContextualMessageScreen(
                            interactive: false,
                            svgAssetToDisplay: "assets/svg/empty-list.svg",
                            message: "There are no " +
                                widget.categoryName +
                                " in " +
                                widget.placeName +
                                ", We are adding more local businesses to serve you better.",
                          );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
