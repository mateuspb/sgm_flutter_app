import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mov_app/models/movimentacao.dart';

void main() {
  group('Movimentacao model', () {
    test('fromJson preenche campos com tipos seguros', () {
      final map = {
        'id': '10',
        'veiculo': 7,
        'cliente': '5',
        'peso_carregado': '123,45',
        'motorista': '3',
        'produto': 11,
        'observacoes': 'ok',
        'tipo_carga': 2,
        'situacao': 1,
        'assinatura_base64': '',
        'data_assinatura': '2025-10-10T10:00:00Z',
        'data_criacao': '2025-10-09T10:00:00Z',
        'cliente_nome': 'Cliente X',
        'produto_nome': 'Produto Y',
        'motorista_nome': 'Fulano',
        'veiculo_placa': 'ABC-1234',
        'tipo_carga_nome': 'A Granel',
        'situacao_nome': 'Aberta',
      };

      final m = Movimentacao.fromJson(map);

      expect(m.id, 10);
      expect(m.veiculo, 7);
      expect(m.cliente, 5);
      expect(m.pesoCarregado, closeTo(123.45, 0.001));
      expect(m.observacoes, 'ok');
      expect(m.tipoCarga, 2);
      expect(m.situacao, 1);
      expect(m.assinaturaBase64, '');
      expect(m.dataAssinatura, '2025-10-10T10:00:00Z');
      expect(m.clienteNome, 'Cliente X');
      expect(m.veiculoPlaca, 'ABC-1234');
    });

    test('toMap gera chaves corretas', () {
      final a = Movimentacao(
        id: 1,
        veiculo: 2,
        cliente: 3,
        pesoCarregado: 10.5,
        motorista: 4,
        produto: 5,
        observacoes: 'obs',
        tipoCarga: 6,
        situacao: 7,
        assinaturaBase64: 'b64',
        dataAssinatura: '2025-10-10',
        dataCriacao: '2025-10-09',
        clienteNome: 'Cli',
        produtoNome: 'Prod',
        motoristaNome: 'Mot',
        veiculoPlaca: 'AAA-0000',
        tipoCargaNome: 'Tipo',
        situacaoNome: 'Sit',
      );

      final map = a.toMap();

      expect(map['id'], 1);
      expect(map['veiculo'], 2);
      expect(map['cliente'], 3);
      expect(map['peso_carregado'], 10.5);
      expect(map['observacoes'], 'obs');
      expect(map['tipo_carga'], 6);
      expect(map['situacao'], 7);
      expect(map['assinatura_base64'], 'b64');
      expect(map['data_assinatura'], '2025-10-10');
      expect(map['cliente_nome'], 'Cli');
      expect(map['veiculo_placa'], 'AAA-0000');
    });
  });
}
