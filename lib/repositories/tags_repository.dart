import 'package:logger/logger.dart';
import '../models/tag_model.dart';
import '../services/tag_service.dart';

class TagsRepository {
  final TagService _tagService = TagService();
  final logger = Logger();

  Future<void> saveTag(Tag tag) async {
    final existingTag = await getTagById(tag.id);

    if (existingTag == null) {
      await addTag(tag);
    } else {
      await updateTag(tag);
    }
  }

  Future<void> addTag(Tag tag) async {
    await _tagService.insert(tag);
    logger.i('added tag');
  }

  Future<void> updateTag(Tag tag) async {
    await _tagService.update(tag);
    logger.i('update tag');
  }

  Future<void> deleteTag(String tagId) async {
    await _tagService.delete(tagId);
    logger.i('Delete Tag');
  }

  Future<List<Tag>> getAllTags() async {
    final tags = await _tagService.getAll();
    logger.i('Get All Tags');
    logger.i(tags);
    return tags;
  }

  Future<Tag?> getTagById(String id) async {
    final data = await _tagService.getById(id);
    if (data != null) {
      return data;
    }
    return null;
  }

  Future<List<Tag>> filter(String query) async {
    final tags = await _tagService.searchByName(query);
    logger.i('Search Tags');
    logger.i(tags);
    return tags;
  }
}
