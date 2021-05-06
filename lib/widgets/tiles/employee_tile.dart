import 'package:bapp/super_strapi/my_strapi/x_widgets/x_widgets.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/firebase_image.dart';
import 'package:bapp/widgets/tiles/rr_list_tile.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class EmployeeTile extends StatelessWidget {
  final bool enabled;
  final Employee employee;
  const EmployeeTile({
    Key? key,
    required this.employee,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ListTile(
        onTap: enabled
            ? () {
                BappNavigator.pop(context, employee);
              }
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
        title: Text(employee.name!),
        trailing: Icon(Icons.arrow_forward_rounded),
        leading: LayoutBuilder(
          builder: (_, cons) {
            return SizedBox(
              width: cons.maxWidth * 0.2,
              child: RRShape(
                child: StrapiListTileImageWidget(
                  placeHolder: Initial(
                    forName: employee.name!,
                  ),
                  file: employee.image?.first,
                ),
              ),
            );
          },
        ),
        subtitle: RatingBar.builder(
          itemSize: 16,
          itemBuilder: (_, __) {
            return Icon(
              FeatherIcons.star,
              color: Colors.amber,
            );
          },
          allowHalfRating: true,
          ignoreGestures: true,
          initialRating: employee.starRating ?? 0,
          maxRating: 5,
          onRatingUpdate: (_) {},
        ),
      ),
    );
  }
}
