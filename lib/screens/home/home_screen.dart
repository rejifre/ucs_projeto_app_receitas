import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../../ui/app_colors.dart';
import '../categories/categories_screen_widget.dart';
import '../favorites_screen.dart';
import '../search_screen.dart';
import '../widgets/drawer_widget.dart';
import 'home_screen_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreenWidget(),
    CategoriesScreenWidget(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAdd() async {
    await Navigator.pushNamed(context, Routes.editRecipe, arguments: null);
  }

  void _navigateToAddCategory() async {
    await Navigator.pushNamed(context, Routes.editCategory, arguments: null);
  }

  // Método para retornar o FloatingActionButton condicionalmente
  Widget? _buildFloatingActionButton() {
    // Se o índice selecionado for 0 (Tela Inicial), retorna o FAB.
    // Caso contrário, retorna null, o que significa que o FAB não será exibido.
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        onPressed: _navigateToAdd,
        tooltip: 'Adicionar Receita',
        backgroundColor: AppColors.buttonMainColor,
        child: const Icon(Icons.add),
      );
    }
    if (_selectedIndex == 1) {
      return FloatingActionButton(
        onPressed: _navigateToAddCategory,
        tooltip: 'Adicionar Categoria',
        backgroundColor: AppColors.buttonMainColor,
        child: const Icon(Icons.add, color: AppColors.backgroundColor),
      );
    }
    return null; // Não exibe o FAB para outras telas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(title: Text("Receitas Na Mão")),
      body: Center(child: _screens.elementAt(_selectedIndex)),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pesquisar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
