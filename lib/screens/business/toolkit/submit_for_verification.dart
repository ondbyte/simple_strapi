import 'dart:io';

import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/tiles/add_image_sliver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessSubmitBranchForVerificationScreen extends StatefulWidget {
  BusinessSubmitBranchForVerificationScreen({Key key}) : super(key: key);

  @override
  _BusinessSubmitBranchForVerificationScreenState createState() =>
      _BusinessSubmitBranchForVerificationScreenState();
}

class _BusinessSubmitBranchForVerificationScreenState
    extends State<BusinessSubmitBranchForVerificationScreen> {
  final Map<String, bool> _businessDocs = {};
  final Map<String, bool> _ownerDoc = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
        ),
        body: Consumer<BusinessStore>(
          builder: (_, businessStore, __) {
            return LoadingStackWidget(
              child: isNotShowable(businessStore)
                  ? ContextualMessageScreen(
                      buttonText: "Go back",
                      init: () {},
                      message:
                          "Your selected branch is disabled or in process of verification",
                      onButtonPressed: (context) {
                        Navigator.pop(context);
                      },
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              PaddedText(
                                "Ready to recieve bookings?",
                                style: Theme.of(context).textTheme.headline1,
                              ),
                              PaddedText(
                                "We verify business before customers could see them, Send us below documents.",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Divider(),
                              AddImageTileWidget(
                                maxImage: 4,
                                title: "Photos of incorporation",
                                subTitle:
                                    "Photo of trade license or establishment ID",
                                onImagesSelected: (images) {
                                  _businessDocs.addAll(images);
                                },
                              ),
                              Divider(),
                              AddImageTileWidget(
                                maxImage: 2,
                                title: "Owner\'s ID",
                                subTitle: "Both sides of the owner\'s ID card",
                                onImagesSelected: (images) {
                                  _ownerDoc.addAll(images);
                                },
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Terms of service"),
                                subtitle: Text(
                                  "Make sure you are aware of the terms of our service.",
                                ),
                                onTap: () {
                                  launch(kTerms);
                                },
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Privacy Policy"),
                                subtitle: Text(
                                  "Read the privacy policy here.",
                                ),
                                onTap: () {
                                  launch(kPrivacy);
                                },
                              ),
                              Divider(),
                              PaddedText(
                                "By clicking submit, you are agreeing to our terms of service and privacy policy.",
                                style: Theme.of(context).textTheme.caption,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: PrimaryButton(
                                  "Verify & Publish",
                                  onPressed: () {
                                    _apply();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          },
        ));
  }

  bool isNotShowable(BusinessStore businessStore) {
    return businessStore.business.selectedBranch.value.status.value ==
            BusinessBranchActiveStatus.documentVerification ||
        businessStore.business.selectedBranch.value.status.value ==
            BusinessBranchActiveStatus.published ||
        businessStore.business.selectedBranch.value.status.value ==
            BusinessBranchActiveStatus.unPublished;
  }

  _apply() async {
    act(() {
      kLoading.value = true;
    });
    final pdf = pw.Document();
    final business =
        Provider.of<BusinessStore>(context, listen: false).business;
    final branch = business.selectedBranch.value;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "business name: " + business.businessName.value,
                  style: pw.TextStyle(
                    fontSize: 22,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "business main address :" + business.address.value,
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch name :" + branch.name.value,
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch address :" + branch.address.value,
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "business contact :" + business.contactNumber.value,
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "business email :" + business.email.value,
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch contact :" + branch.contactNumber.value,
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch email :" + branch.email.value,
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final pdfImages = <PdfImage>[];

    await Future.forEach(_businessDocs.keys, (key) async {
      final bytes = await File(removeLocalFromPath(key)).readAsBytes();
      pdfImages.add(PdfImage.file(pdf.document, bytes: bytes));
    });

    await Future.forEach(_ownerDoc.keys, (key) async {
      final bytes = await File(removeLocalFromPath(key)).readAsBytes();
      pdfImages.add(PdfImage.file(pdf.document, bytes: bytes));
    });

    pdfImages.forEach(
      (element) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(element),
              );
            },
          ),
        );
      },
    );

    final path = await getTemporaryDirectory();
    final fileName = DateTime.now().toIso8601String() + ".pdf";

    final theFileToUpload = await File(path.absolute.path + "/" + fileName)
        .writeAsBytes(pdf.save());

    await uploadBusinessBranchApprovalPDF(fileToUpload: theFileToUpload);

    Navigator.of(context)
        .popAndPushNamed(RouteManager.contextualMessage, arguments: [
      () {
        act(
          () {
            final business =
                Provider.of<BusinessStore>(context, listen: false).business;
            final branch = business.branches.value.firstWhere((element) =>
                business.selectedBranch.value.myDoc == element.myDoc);
            branch.status.value =
                BusinessBranchActiveStatus.documentVerification;
            business.selectedBranch.value = branch;
          },
        );
      },
      "Thank you for sending the documents, we will contact you on your registered number to update you the status."
    ]);
    act(() {
      kLoading.value = true;
    });
  }
}
