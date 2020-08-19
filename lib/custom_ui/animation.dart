import 'package:flutter/material.dart';

class AnimatedOpacityCS extends StatelessWidget{

  AnimatedOpacityCS({
    Key key,
    @required this.child,
  }) : super(key : key);

  final Widget child;

  @override
  Widget build(BuildContext context) {

    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400),
        child: child,
        builder: (BuildContext context, double value, Widget child){
          return Opacity(
            opacity: value,
            child: child,
          );
        }
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({ Key key, this.photo, this.onTap, this.width }) : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}