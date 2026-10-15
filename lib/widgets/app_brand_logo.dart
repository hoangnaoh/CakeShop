import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BrandLogoLayout { vertical, horizontal }

class AppBrandLogo extends StatelessWidget {
  final BrandLogoLayout layout;
  final double iconSize;
  final double titleSize;
  final double taglineSize;
  final bool isLight;
  final bool showAdminBadge;
  final String title;
  final String tagline;

  const AppBrandLogo({
    super.key,
    this.layout = BrandLogoLayout.vertical,
    this.iconSize = 26,
    this.titleSize = 20,
    this.taglineSize = 8,
    this.isLight = false,
    this.showAdminBadge = false,
    this.title = 'CAKE',
    this.tagline = 'FRESH & DELICIOUS',
  });

  /// Logo cỡ lớn cho màn hình Đăng nhập / Đăng ký
  factory AppBrandLogo.hero({bool isLight = false}) {
    return AppBrandLogo(
      layout: BrandLogoLayout.vertical,
      iconSize: 42,
      titleSize: 28,
      taglineSize: 10,
      isLight: isLight,
    );
  }

  /// Logo ngang gọn gàng cho AppBar Admin hoặc thanh công cụ
  factory AppBrandLogo.horizontal({
    bool showAdminBadge = false,
    bool isLight = false,
  }) {
    return AppBrandLogo(
      layout: BrandLogoLayout.horizontal,
      iconSize: 22,
      titleSize: 16,
      taglineSize: 8,
      showAdminBadge: showAdminBadge,
      isLight: isLight,
    );
  }

  /// Logo cho Drawer bên trái trang chủ
  factory AppBrandLogo.drawer() {
    return const AppBrandLogo(
      layout: BrandLogoLayout.vertical,
      iconSize: 32,
      titleSize: 24,
      taglineSize: 9,
      isLight: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = isLight ? Colors.white : AppColors.primary;
    final secondaryTextColor = isLight ? Colors.white.withOpacity(0.85) : AppColors.primary.withOpacity(0.8);
    final dividerColor = isLight ? Colors.white.withOpacity(0.5) : AppColors.primary.withOpacity(0.4);

    if (layout == BrandLogoLayout.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isLight ? Colors.white.withOpacity(0.15) : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cake_rounded, color: primaryColor, size: iconSize),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                  if (showAdminBadge) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          color: isLight ? AppColors.primary : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 1, color: dividerColor),
                  const SizedBox(width: 3),
                  Text(
                    tagline,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: taglineSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(width: 8, height: 1, color: dividerColor),
                ],
              ),
            ],
          ),
        ],
      );
    }

    // Vertical layout (Mặc định)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(iconSize > 30 ? 12 : 0),
          decoration: iconSize > 30
              ? BoxDecoration(
                  color: isLight ? Colors.white.withOpacity(0.18) : AppColors.primaryLight,
                  shape: BoxShape.circle,
                )
              : null,
          child: Icon(
            Icons.cake_rounded,
            color: primaryColor,
            size: iconSize,
          ),
        ),
        SizedBox(height: iconSize > 30 ? 8 : 2),
        Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 1, color: dividerColor),
            const SizedBox(width: 4),
            Text(
              tagline,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: taglineSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 4),
            Container(width: 14, height: 1, color: dividerColor),
          ],
        ),
      ],
    );
  }
}
