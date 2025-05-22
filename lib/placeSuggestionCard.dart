import 'package:flutter/material.dart';

class PlaceSuggestionCard extends StatefulWidget {
  const PlaceSuggestionCard({
    super.key,
    required this.placeName,
    required this.review,
  });

  final String placeName;
  final String review;

  @override
  State<PlaceSuggestionCard> createState() => _PlaceSuggestionCardState();
}

class _PlaceSuggestionCardState extends State<PlaceSuggestionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      //color: Colors.amber,
      height: 86,
      width: 288,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 86,
              width: 89,
              margin: EdgeInsets.fromLTRB(0, 0, 30, 0),
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Image.asset('assets/image/logo.png'),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.placeName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),

                Container(
                  width: 172,
                  child: Text(
                    widget.review,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
