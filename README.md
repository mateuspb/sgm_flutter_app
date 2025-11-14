# Flutter Mov App (pendentes filtrados)

- Login com Simple JWT
- Sincroniza pendentes (`/api/v1/movimentacoes/assinaturas-pendentes/`)
- **Assinar** (`PATCH /api/v1/movimentacoes/{id}/assinar/` com `assinatura_base64`)
- Salva localmente; lista **somente pendentes** (sem `assinatura_base64`)
- Fila offline de assinaturas + botão para reenviar
- Parse numérico robusto (strings com vírgula/ponto)

## Rodar
```bash
flutter create .
flutter pub get
flutter run
```
Base URL: `lib/services/api_client.dart` (padrão `http://10.0.2.2:8000`).
