import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Post extends StatefulWidget {
  Post({Key key}) : super(key: key);

  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(
         children: <Widget>[
           Row(
             children: <Widget>[
               Container(
                 width: 100,
                 height: 100,
                 color: Colors.blueAccent,
               ),
               Column(
                 children: <Widget>[
                    Text(
                      'This is the title of the post',
                      overflow: TextOverflow.clip,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  //  Row(
                  //    children: <Widget>[
                  //      Text('r/testSubReddit'),
                  //      Text('u/testUser'),
                  //      Text('10 Years ago')
                  //    ],
                  //  ),
                  //  Row(
                  //    children: <Widget>[
                  //      Text('1283'),
                  //      Text('434 Comments')
                  //    ],
                  //  )
                 ],
               )
             ]
           )
         ],
       ),
    );
  }
}
