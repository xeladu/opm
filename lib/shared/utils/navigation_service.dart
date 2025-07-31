import 'package:flutter/material.dart';

class NavigationService {
  /// Navigates to the given target by pushing it on the navigation stack
  static Future<void> goTo(BuildContext context, Widget target) async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _createSlideTransition(
              context,
              animation,
              secondaryAnimation,
              child,
            ),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  /// Replaces the current route but preserves the navigation history
  static Future<void> replaceCurrent(
    BuildContext context,
    Widget target,
  ) async {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _createSlideTransition(
              context,
              animation,
              secondaryAnimation,
              child,
            ),

        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Clears the navigation history and pushes the target page as the only route
  static Future<void> replaceAll(BuildContext context, Widget target) async {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            _createSlideTransition(
              context,
              animation,
              secondaryAnimation,
              child,
            ),

        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  /// Removes the top entry from the navigation stack (go back one page)
  static Future<void> goBack<T>(BuildContext context, [T? result]) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  static SlideTransition _createSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final tween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: Curves.ease));

    return SlideTransition(position: animation.drive(tween), child: child);
  }
}
