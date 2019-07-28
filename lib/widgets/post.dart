import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Post extends StatefulWidget {
  Post({Key key}) : super(key: key);

  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
           child: Column(
             children: <Widget>[
               Column(
                 children: <Widget>[
                   Text(
                     'This is a test title of a test post for Reddit that is long enough for testing',
                     maxLines: 3,
                     style: TextStyle(
                       fontSize: 25
                     )
                   ),
                   Row(
                     children: <Widget>[
                        Text(
                          'r/testSubReddit',
                          style: TextStyle(
                            fontSize: 15
                          ),
                        ),
                        Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 15
                          ),
                        ),
                        Text(
                          'u/testUser',
                          style: TextStyle(
                            fontSize: 15
                          ),
                        )
                     ],
                   ),
                  Row(
                    children: <Widget>[
                      Text(
                        '1537 Votes',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      Text(
                        ' - ',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      Text(
                        '475 Comments',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      )
                    ],
                  )
                 ],
               )
             ],
           ),
        ),
      ),
    );
  }
}
