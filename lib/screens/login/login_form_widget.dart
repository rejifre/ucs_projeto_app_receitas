import 'package:flutter/material.dart';
import 'package:ucs_projeto_app_receitas/repositories/login_repository.dart';
import 'package:ucs_projeto_app_receitas/ui/app_colors.dart';

class LoginFormWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginFormWidget({super.key, this.onLoginSuccess});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final LoginRepository _loginRepository = LoginRepository();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Login
        await _loginRepository.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _showSnackBar('Login realizado com sucesso!');
      } else {
        // Cadastro
        await _loginRepository.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        _showSnackBar('Conta criada com sucesso!');
      }

      // Chama o callback de sucesso
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
      //_showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Digite seu e-mail para redefinir a senha', isError: true);
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _loginRepository.resetPassword(_emailController.text.trim());
      _showSnackBar(
        'E-mail de recuperação enviado! Verifique sua caixa de entrada.',
      );
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.backgroundColor),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Logo ou título
                      Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: AppColors.buttonMainColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin ? 'Login' : 'Criar Conta',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Campo Nome (apenas para cadastro)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameController,
                          key: const ValueKey('name'),
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (!_isLogin &&
                                (value == null || value.trim().length < 2)) {
                              return 'Nome deve ter pelo menos 2 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Campo E-mail
                      TextFormField(
                        controller: _emailController,
                        key: const ValueKey('email'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Endereço de E-mail',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira um e-mail.';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Por favor, insira um endereço de e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Senha
                      TextFormField(
                        controller: _passwordController,
                        key: const ValueKey('password'),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres.';
                          }
                          return null;
                        },
                      ),

                      // Mensagem de erro
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Botão principal
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submitAuthForm,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isLogin ? 'Entrar' : 'Criar Conta',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Botão para alternar entre login e cadastro
                      if (!_isLoading)
                        TextButton(
                          onPressed: () {
                            if (!mounted) return;

                            setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                              // Limpar campos ao alternar
                              _nameController.clear();
                              _emailController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Não tem uma conta? Criar conta'
                                : 'Já tem uma conta? Fazer login',
                          ),
                        ),

                      // Botão de esqueceu a senha (apenas no login)
                      if (_isLogin && !_isLoading) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _resetPassword,
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
