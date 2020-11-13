import 'package:bapp/stores/booking_flow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectAProfessionalScreen extends StatefulWidget {
  @override
  _SelectAProfessionalScreenState createState() => _SelectAProfessionalScreenState();
}

class _SelectAProfessionalScreenState extends State<SelectAProfessionalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select A Professional"),
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildListDelegate(
            [
              if(flow.services.isNotEmpty)ListTile(
                title: Text(flow.selectedTitle.value),
                subtitle: Text(flow.selectedSubTitle.value),
              ),
              ..._getProffessionalsTiles()
            ]
          ),),
        ],
      ),
    );
  }

  List<Widget> _getProffessionalsTiles(){
    final list = <Widget>[];
    flow.branch.staff.for
  }

  BookingFlow get flow=>Provider.of<BookingFlow>(context,listen: false);
}
