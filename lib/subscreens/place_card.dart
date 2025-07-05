import 'package:flutter/material.dart';

class PlaceCard extends StatefulWidget {
  const PlaceCard({
    super.key,
    required this.placeName,
    required this.content,
    required this.isLiked,
  });
  final String placeName;
  final String content;
  final bool isLiked;
  //이미지

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 375,
        padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  decoration: BoxDecoration(
                    color: Color(0xffd9d9d9),
                    borderRadius: BorderRadius.all(Radius.circular(17)),
                  ),
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.placeName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.content,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
              child: InkWell(
                onTap: () {
                  setState(() {
                    // 리뷰 찜 리스트 제외 API 통신 필요
                  });
                },
                child: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
