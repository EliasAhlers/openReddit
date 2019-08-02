
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:redditclient/widgets/postWidget.dart';
import 'package:redditclient/widgets/submissionsWidget.dart';

class SubredditScreen extends StatefulWidget {

  final Subreddit subreddit;

  SubredditScreen({Key key, this.subreddit}) : super(key: key);

  _SubredditScreenState createState() => _SubredditScreenState();
}

class _SubredditScreenState extends State<SubredditScreen> {
  List<UserContent> userContentList = [];
  List<Rule> rules;
  Stream<UserContent> userConent;
  String sortMethod = 'Hot';

  @override
  void initState() {
    this.getSubmissions();
    this.getRules();
    super.initState();
  }

  void getRules() async {
    this.rules = await widget.subreddit.rules();
  }

  void getSubmissions() async {
    this.userContentList = [];
    switch (this.sortMethod) {
      case 'Hot': this.userConent = widget.subreddit.hot(); break;
      case 'Top': this.userConent = widget.subreddit.top(); break;
      case 'New': this.userConent = widget.subreddit.newest(); break;
      case 'Rising': this.userConent = widget.subreddit.rising(); break;
      case 'Controversial': this.userConent = widget.subreddit.controversial(); break;
    }
    
    this.userConent.listen((content) {
      setState(() {
        this.userContentList.add(content);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.subreddit.iconImage.toString())
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'r/' + widget.subreddit.displayName,
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                widget.subreddit.data['public_description'],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 5),
              ),
              Text('Subreddit rules:'),
              this.rules != null ? 
              Expanded(
                child: ListView.separated(
                  itemCount: this.rules.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(this.rules[index].shortName),
                      subtitle: Text(this.rules[index].description),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                )
              )
              : Text('Loading rules...'),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('r/' + widget.subreddit.displayName),
        actions: <Widget>[
          DropdownButton(
            value: this.sortMethod,
            items: ['Top', 'Hot', 'New', 'Rising', 'Controversial'].map((String val) {
              return DropdownMenuItem(
                value: val,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        val == 'Top' ? FontAwesomeIcons.trophy :
                        val == 'Hot' ? FontAwesomeIcons.fire :
                        val == 'New' ? FontAwesomeIcons.calendar :
                        val == 'Rising' ? FontAwesomeIcons.arrowUp :
                        val == 'Controversial' ? FontAwesomeIcons.angry :
                        Icons.cloud_circle
                      ),
                    ),
                    Text(val)
                  ],
                ),
              );
            }).toList(),
            onChanged: (newVal) {
              setState(() {
                this.sortMethod = newVal;
                this.getSubmissions();
              });
            },
          )
        ],
      ),
      body: SubmissionsWidget(
        submissions: this.userContentList.cast<Submission>(),
      ),
    );
  }
}