 # Desafio Técnico - Backend
## Pessoa Desenvolvedora Júnior/Pleno | Engenharia 2024

---

## 🎯 Objetivo
A equipe de engenharia da **RD Station** baseia seu trabalho diário em princípios sólidos. Um dos principais é: 
> "Projete seu código para ser mais fácil de entender, não mais fácil de escrever."

Para nós, é mais importante um código de fácil leitura do que um que utilize recursos complexos e/ou desnecessários.

---

## 🚀 O que gostaríamos de ver
* **Legibilidade:** Código limpo e fácil de ler (Clean Code).
* **Documentação:** Notas gerais sobre a versão da linguagem e instruções de execução.
* **Performance:** Preocupação com a complexidade de algoritmos.
* **Cobertura:** O código deve cobrir todos os casos de uso, mesmo onde não houver testes pré-implementados.
* **Testes:** A adição de novos testes é sempre bem-vinda.
* **Entrega:** Link de um repositório público (GitHub, BitBucket, etc.).

---

## 🛒 O Desafio: Carrinho de Compras
O desafio consiste em uma **API Rest** para gerenciamento de um carrinho de compras de e-commerce, utilizando **Ruby on Rails**.

### 1. Registrar um produto no carrinho
Se não existir um carrinho para a sessão, ele deve ser criado e o ID salvo na sessão.
* **Rota:** `POST /cart`
* **Payload:**
{
  "product_id": 345,
  "quantity": 2
}

### 2. Listar itens do carrinho atual
Rota: GET /cart

Response: Retorna o ID do carrinho, lista de produtos com subtotal e o preço total geral.

### 3. Alterar a quantidade de produtos
Se o produto já existir no carrinho, apenas a quantidade deve ser alterada.

Rota: POST /cart/add_item

Payload:
{
  "product_id": 1230,
  "quantity": 1
}
### 4. Remover um produto do carrinho
Rota: DELETE /cart/:product_id

Detalhes: Validar se o produto existe no carrinho e tratar casos de carrinho vazio após a remoção.

### 5. Excluir carrinhos abandonados (Background Job)
Status Abandonado: Sem interação (adição/remoção) há mais de 3 horas.

Remoção: Carrinhos marcados como abandonados há mais de 7 dias.

Requisito: Implementar um Job para gerenciar essas regras automaticamente.

🛠 Como resolver
Implementação
Use como base o código fornecido e expanda as funcionalidades sinalizadas com # TODO.

Testes
Implemente os testes marcados como Pending e garanta que os testes com erro passem a funcionar após sua implementação.

Itens Adicionais (Diferenciais)
Utilização de FactoryBot na construção dos testes.

Desenvolvimento de um arquivo docker-compose.yml.

Tratamento de erros (ex: impedir que um produto tenha quantidade negativa).

💻 Informações Técnicas
Dependências
Ruby: 3.3.1

Rails: 7.1.3.2

Postgres: 16

Redis: 7.0.15

Como executar
Instalar dependências: bundle install

Executar Sidekiq: bundle exec sidekiq

Executar projeto: bundle exec rails server

Executar testes: bundle exec rspec

📤 Como enviar seu projeto
Salve seu código em um versionador (GitHub, GitLab, Bitbucket) e envie o link público. Se necessário, adicione instruções extras no README para facilitar a correção.