// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/ingredient_model.dart';
import '../../models/instruction_model.dart';
import '../../models/recipe_model.dart';
import '../../providers/recipes_provider.dart';
import '../../routes/routes.dart';
import '../../repositories/security_auth_repository.dart';
import '../../services/recipe_generator_service.dart';
import '../../ui/app_colors.dart';
import '../../utils/recipe_screen_type.dart';
import 'edit_form_ingredient_list_widget.dart';
import 'edit_form_instruction_list_widget.dart';

class EditRecipeScreen extends StatefulWidget {
  const EditRecipeScreen({super.key});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<EditFormIngredientListWidgetState> _ingredientListKey =
      GlobalKey<EditFormIngredientListWidgetState>();
  final GlobalKey<EditFormInstructionListWidgetState> _instructionListKey =
      GlobalKey<EditFormInstructionListWidgetState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _preparationTimeController =
      TextEditingController();

  final _uuid = const Uuid();
  String? _currentDate;
  Recipe? _currentRecipe;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _currentRecipe = ModalRoute.of(context)?.settings.arguments as Recipe?;
      _idController.text = _currentRecipe?.id ?? _uuid.v4().toString();
      _titleController.text = _currentRecipe?.title ?? '';
      _descriptionController.text = _currentRecipe?.description ?? '';
      _scoreController.text = _currentRecipe?.score.toString() ?? '';
      _preparationTimeController.text =
          _currentRecipe?.preparationTime ?? '0h 0m';
      _currentDate = _currentRecipe?.date ?? _getDate();

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scoreController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  String _getDate() {
    final now = DateTime.now();
    return DateFormat('dd/MM/yyyy HH:mm').format(now.toUtc());
  }

  Future<void> _confirmDeleteRecipe() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text(
            'Tem certeza de que deseja excluir esta receita?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Deletar'),
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o dialog de confirmação
                await _authenticateAndDelete();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateRecipe() async {
    final sm = ScaffoldMessenger.of(context);
    Recipe? generateRecipe = await RecipeGeneratorService().getRecipe();

    if (generateRecipe == null) {
      Logger().e('Erro ao gerar receita');
      sm.showSnackBar(
        const SnackBar(
          content: Text("Erro ao gerar receita."),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _idController.text = generateRecipe.id;
      _titleController.text = generateRecipe.title;
      _descriptionController.text = generateRecipe.description;
      _scoreController.text = generateRecipe.score.toString();
      _preparationTimeController.text = generateRecipe.preparationTime;
      _ingredientListKey.currentState?.setIngredients(
        generateRecipe.ingredients,
      );
      _instructionListKey.currentState?.setInstructions(generateRecipe.steps);

      setState(() {
        _currentRecipe = generateRecipe;
        _currentDate = generateRecipe.date;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<RecipesProvider>(context, listen: false);
      _formKey.currentState!.save();

      final ingredientControllers = _ingredientListKey.currentState!;
      final instructionControllers = _instructionListKey.currentState!;

      final ingredients = List.generate(
        ingredientControllers.ingredientNameControllers.length,
        (i) => Ingredient(
          id: ingredientControllers.ingredientIds[i],
          name: ingredientControllers.ingredientNameControllers[i].text,
          quantity: ingredientControllers.ingredientQuantityControllers[i].text,
          recipeId: _idController.text,
        ),
      );

      final instructions = List.generate(
        instructionControllers.instructionDescriptionControllers.length,
        (i) => Instruction(
          id: instructionControllers.instructionIds[i],
          stepOrder: i + 1,
          description:
              instructionControllers.instructionDescriptionControllers[i].text,
          recipeId: _idController.text,
        ),
      );

      final updatedRecipe = Recipe(
        id: _idController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        score: double.tryParse(_scoreController.text) ?? 0,
        preparationTime: _preparationTimeController.text,
        ingredients: ingredients,
        steps: instructions,
        date: _getDate(),
      );
      final sm = ScaffoldMessenger.of(context);

      setState(() {
        _currentDate = updatedRecipe.date;
      });
      provider.addOrUpdateRecipe(updatedRecipe);

      sm.showSnackBar(
        const SnackBar(
          content: Text("Receita Salva."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Autentica o usuário usando biometria ou PIN/padrão/senha
  /// e, se bem-sucedido, deleta a receita.
  Future<void> _authenticateAndDelete() async {
    final authService = SecurityAuthRepository();

    // Solicita autenticação
    final result = await authService.authenticate(
      localizedReason: 'Autentique-se para deletar a receita',
      biometricOnly: false, // Permite biometria, PIN, padrão ou senha
      stickyAuth: true,
    );

    if (!mounted) return;

    switch (result) {
      case SecurityAuthResult.success:
        // Autenticação bem-sucedida, procede com a exclusão
        final provider = Provider.of<RecipesProvider>(context, listen: false);
        await provider.deleteRecipe(_idController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Receita deletada com sucesso."),
              duration: Duration(seconds: 2),
            ),
          );

          // Navega de volta para a tela inicial
          Navigator.popUntil(context, ModalRoute.withName(Routes.home));
        }
        break;

      case SecurityAuthResult.failed:
      case SecurityAuthResult.unavailable:
      case SecurityAuthResult.error:
        // Exibe mensagem de erro apropriada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.getResultMessage(result)),
            duration: const Duration(seconds: 3),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = (_currentRecipe?.title ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? RecipeScreenType.editRecipe : RecipeScreenType.newRecipe,
        ),
        actions: <Widget>[
          Visibility(
            visible: isEditing,
            child: TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text("Excluir"),
              style: TextButton.styleFrom(foregroundColor: AppColors.delete),
              onPressed: _confirmDeleteRecipe,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _generateRecipe,
                    label: const Text("Gerar Receita"),
                    icon: const Icon(Icons.draw_outlined),
                  ),
                  Text(
                    'Data: $_currentDate',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Por favor preencha o nome.'
                            : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextFormField(
                controller: _scoreController,
                decoration: const InputDecoration(labelText: 'Nota de 0 a 5'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Por favor preencha a nota.';
                  }
                  final score = double.tryParse(val);
                  if (score == null || score < 0 || score > 5) {
                    return 'A nota deve ser entre 0 e 5.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _preparationTimeController,
                decoration: const InputDecoration(
                  labelText: 'Tempo de Preparo',
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? 'Por favor preencha o tempo de preparo.'
                            : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: EditFormIngredientListWidget(
                  key: _ingredientListKey,
                  initialIngredients: _currentRecipe?.ingredients ?? [],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: EditFormInstructionListWidget(
                  key: _instructionListKey,
                  initialInstructions: _currentRecipe?.steps ?? [],
                ),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salvar Receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
