import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mov_app/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../db/local_db.dart';
import '../models/movimentacao.dart';
import 'pendentes_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _syncPendentes(BuildContext context) async {
    final dio = ApiClient().dioWithAuth(context);
    final db = LocalDB();
    try {
      final res = await dio.get('/api/v1/movimentacoes/assinaturas-pendentes/');
      final list = (res.data as List).cast<Map<String, dynamic>>();
      final parsed = list.map((j) => Movimentacao.fromJson(j).toMap()).toList();
      await db.upsertMovs(parsed);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronização concluída!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Sem conexão com o servidor.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro na sincronização: $e')),
          );
        }
      }
    }
  }

  Future<void> _sendOfflineQueue(BuildContext context) async {
    final dio = ApiClient().dioWithAuth(context);
    final db = LocalDB();
    final queued = await db.listQueued();
    if (queued.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não há assinaturas offline na fila.')),
        );
      }
      return;
    }
    int ok = 0, fail = 0;
    for (final item in queued) {
      final id = item['mov_id'] as int;
      final b64 = item['assinatura_base64'] as String;
      final dataAss = item['data_assinatura'] as String;
      try {
        final url = '/api/v1/movimentacoes/$id/assinar/';
        await dio.patch(url,
            data: {'assinatura_base64': b64, 'data_assinatura': dataAss});
        await db.setLocalAssinatura(id, b64, dataAss);
        await db.removeQueued(id);
        ok++;
      } catch (e) {
        fail++;
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fila enviada: $ok sucesso(s), $fail erro(s).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await context.read<AuthService>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text('Sincronizar pendentes'),
                    onPressed: () => _syncPendentes(context),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.storage),
                    label: const Text('Listar pendentes'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PendentesPage()),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.drive_folder_upload),
                    label: const Text('Enviar assinaturas offline'),
                    onPressed: () => _sendOfflineQueue(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
