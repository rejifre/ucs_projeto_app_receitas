import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

/// Resultado da autenticação biométrica
enum SecurityAuthResult { success, failed, unavailable, error }

/// Repositório para gerenciar autenticação biométrica e de dispositivo
class SecurityAuthRepository {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Logger _logger = Logger();

  /// Verifica se o dispositivo suporta autenticação biométrica
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      _logger.e('Erro ao verificar suporte do dispositivo: $e');
      return false;
    }
  }

  /// Verifica se a biometria está disponível no dispositivo
  Future<bool> checkBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      _logger.e('Erro ao verificar disponibilidade de biometria: $e');
      return false;
    }
  }

  /// Obtém os tipos de biometria disponíveis
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      _logger.e('Erro ao obter biometrias disponíveis: $e');
      return <BiometricType>[];
    }
  }

  /// Verifica se autenticação está disponível (biometria ou PIN/padrão/senha)
  Future<bool> isAuthenticationAvailable() async {
    final isSupported = await isDeviceSupported();
    final canCheck = await checkBiometrics();
    return isSupported && canCheck;
  }

  /// Realiza autenticação com biometria ou PIN/padrão/senha
  /// [localizedReason] - Texto que aparece para o usuário explicando por que a autenticação é necessária
  /// [biometricOnly] - Se true, permite apenas biometria. Se false, permite também PIN/padrão/senha
  /// [stickyAuth] - Se true, mantém a solicitação de autenticação mesmo se o app sair de foco
  Future<SecurityAuthResult> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
    bool stickyAuth = true,
  }) async {
    try {
      // Verifica se a autenticação está disponível
      if (!await isAuthenticationAvailable()) {
        return SecurityAuthResult.unavailable;
      }

      // Solicita autenticação
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      return authenticated
          ? SecurityAuthResult.success
          : SecurityAuthResult.failed;
    } on PlatformException catch (e) {
      _logger.e('Erro durante autenticação: $e');
      return SecurityAuthResult.error;
    } catch (e) {
      _logger.e('Erro inesperado durante autenticação: $e');
      return SecurityAuthResult.error;
    }
  }

  /// Cancela a autenticação em andamento
  Future<bool> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      return true;
    } catch (e) {
      _logger.e('Erro ao cancelar autenticação: $e');
      return false;
    }
  }

  /// Obtém uma mensagem amigável baseada no resultado da autenticação
  String getResultMessage(SecurityAuthResult result) {
    switch (result) {
      case SecurityAuthResult.success:
        return 'Autenticação realizada com sucesso!';
      case SecurityAuthResult.failed:
        return 'Autenticação falhou ou foi cancelada.';
      case SecurityAuthResult.unavailable:
        return 'Autenticação biométrica não disponível neste dispositivo.';
      case SecurityAuthResult.error:
        return 'Erro durante a autenticação.';
    }
  }
}
