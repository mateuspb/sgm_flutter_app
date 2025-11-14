import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../services/api_client.dart';
import '../db/local_db.dart';

class SignPage extends StatefulWidget {
  final int movId;
  final String titulo;

  const SignPage({super.key, required this.movId, required this.titulo});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.white,
  );
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça a assinatura antes de enviar.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final bytes = await _controller.toPngBytes();
      if (bytes == null) throw Exception('Falha ao renderizar assinatura');
      final b64 = base64Encode(bytes);
      final dio = ApiClient().dioWithAuth(context);
      final url = '/api/v1/movimentacoes/${widget.movId}/assinar/';
      final now = DateTime.now().toIso8601String();
      await dio
          .patch(url, data: {'assinatura_base64': b64, 'data_assinatura': now});
      // Atualiza local e oculta da lista pendente (pois agora tem assinatura_base64)
      await LocalDB().setLocalAssinatura(widget.movId, b64, now);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assinatura enviada com sucesso!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      // Sem conexão? Enfileira offline
      final now = DateTime.now().toIso8601String();
      final bytes = await _controller.toPngBytes();
      if (bytes != null) {
        final b64 = base64Encode(bytes);
        await LocalDB().queueSignature(widget.movId, b64, now);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Sem conexão. Assinatura salva offline. ($e)')),
        );
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assinar • ${widget.titulo}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _controller.clear,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Limpar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _sending ? null : _enviar,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
