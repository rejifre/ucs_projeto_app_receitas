import 'package:logger/logger.dart';
import '../models/tag_model.dart';
import '../repositories/tag_repository.dart';

class TagsService {
  final TagRepository _tagRepo = TagRepository();
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
    await _tagRepo.insert(tag);
    logger.i('added tag');
  }

  Future<void> updateTag(Tag tag) async {
    await _tagRepo.update(tag);
    logger.i('update tag');
  }

  Future<void> deleteTag(String tagId) async {
    await _tagRepo.delete(tagId);
    logger.i('Delete Tag');
  }

  Future<List<Tag>> getAllTags() async {
    final tags = await _tagRepo.getAll();
    logger.i('Get All Tags');
    logger.i(tags);
    return tags;
  }

  Future<Tag?> getTagById(String id) async {
    final data = await _tagRepo.getById(id);
    if (data != null) {
      return data;
    }
    return null;
  }
}
