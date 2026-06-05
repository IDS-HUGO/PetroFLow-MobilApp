import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/app_user.dart';
import '../../../../core/providers/session_controller.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_view_model.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterViewModel>(
      create: (context) => RegisterViewModel(
        registerUseCase: context.read<RegisterUseCase>(),
        sessionController: context.read<SessionController>(),
      ),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Crear cuenta',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          onChanged: (value) => vm.fullName = value,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          onChanged: (value) => vm.email = value,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          onChanged: (value) => vm.password = value,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<UserRole>(
                          isExpanded: true,
                          initialValue: vm.role,
                          items:
                              const [
                                    UserRole.supervisor,
                                    UserRole.fieldEngineer,
                                  ]
                                  .map(
                                    (role) => DropdownMenuItem<UserRole>(
                                      value: role,
                                      child: Text(role.label),
                                    ),
                                  )
                                  .toList(growable: false),
                          onChanged: (value) => vm.role = value ?? vm.role,
                          decoration: const InputDecoration(
                            labelText: 'Rol',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            vm.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: vm.isSubmitting
                              ? null
                              : () async {
                                  await vm.register();
                                  if (context.mounted &&
                                      context
                                          .read<SessionController>()
                                          .isAuthenticated) {
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  }
                                },
                          child: vm.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Registrar usuario'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Volver al login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
