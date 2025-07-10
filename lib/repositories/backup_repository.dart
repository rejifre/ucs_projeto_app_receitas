import 'package:logger/logger.dart';
import '../services/backup/backup_firebase_service.dart';
import '../services/backup/backup_local_service.dart';

/// Repository central para operações de backup e restore

class BackupRepository {
  final BackupLocalService _backupLocalService;
  final BackupFirebaseService _backupFirebaseService;
  final Logger _logger;

  BackupRepository({
    BackupLocalService? backupLocalService,
    BackupFirebaseService? backupFirebaseService,
    Logger? logger,
  }) : _backupLocalService = backupLocalService ?? BackupLocalService(),
       _backupFirebaseService =
           backupFirebaseService ?? BackupFirebaseService(),
       _logger = logger ?? Logger();

  // ==================== BACKUP LOCAL ====================

  /// Faz backup completo dos dados para um arquivo local
  /// Abre um seletor de arquivo para o usuário escolher onde salvar
  /// o backup em formato JSON.
  /// Returns: `true` se o backup foi realizado com sucesso, `false` caso contrário
  Future<bool> backupToLocalFile() async {
    try {
      final result = await _backupLocalService.backupToFile();
      return result;
    } catch (e) {
      _logger.e('Erro no repository ao fazer backup local: $e');
      return false;
    }
  }

  /// Restaura dados de um arquivo local específico
  /// [filePath] - Caminho absoluto para o arquivo de backup
  /// Returns: `true` se a restauração foi realizada com sucesso, `false` caso contrário
  Future<bool> restoreFromLocalFile(String filePath) async {
    try {
      final result = await _backupLocalService.restoreFromLocalFile(filePath);
      return result;
    } catch (e) {
      _logger.e('Erro no repository ao restaurar arquivo local: $e');
      return false;
    }
  }

  /// Permite ao usuário selecionar e restaurar um arquivo de backup
  /// Abre um seletor de arquivo para o usuário escolher o arquivo
  /// de backup a ser restaurado.
  /// Returns: `true` se a restauração foi realizada com sucesso, `false` caso contrário
  Future<bool> selectAndRestoreFromFile() async {
    try {
      final result = await _backupLocalService.selectAndRestoreFromFile();

      return result;
    } catch (e) {
      _logger.e('Erro no repository ao selecionar e restaurar arquivo: $e');
      return false;
    }
  }

  // ==================== BACKUP FIRESTORE ====================

  /// Faz backup completo dos dados para o Firestore
  /// Salva todos os dados do usuário no Firestore, organizados por tipo
  /// (receitas, categorias, tags, ingredientes, instruções).
  /// Requer usuário autenticado.
  /// Returns: `true` se o backup foi realizado com sucesso, `false` caso contrário
  Future<bool> backupToFirestore() async {
    try {
      final result = await _backupFirebaseService.backupToFirestore();
      return result;
    } catch (e) {
      _logger.e('Erro no repository ao fazer backup no Firestore: $e');
      return false;
    }
  }

  /// Restaura dados do Firestore
  /// Busca e restaura todos os dados salvos no Firestore para o banco local.
  /// Limpa os dados locais antes da restauração.
  /// Requer usuário autenticado.
  /// Returns: `true` se a restauração foi realizada com sucesso, `false` caso contrário
  Future<bool> restoreFromFirestore() async {
    try {
      final result = await _backupFirebaseService.restoreFromFirestore();
      return result;
    } catch (e) {
      _logger.e('Erro no repository ao restaurar do Firestore: $e');
      return false;
    }
  }

  /// Verifica se existe backup no Firestore e retorna informações sobre ele
  /// Returns: Mapa com informações do backup (versão, data, contadores) ou `null` se não existir
  Future<Map<String, dynamic>?> getFirestoreBackupInfo() async {
    try {
      final result = await _backupFirebaseService.getFirestoreBackupInfo();
      return result;
    } catch (e) {
      _logger.e('Erro no repository ao verificar backup no Firestore: $e');
      return null;
    }
  }

  /// Verifica se existe backup disponível no Firestore
  /// Returns: `true` se existe backup, `false` caso contrário
  Future<bool> hasFirestoreBackup() async {
    try {
      final backupInfo = await getFirestoreBackupInfo();
      return backupInfo != null;
    } catch (e) {
      _logger.e('Erro ao verificar existência de backup no Firestore: $e');
      return false;
    }
  }

  /// Deleta o backup do Firestore
  /// Remove todos os dados de backup salvos no Firestore para o usuário atual.
  /// Requer usuário autenticado.
  /// Returns: `true` se a deleção foi realizada com sucesso, `false` caso contrário
  Future<bool> deleteFirestoreBackup() async {
    try {
      final result = await _backupFirebaseService.deleteFirestoreBackup();
      return result;
    } catch (e) {
      _logger.e('Erro no repository ao deletar backup do Firestore: $e');
      return false;
    }
  }

  // ==================== MÉTODOS UTILITÁRIOS ====================

  /// Retorna um resumo do status dos backups disponíveis
  /// Returns: Mapa com informações sobre backups locais e Firestore
  Future<Map<String, dynamic>> getBackupStatus() async {
    try {
      _logger.i('Coletando status dos backups...');

      // Verifica backup no Firestore
      final firestoreBackupInfo = await getFirestoreBackupInfo();
      final hasFirestore = firestoreBackupInfo != null;

      final status = {
        'firestore': {'available': hasFirestore, 'info': firestoreBackupInfo},
        'local': {'note': 'Backup local requer seleção manual de arquivo'},
        'lastChecked': DateTime.now().toIso8601String(),
      };

      _logger.i('Status dos backups coletado com sucesso.');
      return status;
    } catch (e) {
      _logger.e('Erro ao coletar status dos backups: $e');
      return {
        'error': 'Erro ao verificar status dos backups: $e',
        'lastChecked': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Executa backup completo para todas as opções disponíveis
  /// Faz backup tanto local quanto para Firestore.
  /// Returns: Mapa com resultado de cada operação de backup
  Future<Map<String, bool>> backupToAll() async {
    try {
      _logger.i('Iniciando backup completo (local + Firestore)...');

      final results = <String, bool>{};

      // Backup local
      results['local'] = await backupToLocalFile();

      // Backup Firestore
      results['firestore'] = await backupToFirestore();

      final success = results.values.every((result) => result);
      if (success) {
        _logger.i('Backup completo realizado com sucesso em todas as opções.');
      } else {
        _logger.w('Backup completo concluído com algumas falhas: $results');
      }

      return results;
    } catch (e) {
      _logger.e('Erro durante backup completo: $e');
      return {'local': false, 'firestore': false};
    }
  }
}
