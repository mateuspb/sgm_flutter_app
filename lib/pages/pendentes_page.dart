import 'package:flutter/material.dart';
import '../db/local_db.dart';
import 'sign_page.dart';

class PendentesPage extends StatefulWidget {
  const PendentesPage({super.key});

  @override
  State<PendentesPage> createState() => _PendentesPageState();
}

class _PendentesPageState extends State<PendentesPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await LocalDB().listPendentes();
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendentes (local)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Sem itens pendentes.'))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final m = _items[i];
                    return ListTile(
                      onTap: () async {
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => SignPage(
                              movId: m['id'] as int,
                              titulo: 'Comprovante #${m['id']}',
                            ),
                          ),
                        );
                        await _load();
                      },
                      leading: const Icon(Icons.description_outlined),
                      title: Text(
                          'Comprovante #${m['id']} • ${m['cliente_nome']}'),
                      subtitle: Text(
                          'Placa: ${m['veiculo_placa']} • Produto: ${m['produto_nome']}'),
                      trailing: const Icon(Icons.edit),
                    );
                  },
                ),
    );
  }
}
