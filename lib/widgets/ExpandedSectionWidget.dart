import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class ExpandedSectionWidget extends StatefulWidget {

  final Widget child;
  final bool expand;
  final int duration;

  ExpandedSectionWidget({this.expand = false, this.duration = 500, this.child});

  @override
  _ExpandedSectionWidgetState createState() => _ExpandedSectionWidgetState();
}

class _ExpandedSectionWidgetState extends State<ExpandedSectionWidget> with SingleTickerProviderStateMixin {
  AnimationController _expandController;
  Animation<double> _animation; 
  bool renderContent;

  @override
  void initState() {
    super.initState();
    renderContent = widget.expand;
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    _expandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration)
    );
    Animation curve = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      }
    );
  }

  @override
  void didUpdateWidget(ExpandedSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.expand) {
      setState(() {
        renderContent = true;
      });
      _expandController.forward();
    }
    else {
      Future.delayed(Duration(milliseconds: widget.duration + 5)).then((_) {
        if(mounted)
          setState(() {
            renderContent = false;
          });
      });
      _expandController.reverse();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: _animation,
      child: renderContent ? widget.child : Container()
    );
  }
}