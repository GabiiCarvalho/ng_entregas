import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color titleColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double elevation;
  final bool centerTitle;
  final Widget? titleWidget;
  final Widget? flexibleSpace;
  final double height;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.leading,
    this.actions,
    this.backgroundColor = Colors.orange,
    this.titleColor = Colors.white,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleWidget,
    this.flexibleSpace,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title:
          titleWidget ??
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
      leading: leading ?? _buildBackButton(context),
      actions: actions,
      elevation: elevation,
      centerTitle: centerTitle,
      flexibleSpace: flexibleSpace,
      iconTheme: IconThemeData(color: titleColor),
      toolbarHeight: height,
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    if (!showBackButton) return null;

    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: 20),
      onPressed: onBackPressed ?? () => Navigator.pop(context),
    );
  }
}

class DeliveryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showProfile;
  final String? profileName;
  final String? profileImage;
  final VoidCallback? onProfileTap;
  final Color backgroundColor;
  final bool showDivider;

  const DeliveryAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showProfile = false,
    this.profileName,
    this.profileImage,
    this.onProfileTap,
    this.backgroundColor = Colors.orange,
    this.showDivider = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(showProfile ? 120 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (leading != null) leading!,
                  if (leading == null && Navigator.canPop(context))
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),

                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),

          if (showProfile) _buildProfileSection(),

          if (showDivider)
            Divider(
              height: 1,
              color: Colors.white.withOpacity(0.3),
              thickness: 0.5,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: onProfileTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: profileImage != null
                  ? CircleAvatar(backgroundImage: NetworkImage(profileImage!))
                  : Center(
                      child: Text(
                        profileName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${profileName?.split(' ').first ?? 'Usuário'}!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pronto para uma nova entrega?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.notifications_none, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onCancel;
  final bool showCancelButton;
  final Color backgroundColor;
  final Color iconColor;

  const SearchAppBar({
    super.key,
    this.hintText = 'Buscar...',
    this.controller,
    this.onChanged,
    this.onSearch,
    this.onCancel,
    this.showCancelButton = true,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.grey,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: (_) => onSearch?.call(),
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: iconColor),
            suffixIcon: controller?.text.isNotEmpty == true
                ? IconButton(
                    icon: Icon(Icons.close, size: 18, color: iconColor),
                    onPressed: () {
                      controller?.clear();
                      onChanged?.call('');
                    },
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
      actions: showCancelButton
          ? [
              TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: Colors.orange)),
              ),
            ]
          : null,
    );
  }
}

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color iconColor;
  final Color? backgroundColor;

  const TransparentAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.iconColor = Colors.white,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      title: title != null
          ? Text(title!, style: TextStyle(color: iconColor))
          : null,
      leading:
          leading ??
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: iconColor),
            onPressed: () => Navigator.pop(context),
          ),
      actions: actions,
      iconTheme: IconThemeData(color: iconColor),
    );
  }
}

class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTabChanged;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color indicatorColor;
  final bool isScrollable;

  const TabbedAppBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTabChanged,
    this.backgroundColor = Colors.orange,
    this.selectedColor = Colors.white,
    this.unselectedColor = Colors.white70,
    this.indicatorColor = Colors.white,
    this.isScrollable = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      bottom: TabBar(
        controller: controller,
        onTap: onTabChanged,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        labelColor: selectedColor,
        unselectedLabelColor: unselectedColor,
        indicatorColor: indicatorColor,
        indicatorWeight: 3,
        isScrollable: isScrollable,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
