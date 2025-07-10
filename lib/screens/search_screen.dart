import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/routes.dart';
import '../providers/recipes_provider.dart';
import '../ui/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Adiciona um listener para recarregar as categorias sempre que o texto de busca mudar
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose(); // Não esqueça de liberar o controlador
    super.dispose();
  }

  /// Carrega as categorias do banco de dados, aplicando um filtro de busca se fornecido.
  Future<void> _loadRecipes({String? query}) async {
    final provider = Provider.of<RecipesProvider>(context, listen: false);
    if (query != null && query.isNotEmpty) {
      await provider.searchRecipes(query);
    } else {
      await provider.searchRecipes();
    }
  }

  /// Chamado quando o texto no campo de busca é alterado.
  void _onSearchChanged() {
    _loadRecipes(query: _searchController.text);
  }

  void _navigateToDetail(String id) async {
    await Navigator.pushNamed(context, Routes.recipeDetail, arguments: id);
    _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesProvider>(context);
    final recipes = provider.recipes;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              'Buscar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Buscar receitas....',
              onChanged: (value) => _loadRecipes(query: value.trim()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.mainColor,
                      child: Text(
                        index.toString(),
                        style: TextStyle(color: AppColors.lightBackgroundColor),
                      ),
                    ),
                    title: Text(recipes[index].title),
                    subtitle: Text(
                      "${recipes[index].ingredients.length} ingredientes.",
                    ),
                    tileColor: AppColors.lightBackgroundColor,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Icon(Icons.timer_sharp, size: 15),
                        Text(recipes[index].preparationTime),
                      ],
                    ),
                    onTap: () => _navigateToDetail(recipes[index].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
