import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';

// --- Widget de Gerenciamento de Categorias ---
class EditFormCategoryWidget extends StatefulWidget {
  final List<String> initialCategoryIds; // IDs das categorias já selecionadas
  final ValueChanged<List<String>> onCategoriesChanged;

  const EditFormCategoryWidget({
    super.key,
    required this.initialCategoryIds,
    required this.onCategoriesChanged,
  });

  @override
  State<EditFormCategoryWidget> createState() => EditFormCategoryWidgetState();
}

class EditFormCategoryWidgetState extends State<EditFormCategoryWidget> {
  late List<String> selectedCategoryIds = [];
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategoryIds = List.from(widget.initialCategoryIds);
  }

  void _removeCategory(String categoryId) {
    setState(() {
      selectedCategoryIds.remove(categoryId);
      widget.onCategoriesChanged(selectedCategoryIds);
    });
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void setCategories(List<String> list) {
    setState(() {
      selectedCategoryIds = list;
      widget.onCategoriesChanged(selectedCategoryIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    final List<CategoryModel> availableCategories =
        categoriesProvider.categories;

    // Para múltipla escolha, use showModalBottomSheet com CheckboxListTile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorias', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('Selecionar Categorias'),
            onPressed: () async {
              final result = await showModalBottomSheet<List<String>>(
                context: context,
                builder: (context) {
                  List<String> tempSelected = List.from(selectedCategoryIds);
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Selecione as tags',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children:
                                  availableCategories.map((category) {
                                    return CheckboxListTile(
                                      value: tempSelected.contains(category.id),
                                      title: Text(category.name),
                                      onChanged: (checked) {
                                        setModalState(() {
                                          if (checked == true) {
                                            tempSelected.add(category.id);
                                          } else {
                                            tempSelected.remove(category.id);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, tempSelected);
                              },
                              child: const Text('Confirmar'),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                isScrollControlled: true,
              );
              if (result != null) {
                setState(() {
                  selectedCategoryIds = result;
                  widget.onCategoriesChanged(selectedCategoryIds);
                });
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        // --- Tags Atuais da Receita ---
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children:
              selectedCategoryIds.isEmpty
                  ? [const Text('Nenhuma categoria adicionada.')]
                  : selectedCategoryIds.map((categoryId) {
                    final category = availableCategories.firstWhere(
                      (c) => c.id == categoryId,
                      orElse:
                          () => CategoryModel(
                            id: categoryId,
                            name: 'Categoria Desconhecida',
                          ),
                    );
                    return Chip(
                      label: Text(category.name),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeCategory(category.id),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
