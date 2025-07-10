import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tags_provider.dart';
import '../../routes/routes.dart';
import '../../ui/app_colors.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final tagsProvider = Provider.of<TagsProvider>(context);
    final tags = tagsProvider.tags;

    // Filtra as tags pelo texto digitado
    final filteredTags =
        tags
            .where(
              (tag) => tag.name.toLowerCase().contains(_search.toLowerCase()),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.buttonMainColor,
        tooltip: 'Adicionar Tag',
        onPressed: () {
          Navigator.pushNamed(context, Routes.editTag, arguments: null);
        },
        child: const Icon(Icons.add, color: AppColors.backgroundColor),
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(10)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar tags...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
          ),
          Expanded(
            child:
                filteredTags.isEmpty
                    ? const Center(child: Text('Nenhuma tag encontrada.'))
                    : ListView.builder(
                      itemCount: filteredTags.length,
                      itemBuilder: (context, index) {
                        final tag = filteredTags[index];
                        return Card(
                          color: Theme.of(context).primaryColor,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              tag.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            trailing: Icon(Icons.label, color: Colors.white),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.editTag,
                                arguments: tag,
                              );
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
