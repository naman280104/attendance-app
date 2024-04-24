import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class PDFDisplay extends StatefulWidget {
  // final String path;
  final Uint8List data;

  PDFDisplay({Key? key, required this.data}) : super(key: key);

  _PDFDisplayState createState() => _PDFDisplayState();
}

class _PDFDisplayState extends State<PDFDisplay> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black)
        )
      ),
      child: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: PDFView(
                // filePath: widget.path,
                pdfData: widget.data,
                // enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: currentPage!,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation:
                    false, // if set to true the link is handled in flutter
                onRender: (_pages) {
                  setState(() {
                    pages = _pages;
                    isReady = true;
                  });
                },
                onError: (error) {
                  setState(() {
                    errorMessage = error.toString();
                  });
                  print(error.toString());
                },
                onPageError: (page, error) {
                  setState(() {
                    errorMessage = '$page: ${error.toString()}';
                  });
                  print('$page: ${error.toString()}');
                },
                onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                },
                onLinkHandler: (String? uri) {
                  print('goto uri: $uri');
                },
                onPageChanged: (int? page, int? total) {
                  print('page change: $page/$total');
                  setState(() {
                    currentPage = page;
                  });
                },
              ),
            ),
            errorMessage.isEmpty
                ? !isReady
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container()
                : Center(
                    child: Text(errorMessage),
                  )
          ],
      ),
    );
  }
}