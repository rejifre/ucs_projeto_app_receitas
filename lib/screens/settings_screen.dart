import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/categories_provider.dart'; // Adicione este import
import '../providers/tags_provider.dart';
import '../repositories/backup_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// TODO: REFATORAR ESSE PESADELO
class _SettingsScreenState extends State<SettingsScreen> {
  final BackupRepository _backupRepository = BackupRepository();

  // Substitua o plugin por uma variável global, se preferir
  final localNotifications = FlutterLocalNotificationsPlugin();

  bool _isLoading = false;
  String? _statusMessage;
  Map<String, dynamic>? _backupStatus;

  @override
  void initState() {
    super.initState();
    configurarNotificacaoLocal();
    _loadBackupStatus();
  }

  Future<void> configurarNotificacaoLocal() async {
    const AndroidInitializationSettings cfgAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const cfgiOs = DarwinInitializationSettings();

    var initializationSettings = const InitializationSettings(
      android: cfgAndroid,
      iOS: cfgiOs,
    );

    await localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notifiocationResponse,
    );
  }

  void notifiocationResponse(NotificationResponse details) {
    // Aqui você pode tratar o clique na notificação, se desejar
    // Exemplo: print('Notificação clicada: ${details.payload}');
  }

  Future<void> _showNotification(
    String title,
    String body, {
    bool isError = false,
  }) async {
    await localNotifications.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'backup_channel',
          'Backup Notificações',
          importance: Importance.max,
          priority: Priority.high,
          color: isError ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> _loadBackupStatus() async {
    setState(() => _isLoading = true);

    try {
      final status = await _backupRepository.getBackupStatus();
      setState(() {
        _backupStatus = status;
        _statusMessage = 'Status atualizado com sucesso';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Erro ao carregar status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showMessage(String message, {bool isError = false}) async {
    setState(() => _statusMessage = message);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _backupToLocalFile() async {
    setState(() => _isLoading = true);

    try {
      final success = await _backupRepository.backupToLocalFile();

      await _showMessage(
        success
            ? 'Backup local realizado com sucesso!'
            : 'Backup local falhou ou foi cancelado',
        isError: !success,
      );
      await _showNotification(
        'Backup Local',
        success
            ? 'Backup local realizado com sucesso!'
            : 'Backup local falhou ou foi cancelado',
        isError: !success,
      );
    } catch (e) {
      await _showMessage('Erro no backup local: $e', isError: true);
      await _showNotification(
        'Backup Local',
        'Erro no backup local: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectAndRestore() async {
    setState(() => _isLoading = true);

    try {
      final success = await _backupRepository.selectAndRestoreFromFile();
      await _showMessage(
        success
            ? 'Restauração realizada com sucesso!'
            : 'Restauração falhou ou foi cancelada',
        isError: !success,
      );
      await _showNotification(
        'Restauração Local',
        success
            ? 'Restauração realizada com sucesso!'
            : 'Restauração falhou ou foi cancelada',
        isError: !success,
      );

      if (success) {
        updateProviders(); // Atualiza as receitas no provider
        await _loadBackupStatus(); // Atualiza status após restauração
      }
    } catch (e) {
      await _showMessage('Erro na restauração: $e', isError: true);
      await _showNotification(
        'Restauração Local',
        'Erro na restauração: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  updateProviders() {
    // Atualiza as receitas no provider
    Provider.of<RecipesProvider>(context, listen: false).loadRecipes();
    // Atualiza as categorias no provider
    Provider.of<CategoriesProvider>(context, listen: false).loadCategories();
    // Atualiza as tags no provider (se necessário)
    Provider.of<TagsProvider>(context, listen: false).loadTags();
  }

  Future<void> _backupToFirestore() async {
    setState(() => _isLoading = true);

    try {
      final success = await _backupRepository.backupToFirestore();
      await _showMessage(
        success
            ? 'Backup no Firestore realizado com sucesso!'
            : 'Backup no Firestore falhou',
        isError: !success,
      );
      await _showNotification(
        'Backup Firestore',
        success
            ? 'Backup no Firestore realizado com sucesso!'
            : 'Backup no Firestore falhou',
        isError: !success,
      );

      if (success) {
        await _loadBackupStatus(); // Atualiza status após backup
      }
    } catch (e) {
      await _showMessage('Erro no backup Firestore: $e', isError: true);
      await _showNotification(
        'Backup Firestore',
        'Erro no backup Firestore: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromFirestore() async {
    setState(() => _isLoading = true);

    try {
      final success = await _backupRepository.restoreFromFirestore();
      await _showMessage(
        success
            ? 'Restauração do Firestore realizada com sucesso!'
            : 'Restauração do Firestore falhou',
        isError: !success,
      );
      await _showNotification(
        'Restauração Firestore',
        success
            ? 'Restauração do Firestore realizada com sucesso!'
            : 'Restauração do Firestore falhou',
        isError: !success,
      );

      if (success) {
        updateProviders(); // Atualiza as receitas no provider
        await _loadBackupStatus(); // Atualiza status após restauração
      }
    } catch (e) {
      await _showMessage('Erro na restauração Firestore: $e', isError: true);
      await _showNotification(
        'Restauração Firestore',
        'Erro na restauração Firestore: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFirestoreBackup() async {
    // Confirma a ação
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Deleção'),
            content: const Text(
              'Tem certeza que deseja deletar o backup do Firestore? Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Deletar'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await _backupRepository.deleteFirestoreBackup();
      await _showMessage(
        success
            ? 'Backup do Firestore deletado com sucesso!'
            : 'Falha ao deletar backup do Firestore',
        isError: !success,
      );
      await _showNotification(
        'Deletar Backup Firestore',
        success
            ? 'Backup do Firestore deletado com sucesso!'
            : 'Falha ao deletar backup do Firestore',
        isError: !success,
      );

      if (success) {
        await _loadBackupStatus(); // Atualiza status após deleção
      }
    } catch (e) {
      await _showMessage('Erro ao deletar backup: $e', isError: true);
      await _showNotification(
        'Deletar Backup Firestore',
        'Erro ao deletar backup: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _backupToAll() async {
    setState(() => _isLoading = true);

    try {
      final results = await _backupRepository.backupToAll();
      final localSuccess = results['local'] ?? false;
      final firestoreSuccess = results['firestore'] ?? false;

      String message;
      bool isError = false;

      if (localSuccess && firestoreSuccess) {
        message = 'Backup completo realizado com sucesso!';
      } else if (localSuccess || firestoreSuccess) {
        message =
            'Backup parcial: Local=${localSuccess ? 'OK' : 'Falhou'}, Firestore=${firestoreSuccess ? 'OK' : 'Falhou'}';
        isError = true;
      } else {
        message = 'Backup completo falhou';
        isError = true;
      }

      await _showMessage(message, isError: isError);
      await _showNotification('Backup Completo', message, isError: isError);
      await _loadBackupStatus(); // Atualiza status
    } catch (e) {
      await _showMessage('Erro no backup completo: $e', isError: true);
      await _showNotification(
        'Backup Completo',
        'Erro no backup completo: $e',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBackupStatus,
            tooltip: 'Atualizar Status',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status dos Backups',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_backupStatus != null) ...[
                              Text(
                                'Firestore: ${_backupStatus!['firestore']['available'] ? 'Disponível' : 'Não disponível'}',
                              ),
                              if (_backupStatus!['firestore']['info'] != null)
                                Text(
                                  'Última atualização: ${_backupStatus!['firestore']['info']['timestamp'] ?? 'N/A'}',
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Verificado em: ${_backupStatus!['lastChecked']}',
                              ),
                            ],
                            if (_statusMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _statusMessage!,
                                style: TextStyle(
                                  color:
                                      _statusMessage!.contains('Erro')
                                          ? Colors.red
                                          : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Backup Local Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backup Local',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Salva dados em arquivo no dispositivo'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _backupToLocalFile,
                                    icon: const Icon(Icons.download),
                                    label: const Text('Fazer Backup'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _selectAndRestore,
                                    icon: const Icon(Icons.upload),
                                    label: const Text('Restaurar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Backup Firestore Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backup Firestore',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Salva dados na nuvem (requer login)'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _backupToFirestore,
                                    icon: const Icon(Icons.cloud_upload),
                                    label: const Text('Backup'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : _restoreFromFirestore,
                                    icon: const Icon(Icons.cloud_download),
                                    label: const Text('Restaurar'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _deleteFirestoreBackup,
                              icon: const Icon(Icons.delete),
                              label: const Text('Deletar Backup da Nuvem'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Backup Completo Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Backup Completo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Faz backup local e na nuvem simultaneamente',
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _backupToAll,
                                icon: const Icon(Icons.backup),
                                label: const Text('Backup Completo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
