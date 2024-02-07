import 'dart:convert';

import 'package:AIBudget/features/main_navigation/main_navigation_screen.dart';
import 'package:AIBudget/features/main_navigation/widgets/card_Box.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageInfo {
  final int year;
  final int month;
  final String caption;
  final String imagePath;

  ImageInfo({
    required this.year,
    required this.month,
    required this.caption,
    required this.imagePath,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      year: json['year'],
      month: json['month'],
      caption: json['caption'],
      imagePath: json['image_path'],
    );
  }
}

Future<List<ImageInfo>> fetchImagesForDate(DateTime date) async {
  final response = await http.post(
    Uri.parse("https://5431508973.for-seoul.synctreengine.com/load_image"),
    body: {"date": date.toIso8601String().substring(0, 10)},
  );

  if (response.statusCode == 200) {
    final data =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final List<dynamic> resultList = data['result'];
    return resultList.map((item) => ImageInfo.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load images');
  }
}

Future<String?> getFirstImageForMonth(int year, int month) async {
  DateTime date = DateTime(year, month, 1);
  List<ImageInfo> imageInfos = await fetchImagesForDate(date);

  if (imageInfos.isNotEmpty) {
    return imageInfos[0].imagePath;
  }
  return null;
}

class StackDialog extends StatefulWidget {
  final double initialIndex;
  final PageController controller;

  const StackDialog({
    super.key,
    required this.controller,
    this.initialIndex = 0.0,
  });

  @override
  _StackDialogState createState() => _StackDialogState();
}

class _StackDialogState extends State<StackDialog>
    with TickerProviderStateMixin {
  bool dialogShowContainer = false;
  late AnimationController dialogFadeController;
  late double _currentIndex;
  List<String?> monthlyFirstImageUrls = List.filled(4, null);
  List<String?> monthlyCaptions = List.filled(4, null);
  String? currentCaption;

  void loadFirstImagesForMonths() async {
    DateTime date = DateTime(2023, 9, 1);
    List<ImageInfo> imageInfos = await fetchImagesForDate(date);

    if (imageInfos.isNotEmpty) {
      for (int i = 0; i < imageInfos.length && i < 4; i++) {
        monthlyFirstImageUrls[i] = imageInfos[i].imagePath;
        monthlyCaptions[i] = imageInfos[i].caption;
      }
      setState(() {});
    }
  }

  void _dialogOnClosePressed() {
    print("Close button pressed!");
    dialogFadeController.reverse().then((value) {
      setState(() {
        dialogShowContainer = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    dialogFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    loadFirstImagesForMonths();
  }

  @override
  void dispose() {
    dialogFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 600, // 원하는 높이를 설정하세요.
        width: 400, // 원하는 너비를 설정하세요.
        child: Stack(
          children: [
            SizedBox(
              height: 600,
              child: PageView.builder(
                controller: widget.controller,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final imageUrl =
                      monthlyFirstImageUrls[index] ?? "fallback_image_url";
                  final caption = monthlyCaptions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CardBox(
                      imageUrl: imageUrl,
                      height: 800,
                      onTap: () {
                        loadFirstImagesForMonths();
                        setState(() {
                          currentCaption =
                              utf8.decode(utf8.encode(caption ?? ""));
                          dialogShowContainer = true;
                          dialogFadeController.forward();
                        });
                      },
                    ),
                  );
                },
                onPageChanged: (int index) {
                  setState(() {
                    _currentIndex = index.toDouble();
                    dialogShowContainer = false;
                    dialogFadeController.reverse();
                  });
                },
              ),
            ),
            if (dialogShowContainer)
              Positioned(
                top: 490,
                left: 25,
                child: FadeTransition(
                  opacity: dialogFadeController,
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentCaption ?? "",
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: _dialogOnClosePressed,
                              color: Colors.black,
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: DotsIndicator(
                decorator: DotsDecorator(
                  activeColor: kbYellow,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide.none,
                  ),
                ),
                dotsCount: 4,
                position: _currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
