import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/business_profile/business_profile.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/tiles/business_tile_big.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BranchesResultScreen extends StatefulWidget {
  final Future<List<BusinessBranch>> futureBranchList;
  final String title, subTitle;

  const BranchesResultScreen(
      {Key key, this.futureBranchList, this.title, this.subTitle})
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
            backgroundColor: Colors.black,
            expandedHeight: 256,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox(
                height: 256,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headline1.apply(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      widget.subTitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .apply(color: Colors.white),
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
                      return LinearProgressIndicator();
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snap.hasData ? snap.data.length : 0,
                      itemBuilder: (_, i) {
                        return BusinessTileWidget(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          branch: snap.data[i],
                          onTap: () async {
                            flow.branch = snap.data[i];
                            BappNavigator.bappPush(
                                context, BusinessProfileScreen());
                          },
                        );
                      },
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
