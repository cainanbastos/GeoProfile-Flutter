# GeoProfile — câmera e localização Flutter

Atividade do PDF 'Câmera e Localização no Flutter' com desafios implementados.

## Instalação em Windows
1. Extraia este ZIP.
2. Abra a pasta `cameralocalizacaoflutter`.
3. Execute `INSTALAR_NO_WINDOWS.bat` para gerar os arquivos nativos compatíveis com a sua versão instalada do Flutter.
4. Abra a pasta no VS Code ou Android Studio.
5. Conecte um tablet/celular **Android** com depuração USB habilitada.
6. No terminal:
   ```
   flutter devices
   flutter run
   ```

Não rode usando a opção `Windows` ou `Chrome`: `dart:io`/`FileImage` e o fluxo de câmera deste projeto são direcionados ao Android.

## Recursos
- Tirar foto com câmera
- Escolher e trocar foto pela galeria
- Remover foto
- Editar nome do perfil
- GPS com solicitações de permissão e mensagens de erro
- Latitude/longitude com quatro casas decimais
- Ícone de status antes/depois da obtenção
- Indicador de carregamento
- Atualizar localização e exibir data/hora
- Layout responsivo escuro para tablet

## Observação
O ZIP fornece os fontes do app e o manifesto Android. O `.bat` executa `flutter create` para gerar a estrutura nativa (Gradle, Kotlin e wrapper) que depende da versão local do Flutter. Não foi possível compilar ou executar o app neste ambiente porque o SDK Flutter não está instalado.
