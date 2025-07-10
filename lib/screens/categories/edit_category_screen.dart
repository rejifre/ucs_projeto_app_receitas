import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/category_model.dart';
import '../../providers/categories_provider.dart';
import '../../ui/app_colors.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final _uuid = const Uuid();
  var isEditing = false;
  CategoryModel? _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_category == null) {
      final category =
          ModalRoute.of(context)!.settings.arguments as CategoryModel?;
      isEditing = category?.id != null;
      _idController.text = category?.id ?? _uuid.v4();
      _nameController.text = category?.name ?? '';
      _category = category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para a categoria'),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _saveCategory();
    }
  }

  void _saveCategory() {
    final category = CategoryModel(
      id: _idController.text,
      name: _nameController.text,
    );

    final provider = Provider.of<CategoriesProvider>(context, listen: false);
    provider.addOrUpdateCategory(category);

    final sm = ScaffoldMessenger.of(context);
    sm.showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Categoria atualizada com sucesso!'
              : 'Categoria adicionada com sucesso!',
        ),
      ),
    );
  }

  void _confirmDeleteCategory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Excluir Categoria'),
            content: const Text(
              'Você tem certeza que deseja excluir esta categoria?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final provider = Provider.of<CategoriesProvider>(
                    context,
                    listen: false,
                  );
                  provider.deleteCategory(_idController.text);
                  Navigator.of(context).pop(); // fecha o dialog
                  Navigator.of(context).pop(); // volta para a tela anterior
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: AppColors.delete),
                ),
              ),
            ],
          ),
    );
  }

  // void _pickColor() async {
  //   Color? picked = await showDialog<Color>(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Escolha uma cor'),
  //           content: SingleChildScrollView(
  //             child: BlockPicker(
  //               pickerColor: _selectedColor,
  //               onColorChanged: (color) => Navigator.of(context).pop(color),
  //             ),
  //           ),
  //         ),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _selectedColor = picked;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Categoria'),
        actions: [
          Visibility(
            visible: isEditing,
            child: TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text("Excluir"),
              style: TextButton.styleFrom(foregroundColor: AppColors.delete),
              onPressed: _confirmDeleteCategory,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 16),
              // Row(
              //   children: [
              //     const Text('Cor:'),
              //     const SizedBox(width: 8),
              //     GestureDetector(
              //       onTap: _pickColor,
              //       child: CircleAvatar(
              //         backgroundColor: _selectedColor,
              //         radius: 18,
              //       ),
              //     ),
              //   ],
              // ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salvar Categoria'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
