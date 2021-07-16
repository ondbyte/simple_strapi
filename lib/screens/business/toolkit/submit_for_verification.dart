import 'dart:io';
import 'dart:typed_data';

import 'package:bapp/classes/firebase_structures/business_branch.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/widgets/buttons.dart';
import 'package:bapp/widgets/loading_stack.dart';
import 'package:bapp/widgets/padded_text.dart';
import 'package:bapp/widgets/tiles/add_image_sliver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessSubmitBranchForVerificationScreen extends StatefulWidget {
  BusinessSubmitBranchForVerificationScreen({Key? key}) : super(key: key);

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
        body: Builder(
          builder: (_) {
            return LoadingStackWidget(
              child: isNotShowable()
                  ? ContextualMessageScreen(
                      buttonText: "Go back",
                      init: () {},
                      message:
                          "Your selected branch is disabled or in process of verification",
                      onButtonPressed: (context) {
                        Get.back(result: null);
                      },
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              PaddedText(
                                "Ready to recieve bookings?",
                                style: Theme.of(context).textTheme.headline1 ??
                                    TextStyle(),
                              ),
                              PaddedText(
                                "We verify business before customers could see them, Send us below documents.",
                                style: Theme.of(context).textTheme.bodyText1 ??
                                    TextStyle(),
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
                                style: Theme.of(context).textTheme.caption ??
                                    TextStyle(),
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

  bool isNotShowable() {
    return false;
  }

  _apply() async {
    act(() {
      kLoading.value = true;
    });
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "business name: " "na",
                  style: pw.TextStyle(
                    fontSize: 22,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "business main address :" "na",
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch name :" + "na",
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch address :" + "na",
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "business contact :" + "na",
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "business email :" + "na",
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch contact :" + "na",
                  style: pw.TextStyle(
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  "branch email :" + "na",
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

    await Future.forEach<String>(_businessDocs.keys, (key) async {
      final bytes = await File(removeLocalFromPath(key)).readAsBytes();
      pdfImages.add(PdfImage.file(pdf.document, bytes: bytes));
    });

    await Future.forEach<String>(_ownerDoc.keys, (key) async {
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
                child: pw.SizedBox(),
              );
            },
          ),
        );
      },
    );

    final path = await getTemporaryDirectory();
    final fileName = DateTime.now().toIso8601String() + ".pdf";

    final ints = await pdf.save();
    if (ints is Uint8List) {
      final theFileToUpload =
          await File(path.absolute.path + "/" + fileName).writeAsBytes(ints);

      //await uploadBusinessBranchApprovalPDF(fileToUpload: theFileToUpload);
    }

    Get.off(ContextualMessageScreen(
      init: () {
        act(
          () {},
        );
      },
      message:
          "Thank you for sending the documents, we will contact you on your registered number to update you the status.",
    ));
    act(() {
      kLoading.value = true;
    });
  }
}
