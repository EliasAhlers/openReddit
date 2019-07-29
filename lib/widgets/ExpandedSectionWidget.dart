import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class ExpandedSectionWidget extends StatefulWidget {

  final Widget child;
  final bool expand;
  ExpandedSectionWidget({this.expand = true, this.child});

  @override
  _ExpandedSectionWidgetState createState() => _ExpandedSectionWidgetState();
}

class _ExpandedSectionWidgetState extends State<ExpandedSectionWidget> with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation; 

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500)
    );
    Animation curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 1.0, end: 0.0).animate(curve)
      ..addListener(() {
        setState(() {

        });
      }
    );
  }

  @override
  void didUpdateWidget(ExpandedSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.expand) {
      expandController.reverse();
    }
    else {
      expandController.forward();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: widget.child
    );
  }
}