# Gather 🍽️

**Gather** é uma solução desenvolvida com **Flutter & Dart** projetada para centralizar e automatizar a coleta de informações sobre necessidades alimentares de convidados em eventos. 

O projeto visa eliminar a incerteza no planejamento de cardápios, permitindo que organizadores identifiquem previamente restrições (alergias, intolerâncias) e preferências (veganismo, vegetarianismo), garantindo a segurança dos participantes e reduzindo o desperdício de insumos.

---

## 🎯 Objetivo Principal

Centralizar a coleta de dados dietéticos para permitir um planejamento estratégico de compras e produção gastronômica, assegurando que cada convidado seja atendido em suas particularidades.

## 👥 Público-Alvo

* Organizadores de festas e eventos particulares.
* Pequenos buffets e empresas de catering.
* Cerimonialistas e promotores de eventos sociais.

---

## ✨ Funcionalidades

### 1. Módulo do Organizador
* **Autenticação:** Sistema seguro via e-mail e senha (Firebase Auth).
* **Gestão de Eventos:** Criação de novos eventos com geração de códigos de acesso exclusivos.
* **Dashboard de Insights:**
    * Somatório quantitativo automático das restrições.
    * Lista detalhada com as respostas individuais de cada convidado.

### 2. Módulo do Convidado (Acesso Público)
* **Acesso Simplificado:** Entrada rápida via código do evento (sem necessidade de login).
* **Formulário Intuitivo:** * Campo de identificação (nome).
    * Seletores (checkboxes) para as restrições e preferências mais comuns.
    * Campo dissertativo para detalhes adicionais ou alergias graves.

### 3. Infraestrutura & Segurança
* **Banco de Dados:** Persistência em tempo real com **Cloud Firestore**.
* **Segurança:** Regras de segurança no Firebase para garantir que apenas o criador do evento visualize os dados consolidados.

---

## 🛠️ Tecnologias Utilizadas

* [Flutter](https://flutter.dev/) - Framework UI.
* [Dart](https://dart.dev/) - Linguagem de programação.
* [Firebase Auth](https://firebase.google.com/products/auth) - Autenticação.
* [Cloud Firestore](https://firebase.google.com/products/firestore) - Banco de dados NoSQL em tempo real.

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* SDK do Flutter instalado (versão estável).
* Um projeto configurado no [Firebase Console](https://console.firebase.google.com/).

### Instalação

1.  Clone o repositório:
    ```bash
    git clone https://github.com/seu-usuario/gather.git
    ```
2.  Acesse a pasta do projeto:
    ```bash
    cd gather
    ```
3.  Instale as dependências:
    ```bash
    flutter pub get
    ```
4.  Configure o Firebase:
    * Adicione o arquivo `google-services.json` (Android) em `android/app/`.
    * Adicione o arquivo `GoogleService-Info.plist` (iOS) em `ios/Runner/`.
    * *Ou utilize o FlutterFire CLI para configurar automaticamente.*

5.  Execute o aplicativo:
    ```bash
    flutter run
    ```

---
Desenvolvido com ❤️ para facilitar a organização de eventos.
