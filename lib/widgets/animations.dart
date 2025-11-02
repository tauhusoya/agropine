import 'package:flutter/material.dart';

class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeIn,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}

class SlideInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;

  const SlideInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    this.direction = SlideDirection.fromBottom,
  });

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.fromTop:
        beginOffset = const Offset(0, -1);
        break;
      case SlideDirection.fromBottom:
        beginOffset = const Offset(0, 1);
        break;
      case SlideDirection.fromLeft:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.fromRight:
        beginOffset = const Offset(1, 0);
        break;
    }

    _offset = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: widget.child,
    );
  }
}

enum SlideDirection { fromTop, fromBottom, fromLeft, fromRight }

class StaggeredFadeInWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration duration;
  final Curve curve;

  const StaggeredFadeInWidget({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeIn,
  });

  @override
  State<StaggeredFadeInWidget> createState() => _StaggeredFadeInWidgetState();
}

class _StaggeredFadeInWidgetState extends State<StaggeredFadeInWidget> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.asMap().entries.map((entry) {
      final controller = entry.value;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.itemDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => FadeTransition(
          opacity: _animations[index],
          child: widget.children[index],
        ),
      ),
    );
  }
}
