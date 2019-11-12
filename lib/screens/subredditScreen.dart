
import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openReddit/widgets/submissionsWidget.dart';

class SubredditScreen extends StatefulWidget {

  final Subreddit subreddit;
  final Future<Subreddit> futureSubreddit;

  SubredditScreen({Key key, this.subreddit, this.futureSubreddit}) : super(key: key);

  _SubredditScreenState createState() => _SubredditScreenState();
}

class _SubredditScreenState extends State<SubredditScreen> {
  List<UserContent> _userContentList = [];
  List<Rule> _rules;
  Stream<UserContent> _userConent;
  String _sortMethod = 'Hot';
  String _topTimeFrame = 'Day';
  StreamSubscription<UserContent> _newUserConentsubscription;
  bool _ready = false;
  Subreddit _subreddit;
  bool _subscribed;

  @override
  void initState() {
    this.populate();
    super.initState();
  }

  @override
  void dispose() {
    _newUserConentsubscription.cancel();
    super.dispose();
  }

  void populate() async {
    if(widget.futureSubreddit != null) {
      _subreddit = await widget.futureSubreddit;
      await this.getSubmissions();
      setState(() {
        _ready = true;
      });
    } else {
      _subreddit = widget.subreddit;
      await this.getSubmissions();
      setState(() {
        _ready = true;
      });
    }
    _subscribed = _subreddit.data['user_is_subscriber'];
    this.getRules();
  }

  void getRules() async {
    List<Rule> rules = await _subreddit.rules();
    setState(() {
      this._rules = rules;
    });
  }

  Future<void> getSubmissions() async {
    Completer completer = new Completer();

    if(this._newUserConentsubscription != null) {
      this._newUserConentsubscription.cancel();
    }
    setState(() {
      this._userContentList = [];
      this._ready = false;
    });
    switch (this._sortMethod) {
      case 'Hot': this._userConent = _subreddit.hot(); break;
      case 'Top':
        this._userConent = _subreddit.top(
          timeFilter: 
            _topTimeFrame == 'Hour' ? TimeFilter.hour :
            _topTimeFrame == 'Day' ? TimeFilter.day :
            _topTimeFrame == 'Week' ? TimeFilter.week :
            _topTimeFrame == 'Month' ? TimeFilter.month :
            _topTimeFrame == 'Year' ? TimeFilter.year :
            _topTimeFrame == 'All time' ? TimeFilter.all :
            TimeFilter.day
        );
        break;
      case 'New': this._userConent = _subreddit.newest(); break;
      case 'Rising': this._userConent = _subreddit.rising(); break;
      case 'Controversial': this._userConent = _subreddit.controversial(); break;
    }
    
    this._newUserConentsubscription = this._userConent.listen((content) async {
      if(!completer.isCompleted)
      completer.complete();
      if(this.mounted)
      setState(() {
        this._userContentList.add(content);
      });
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if(_ready) {
      return Scaffold(
        endDrawer: Drawer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if(_subreddit.iconImage.toString() != '')
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(_subreddit.iconImage.toString() ?? '')
                          )
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'r/' + _subreddit.displayName,
                        style: TextStyle(
                          fontSize: 25
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Subscriber ' + _subreddit.data['subscribers'].toString(),
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                    IconButton(
                      icon: Icon(_subscribed ? FontAwesomeIcons.bellSlash : FontAwesomeIcons.bell),
                      color: _subscribed ? Colors.blueAccent : null,
                      onPressed: () {
                        setState(() {
                          if(_subscribed) {
                            _subscribed = false;
                            _subreddit.unsubscribe();
                          } else {
                            _subscribed = true;
                            _subreddit.subscribe();
                          }
                        });
                      },
                    )
                  ],
                ),
                Text(
                  _subreddit.data['public_description'],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 5),
                ),
                Text('Subreddit description & rules:'),
                Expanded(
                  child: this._rules != null ? 
                  ListView.separated(
                    itemCount: this._rules.length + 1,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      if(index == 0) {
                        return MarkdownBody(
                          data: _subreddit.data["description"],
                          onTapLink: (link) {
                            FlutterWebBrowser.openWebPage(url: link); // TODO: unify with login browser
                          },
                        );
                      }
                      return ListTile(
                        title: Text(this._rules[index-1].shortName),
                        subtitle: Text(this._rules[index-1].description),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  )
                  : Text('Loading rules...'),
                )
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('r/' + _subreddit.displayName),
          actions: <Widget>[
            DropdownButton(
              value: this._sortMethod,
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
              onChanged: (newVal) async {
                setState(() {
                  this._sortMethod = newVal;
                });
                await this.getSubmissions();
                setState(() {
                  this._ready = true;
                });
              },
            ),
            if(_sortMethod == 'Top')
              DropdownButton(
                value: _topTimeFrame,
                items: ['Hour', 'Day', 'Week', 'Month', 'Year', 'All time'].map((String val) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (newVal) async {
                  setState(() {
                    this._topTimeFrame = newVal;
                  });
                  await this.getSubmissions();
                  setState(() {
                    this._ready = true;
                  });
                },
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return this.getSubmissions();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SubmissionsWidget(
              submissions: this._userContentList.cast<Submission>(),
              leading: Container(
                // decoration: _subreddit.headerImage != null ? BoxDecoration(
                //   image: DecorationImage(
                //     image: NetworkImage(_subreddit.headerImage.toString())
                //   )
                // ) : BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if(_subreddit.iconImage.toString() != '')
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(_subreddit.iconImage.toString()),
                          )
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'r/' + _subreddit.displayName,
                        style: TextStyle(
                          fontSize: 30
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),      
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: LinearProgressIndicator(),
      );
    }
  }
}
