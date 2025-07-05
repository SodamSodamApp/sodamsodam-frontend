import 'package:flutter/material.dart';

class PlaceReviewCard extends StatefulWidget {
  const PlaceReviewCard({
    super.key,
    required this.userName,
    required this.isLiked,
    required this.tags,
    required this.content, //required this.images,
  });
  final String userName;
  final bool isLiked;
  //final Image images;
  final List<String> tags;
  final String content;

  @override
  State<PlaceReviewCard> createState() => _PlaceReviewCardState();
}

class _PlaceReviewCardState extends State<PlaceReviewCard> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 375,
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        padding: EdgeInsets.all(2),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 0.5),
                        ),
                        child: Image.asset("/assets/image/user.png"),
                      ),

                      Text(
                        widget.userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        // 리뷰 찜 리스트 제외 API 통신 필요
                      });
                    },
                    child: Icon(
                      widget.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  3, //images의 length
                  (context) {
                    return Container(
                      width: 120,
                      height: 150,
                      margin: EdgeInsets.fromLTRB(0, 0, 5, 15),
                      decoration: BoxDecoration(
                        color: Color(0xff898989),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(widget.tags.length, (context) {
                return Container(
                  padding: EdgeInsets.all(3),
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Color(0xffededed),
                    borderRadius: BorderRadius.all(Radius.circular(19)),
                  ),
                  child: Text(
                    "# ${widget.tags[context]}",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
                  ),
                );
              }),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 0, 5),
              child: Text(
                widget.content,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
