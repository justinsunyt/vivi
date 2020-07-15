import 'package:flutter/material.dart';
import '../Components/NavBurger.dart';
import '../Components/SideNav.dart';

class WrapperWidget extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final bool nav;

  const WrapperWidget({@required this.child, this.backgroundColor, this.nav});

  @override
  _WrapperWidgetState createState() => _WrapperWidgetState();
}

class _WrapperWidgetState extends State<WrapperWidget> {
  bool _navActive = false;

  void toggleNav() {
    setState(() {
      _navActive = !_navActive;
    });
  }

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 10 && widget.nav) {
              setState(() {
                _navActive = true;
              });
            }
            if (details.delta.dx < -10 && widget.nav) {
              setState(() {
                _navActive = false;
              });
            }
          },
          child: Stack(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _navActive = false;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                  color: widget.backgroundColor,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: _navActive ? 0.5 : 1,
                    child: SafeArea(
                      child: _navActive ? IgnorePointer(child: widget.child) : Container(child: widget.child),
                    ),
                  ),
                ),
              ),
              SideNav(onTap: toggleNav, active: _navActive,),
              SafeArea(
                child: Offstage(
                  offstage: !widget.nav,
                  child: NavBurger(onTap: toggleNav, active: _navActive),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}