// ignore_for_file: public_member_api_docs, sort_constructors_first
// services/backup_restore_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Importa o file_picker
import 'package:logger/web.dart';
import 'backup/backup_local_service.dart';

class FilePickerService {
  final Logger _logger = Logger();
  final BackupLocalService _backupLocalService = BackupLocalService();

  FilePickerService();

  // Restauração de Arquivo Local (usando FilePicker para selecionar)
  Future<bool> restoreFromFile(String? filePath) async {
    if (filePath == null) {
      _logger.e('Caminho do arquivo de restauração não fornecido.');
      return false;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.e('Arquivo de backup não encontrado no caminho: $filePath');
        return false;
      }

      final String jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      // Verifica se é um backup completo ou apenas receitas (compatibilidade)
      if (backupData.containsKey('data')) {
        // Backup completo
        await _backupLocalService.restoreCompleteBackup(backupData);
      }

      _logger.i('Restauração de arquivo local concluída do caminho: $filePath');
      return true;
    } catch (e) {
      _logger.e('Erro ao restaurar de arquivo: $e');
      return false;
    }
  }

  // Método auxiliar para seleção de arquivo de restauração
  Future<bool> selectAndRestoreFromFile() async {
    try {
      // Abre o seletor de arquivos para o usuário escolher o arquivo de backup
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione o arquivo de backup para restaurar',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _logger.i('Seleção de arquivo de restauração cancelada.');
        return false;
      }

      final filePath = result.files.first.path;
      return await restoreFromFile(filePath);
    } catch (e) {
      _logger.e('Erro ao selecionar e restaurar arquivo: $e');
      return false;
    }
  }
}
