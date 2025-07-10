import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tag_model.dart';
import '../../providers/tags_provider.dart';

// --- Widget de Gerenciamento de Tags ---
class EditFormTagsWidget extends StatefulWidget {
  final List<String> initialTagIds; // IDs das tags já selecionadas
  final ValueChanged<List<String>>
  onTagsChanged; // Callback para retornar a lista de IDs de tags

  const EditFormTagsWidget({
    super.key,
    required this.initialTagIds,
    required this.onTagsChanged,
  });

  @override
  State<EditFormTagsWidget> createState() => EditFormTagsWidgetState();
}

class EditFormTagsWidgetState extends State<EditFormTagsWidget> {
  late List<String> selectedTagIds = [];
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedTagIds = List.from(widget.initialTagIds);
  }

  void _removeTag(String tagId) {
    setState(() {
      selectedTagIds.remove(tagId);
      widget.onTagsChanged(selectedTagIds);
    });
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  void setTags(List<String> list) {
    setState(() {
      selectedTagIds = list;
      widget.onTagsChanged(selectedTagIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagsProvider = Provider.of<TagsProvider>(context);
    final List<Tag> availableTags = tagsProvider.tags;

    // Para múltipla escolha, use showModalBottomSheet com CheckboxListTile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags da Receita', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('Selecionar Tags'),
            onPressed: () async {
              final result = await showModalBottomSheet<List<String>>(
                context: context,
                builder: (context) {
                  List<String> tempSelected = List.from(selectedTagIds);
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
                                  availableTags.map((tag) {
                                    return CheckboxListTile(
                                      value: tempSelected.contains(tag.id),
                                      title: Text(tag.name),
                                      onChanged: (checked) {
                                        setModalState(() {
                                          if (checked == true) {
                                            tempSelected.add(tag.id);
                                          } else {
                                            tempSelected.remove(tag.id);
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
                  selectedTagIds = result;
                  widget.onTagsChanged(selectedTagIds);
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
              selectedTagIds.isEmpty
                  ? [const Text('Nenhuma tag adicionada.')]
                  : selectedTagIds.map((tagId) {
                    final tag = availableTags.firstWhere(
                      (t) => t.id == tagId,
                      orElse: () => Tag(id: tagId, name: 'Tag Desconhecida'),
                    );
                    return Chip(
                      label: Text(tag.name),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeTag(tag.id),
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
