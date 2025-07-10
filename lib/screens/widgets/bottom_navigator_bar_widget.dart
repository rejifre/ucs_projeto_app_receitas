import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../../ui/app_colors.dart';

class BottomNavigatorBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavigatorBarWidget({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushNamed(context, Routes.home);
    } else if (index == 1) {
      Navigator.pushNamed(context, Routes.categoriesScreen);
    } else if (index == 2) {
      Navigator.pushNamed(context, Routes.search);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.backgroundColor,
      currentIndex: currentIndex,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorias',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pesquisar'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
      ],
    );
  }
}
