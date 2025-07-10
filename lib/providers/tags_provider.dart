import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../repositories/tags_repository.dart';

class TagsProvider with ChangeNotifier {
  final TagsRepository _service = TagsRepository();
  List<Tag> _tags = [];

  List<Tag> get tags => _tags;

  TagsProvider() {
    loadTags();
  }

  Future<void> loadTags() async {
    _tags = await _service.getAllTags();
    notifyListeners();
  }

  Future<void> deleteTag(String id) async {
    await _service.deleteTag(id);
    await loadTags(); // Atualiza a lista
  }

  Future<void> addOrUpdateTag(Tag tag) async {
    if (_tags.any((c) => c.id == tag.id)) {
      // Se a tag já existe, atualiza-a
      await _service.updateTag(tag);
    } else {
      // Caso contrário, adiciona uma nova tag
      await _service.addTag(tag);
    }
    await loadTags();
  }

  Future<Tag?> getTagById(String id) async {
    return await _service.getTagById(id);
  }

  Future<List<Tag>> searchTags(String query) async {
    _tags = await _service.filter(query);
    notifyListeners();
    return _tags;
  }
}
