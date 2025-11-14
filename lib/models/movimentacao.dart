
double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.replaceAll(',', '.').trim();
    final d = double.tryParse(s);
    if (d != null) return d;
  }
  return 0.0;
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s.replaceAll(',', '.'));
    if (d != null) return d.toInt();
  }
  return 0;
}

String _asString(dynamic v) => v?.toString() ?? '';

class Movimentacao {
  final int id;
  final int veiculo;
  final int cliente;
  final double pesoCarregado;
  final int motorista;
  final int produto;
  final String? observacoes;
  final int tipoCarga;
  final int situacao;
  final String? assinaturaBase64;
  final String? dataAssinatura;
  final String dataCriacao;
  final String clienteNome;
  final String produtoNome;
  final String motoristaNome;
  final String veiculoPlaca;
  final String tipoCargaNome;
  final String situacaoNome;

  Movimentacao({
    required this.id,
    required this.veiculo,
    required this.cliente,
    required this.pesoCarregado,
    required this.motorista,
    required this.produto,
    required this.observacoes,
    required this.tipoCarga,
    required this.situacao,
    required this.assinaturaBase64,
    required this.dataAssinatura,
    required this.dataCriacao,
    required this.clienteNome,
    required this.produtoNome,
    required this.motoristaNome,
    required this.veiculoPlaca,
    required this.tipoCargaNome,
    required this.situacaoNome,
  });

  factory Movimentacao.fromJson(Map<String, dynamic> j) {
    return Movimentacao(
      id: _asInt(j['id']),
      veiculo: _asInt(j['veiculo']),
      cliente: _asInt(j['cliente']),
      pesoCarregado: _asDouble(j['peso_carregado']),
      motorista: _asInt(j['motorista']),
      produto: _asInt(j['produto']),
      observacoes: j['observacoes']?.toString(),
      tipoCarga: _asInt(j['tipo_carga']),
      situacao: _asInt(j['situacao'] ?? j['situicao']),
      assinaturaBase64: j['assinatura_base64']?.toString(),
      dataAssinatura: j['data_assinatura']?.toString(),
      dataCriacao: _asString(j['data_criacao']),
      clienteNome: _asString(j['cliente_nome']),
      produtoNome: _asString(j['produto_nome']),
      motoristaNome: _asString(j['motorista_nome']),
      veiculoPlaca: _asString(j['veiculo_placa']),
      tipoCargaNome: _asString(j['tipo_carga_nome']),
      situacaoNome: _asString(j['situacao_nome']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'veiculo': veiculo,
        'cliente': cliente,
        'peso_carregado': pesoCarregado,
        'motorista': motorista,
        'produto': produto,
        'observacoes': observacoes,
        'tipo_carga': tipoCarga,
        'situacao': situacao,
        'assinatura_base64': assinaturaBase64,
        'data_assinatura': dataAssinatura,
        'data_criacao': dataCriacao,
        'cliente_nome': clienteNome,
        'produto_nome': produtoNome,
        'motorista_nome': motoristaNome,
        'veiculo_placa': veiculoPlaca,
        'tipo_carga_nome': tipoCargaNome,
        'situacao_nome': situacaoNome,
      };
}
