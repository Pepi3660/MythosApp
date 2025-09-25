import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

enum ScreenOrientation {
  portrait,
  landscape,
}

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  final BuildContext context;
  
  const ResponsiveUtils._(this.context);
  
  static ResponsiveUtils of(BuildContext context) {
    return ResponsiveUtils._(context);
  }

  // Device type getters
  DeviceType get deviceType {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < largeDesktopBreakpoint) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  bool get mobile => ResponsiveUtils.isMobile(context);
  bool get tablet => ResponsiveUtils.isTablet(context);
  bool get desktop => ResponsiveUtils.isDesktop(context);
  
  // Width percentage methods
  double wp(double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }
  
  // Height percentage methods
  double hp(double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }
  
  // Density-independent pixel methods
  double dp(double size) {
    return size * MediaQuery.of(context).textScaleFactor;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }



  // Responsive layout methods
  int get gridColumns {
    switch (deviceType) {
      case DeviceType.mobile:
        return isLandscape ? 2 : 1;
      case DeviceType.tablet:
        return isLandscape ? 3 : 2;
      case DeviceType.desktop:
        return 4;
      case DeviceType.largeDesktop:
        return 6;
    }
  }

  double get maxContentWidth {
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
      case DeviceType.largeDesktop:
        return 1400;
    }
  }

  EdgeInsets get responsivePadding {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(48);
    }
  }

  double get responsiveFontSize {
    switch (deviceType) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 18;
      case DeviceType.largeDesktop:
        return 20;
    }
  }

  bool get isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;
  bool get isPortrait => !isLandscape;

  // Adaptive spacing
  double get smallSpacing => deviceType == DeviceType.mobile ? 8 : 12;
  double get mediumSpacing => deviceType == DeviceType.mobile ? 16 : 24;
  double get largeSpacing => deviceType == DeviceType.mobile ? 24 : 32;

  // Adaptive sizing for components
  double get buttonHeight {
    switch (deviceType) {
      case DeviceType.mobile:
        return 48;
      case DeviceType.tablet:
        return 52;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 56;
    }
  }

  double get appBarHeight {
    switch (deviceType) {
      case DeviceType.mobile:
        return 56;
      case DeviceType.tablet:
        return 64;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 72;
    }
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth - 32; // Full width minus padding
    } else if (isTablet(context)) {
      return (screenWidth - 72) / 2; // Two columns with spacing
    } else {
      return (screenWidth - 128) / 3; // Three columns with spacing
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) {
      return screenWidth > 1400 ? 1200 : screenWidth * 0.85;
    }
    return screenWidth;
  }

  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.responsiveBuilder(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveUtils.getMaxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? forceColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.forceColumns,
  });

  @override
  Widget build(BuildContext context) {
    final columns = forceColumns ?? ResponsiveUtils.getGridColumns(context);
    
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: ResponsiveUtils.isMobile(context) 
              ? double.infinity 
              : (ResponsiveUtils.getScreenWidth(context) - 
                 ResponsiveUtils.getResponsivePadding(context).horizontal - 
                 (spacing * (columns - 1))) / columns,
          child: child,
        );
      }).toList(),
    );
  }
}