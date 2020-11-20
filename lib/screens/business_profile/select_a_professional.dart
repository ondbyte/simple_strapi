import 'package:bapp/classes/filtered_business_staff.dart';
import 'package:bapp/classes/firebase_structures/business_timings.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/business_profile/select_time_slot.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class SelectAProfessionalScreen extends StatefulWidget {
  final Function(FilteredBusinessStaff) onSelected;

  const SelectAProfessionalScreen({Key key, this.onSelected}) : super(key: key);
  @override
  _SelectAProfessionalScreenState createState() =>
      _SelectAProfessionalScreenState();
}

class _SelectAProfessionalScreenState extends State<SelectAProfessionalScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      act(() {
        flow.timeWindow.value = FromToTiming.today();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select A Professional"),
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (flow.services.isNotEmpty)
                  RRShape(
                    child: ListTile(
                      tileColor: Theme.of(context).backgroundColor,
                      title: Text(flow.selectedTitle.value),
                      subtitle: Text(flow.selectedSubTitle.value),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                _getProffessionalsTiles()
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProffessionalsTiles() {
    return Observer(builder: (_) {
      final list = <Widget>[];

      flow.filteredStaffs.forEach(
        (s) {
          list.add(
            ListTile(
              onTap: widget.onSelected != null
                  ? () {
                      widget.onSelected(s);
                      Navigator.of(context).pop();
                    }
                  : () {
                      act(() {
                        flow.professional.value = s;
                      });
                      BappNavigator.bappPush(context, SelectTimeSlotScreen());
                    },
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              title: Text(s.staff.name),
              trailing: Icon(Icons.arrow_forward_rounded),
              leading: ListTileFirebaseImage(
                circular: true,
                storagePathOrURL: s.staff.images.isNotEmpty
                    ? s.staff.images.keys.elementAt(0)
                    : kTemporaryPlaceHolderImage,
              ),
              subtitle: RatingBar.builder(
                  itemSize: 16,
                  itemBuilder: (_, __) {
                    return Icon(
                      FeatherIcons.star,
                    );
                  },
                  allowHalfRating: true,
                  ignoreGestures: true,
                  initialRating: s.staff.rating,
                  maxRating: 5,
                  onRatingUpdate: (_) {}),
            ),
          );
        },
      );
      if (flow.filteredStaffs.isEmpty) {
        return SizedBox();
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      );
    });
  }

  BookingFlow get flow => Provider.of<BookingFlow>(context, listen: false);
}
