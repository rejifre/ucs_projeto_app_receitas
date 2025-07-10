import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';
import '../../routes/routes.dart';

class CategoriesScreenWidget extends StatefulWidget {
  const CategoriesScreenWidget({super.key});

  @override
  State<CategoriesScreenWidget> createState() => _CategoriesScreenWidgetState();
}

class _CategoriesScreenWidgetState extends State<CategoriesScreenWidget> {
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
  Future<void> _loadCategories({String? query}) async {
    final provider = Provider.of<CategoriesProvider>(context, listen: false);
    if (query != null && query.isNotEmpty) {
      await provider.searchCategories(query);
    } else {
      await provider.loadCategories();
    }
  }

  /// Chamado quando o texto no campo de busca é alterado.
  void _onSearchChanged() {
    _loadCategories(query: _searchController.text);
  }

  void _edit(BuildContext context, CategoryModel category) async {
    await Navigator.pushNamed(
      context,
      Routes.editCategory,
      arguments: category,
    );
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoriesProvider>(context);
    final categories = provider.categories;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              'Categorias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar tags...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _loadCategories(query: value.trim());
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                CategoryModel category = categories[index];
                return Card(
                  color: Colors.green,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      category.name,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onTap: () {
                      _edit(context, category);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
