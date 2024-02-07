import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 이미지URL로 받아와서 container에 출력하는 법.
class CardBox extends StatefulWidget {
  const CardBox({
    Key? key,
    required this.height,
    required this.onTap,
    required this.imageUrl, // <-- 이미지 URL을 받아올 프로퍼티를 추가
  }) : super(key: key);

  final double height;
  final VoidCallback onTap;
  final String imageUrl; // <-- 이미지 URL을 저장할 프로퍼티

  @override
  State<CardBox> createState() => _CardBoxState();
}

class _CardBoxState extends State<CardBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
              image: DecorationImage(
                // <-- 여기서 이미지를 표시
                image: NetworkImage(widget.imageUrl), // <-- 이미지 URL 사용
                fit: BoxFit.fitWidth, // <-- 이미지가 컨테이너에 가득 차도록 설정
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const FaIcon(FontAwesomeIcons.xmark),
            ),
          ),
        ],
      ),
    );
  }
}
