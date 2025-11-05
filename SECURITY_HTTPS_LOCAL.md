# 🔐 Segurança: HTTPS para Comunicação Local

## Por que criptografar PWA ↔ Agente em localhost?

### Vetores de Ataque em Localhost:
1. **Ferramentas de captura**: Wireshark, Fiddler, Burp Suite
2. **Malware**: Trojans bancários, keyloggers
3. **Browser comprometido**: Extensões maliciosas
4. **DevTools aberto**: Network tab expõe dados sensíveis

### Dados Sensíveis Expostos:
- CPF/CNPJ de clientes
- Valores de transações
- Tokens de autenticação
- Dados de cartão (se houver)

---

## 🚀 Implementação com mkcert

### 1. Instalar mkcert

#### Windows (PowerShell como Admin):
```powershell
# Via Chocolatey
choco install mkcert

# Ou via Scoop
scoop bucket add extras
scoop install mkcert

# Ou download direto
# https://github.com/FiloSottile/mkcert/releases
```

#### Instalar CA raiz:
```powershell
mkcert -install
```

### 2. Gerar Certificados para Localhost

```powershell
cd C:\Users\Guilherme Batista\Solis

# Criar diretório para certificados
mkdir certs

cd certs

# Gerar certificado para localhost
mkcert localhost 127.0.0.1 ::1

# Vai gerar:
# - localhost+2.pem (certificado)
# - localhost+2-key.pem (chave privada)
```

---

## 🔧 Configuração dos Componentes

### A. Agente PDV (.NET) - HTTPS

#### 1. Atualizar `appsettings.json`:

```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://localhost:5000"
      },
      "Https": {
        "Url": "https://localhost:5001",
        "Certificate": {
          "Path": "C:/Users/Guilherme Batista/Solis/certs/localhost+2.pem",
          "KeyPath": "C:/Users/Guilherme Batista/Solis/certs/localhost+2-key.pem"
        }
      }
    }
  }
}
```

#### 2. Atualizar `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Configurar HTTPS
builder.WebHost.ConfigureKestrel(serverOptions =>
{
    serverOptions.ConfigureHttpsDefaults(httpsOptions =>
    {
        // Aceitar certificados mkcert
        httpsOptions.SslProtocols = System.Security.Authentication.SslProtocols.Tls12 | 
                                   System.Security.Authentication.SslProtocols.Tls13;
    });
});

// Forçar HTTPS redirect (OPCIONAL - pode quebrar localhost HTTP)
// app.UseHttpsRedirection();
```

### B. PWA (Vite) - Cliente HTTPS

#### 1. Atualizar `vite.config.ts`:

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import fs from 'fs'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  server: {
    https: {
      key: fs.readFileSync(path.resolve(__dirname, '../certs/localhost+2-key.pem')),
      cert: fs.readFileSync(path.resolve(__dirname, '../certs/localhost+2.pem'))
    },
    port: 3001
  }
})
```

#### 2. Atualizar variáveis de ambiente `.env`:

```bash
# Mudar HTTP para HTTPS
VITE_AGENTE_API_URL=https://localhost:5001
VITE_SOLIS_API_URL=https://localhost:3000
```

#### 3. Atualizar `lib/api.ts`:

```typescript
const AGENTE_PDV_URL = import.meta.env.VITE_AGENTE_PDV_URL || 'https://localhost:5001'

// Configurar axios para aceitar certificados localhost
export const agenteApi = axios.create({
  baseURL: AGENTE_PDV_URL,
  httpsAgent: new https.Agent({  
    rejectUnauthorized: false // Apenas para desenvolvimento local
  })
})
```

---

## 🔐 Segurança Adicional: Criptografia de Payload

### Além do HTTPS, criptografar dados sensíveis:

#### 1. Instalar crypto no PWA:

```bash
npm install crypto-js
npm install @types/crypto-js -D
```

#### 2. Criar serviço de criptografia:

```typescript
// lib/crypto.service.ts
import CryptoJS from 'crypto-js'

const SECRET_KEY = import.meta.env.VITE_CRYPTO_SECRET || 'your-secret-key'

export class CryptoService {
  static encrypt(data: any): string {
    const jsonString = JSON.stringify(data)
    return CryptoJS.AES.encrypt(jsonString, SECRET_KEY).toString()
  }

  static decrypt(encrypted: string): any {
    const bytes = CryptoJS.AES.decrypt(encrypted, SECRET_KEY)
    const jsonString = bytes.toString(CryptoJS.enc.Utf8)
    return JSON.parse(jsonString)
  }

  // Hash de dados sensíveis (CPF, etc)
  static hash(value: string): string {
    return CryptoJS.SHA256(value).toString()
  }
}
```

#### 3. Usar na comunicação:

```typescript
// Enviar dados criptografados
const payload = CryptoService.encrypt({
  clienteCpf: '123.456.789-00',
  valorTotal: 150.00
})

await axios.post('/api/vendas', { encrypted: payload })
```

#### 4. Descriptografar no Agente:

```csharp
// Services/CryptoService.cs
using System.Security.Cryptography;
using System.Text;

public class CryptoService
{
    private readonly string _secretKey;

    public CryptoService(IConfiguration config)
    {
        _secretKey = config["CryptoSecret"] ?? "your-secret-key";
    }

    public string Decrypt(string encrypted)
    {
        // Implementar AES decrypt compatível com crypto-js
        // ...
    }
}
```

---

## 📋 Checklist de Segurança

### Nível 1: HTTPS (OBRIGATÓRIO)
- [ ] mkcert instalado e CA raiz adicionada
- [ ] Certificados gerados para localhost
- [ ] Agente configurado para HTTPS (porta 5001)
- [ ] PWA configurado para HTTPS (porta 3001)
- [ ] Variáveis de ambiente atualizadas

### Nível 2: Criptografia de Payload (RECOMENDADO)
- [ ] crypto-js instalado no PWA
- [ ] Serviço de criptografia criado
- [ ] Dados sensíveis criptografados antes do envio
- [ ] Agente descriptografa corretamente

### Nível 3: Outras Camadas (OPCIONAL)
- [ ] Rate limiting implementado
- [ ] Validação de origem (localhost apenas)
- [ ] Token JWT com expiração curta
- [ ] Logs de auditoria
- [ ] CORS restritivo

---

## 🧪 Testes

### Verificar HTTPS funcionando:

```powershell
# Testar Agente
curl https://localhost:5001/api/health

# Testar PWA
Start-Process "https://localhost:3001"
```

### Testar com Wireshark:

1. Capturar interface loopback
2. Filtro: `tcp.port == 5001`
3. Verificar que payload é criptografado (TLS)

---

## 🎯 Recomendação Final

### Desenvolvimento:
✅ **HTTPS com mkcert** - Simples e eficaz

### Produção:
✅ **HTTPS + Criptografia de Payload** - Defesa em profundidade
✅ **Certificado válido** (Let's Encrypt se exposto)
✅ **Monitoramento de segurança**

---

## 📚 Referências

- [mkcert](https://github.com/FiloSottile/mkcert)
- [OWASP Transport Layer Protection](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)
- [LGPD - Lei Geral de Proteção de Dados](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)
- [PCI-DSS Requirements](https://www.pcisecuritystandards.org/)

---

**Status**: 🟡 A IMPLEMENTAR  
**Prioridade**: 🔴 ALTA  
**Esforço**: 2-4 horas
