import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const PerfilApp());

class PerfilApp extends StatelessWidget {
  const PerfilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoProfile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1020),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF67B7FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const TelaPerfil(),
    );
  }
}

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nomeController =
      TextEditingController(text: 'Meu perfil');

  File? _foto;
  Position? _posicao;
  DateTime? _ultimaAtualizacao;
  String _mensagemLocalizacao = 'Localização ainda não obtida';
  bool _buscandoLocalizacao = false;
  bool _selecionandoFoto = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto(ImageSource origem) async {
    if (_selecionandoFoto) return;
    setState(() => _selecionandoFoto = true);

    try {
      final imagem = await _picker.pickImage(
        source: origem,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) return;
      if (imagem != null) {
        setState(() => _foto = File(imagem.path));
      }
    } catch (erro) {
      if (!mounted) return;
      _mostrarMensagem(
        origem == ImageSource.camera
            ? 'Não foi possível abrir a câmera. Confira as permissões.'
            : 'Não foi possível abrir a galeria.',
      );
    } finally {
      if (mounted) setState(() => _selecionandoFoto = false);
    }
  }

  void _removerFoto() {
    setState(() => _foto = null);
    _mostrarMensagem('Foto removida do perfil.');
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _erroLocalizacao(String mensagem) {
    if (!mounted) return;
    setState(() {
      _mensagemLocalizacao = mensagem;
      _posicao = null;
      _ultimaAtualizacao = null;
      _buscandoLocalizacao = false;
    });
  }

  Future<void> _obterLocalizacao() async {
    if (_buscandoLocalizacao) return;
    setState(() => _buscandoLocalizacao = true);

    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        _erroLocalizacao('Ative a localização (GPS) do dispositivo.');
        return;
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        _erroLocalizacao('Permissão de localização negada.');
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        _erroLocalizacao(
          'Permissão bloqueada. Libere a localização nas configurações.',
        );
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

      if (!mounted) return;
      setState(() {
        _posicao = posicao;
        _ultimaAtualizacao = DateTime.now();
        _mensagemLocalizacao = 'Localização obtida com sucesso';
        _buscandoLocalizacao = false;
      });
    } on LocationServiceDisabledException {
      _erroLocalizacao('O serviço de localização está desligado.');
    } on PermissionDeniedException {
      _erroLocalizacao('O acesso à localização não foi permitido.');
    } catch (_) {
      _erroLocalizacao(
        'Não foi possível obter a localização. Tente novamente.',
      );
    }
  }

  String _formatarData(DateTime data) {
    String doisDigitos(int numero) => numero.toString().padLeft(2, '0');
    return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year} '
        'às ${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
  }

  Widget _botao({
    required String texto,
    required IconData icone,
    required VoidCallback? onPressed,
    bool destaque = false,
  }) {
    final estilo = destaque
        ? FilledButton.styleFrom(
            backgroundColor: const Color(0xFF66B5FF),
            foregroundColor: const Color(0xFF061424),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE6F0FF),
            side: const BorderSide(color: Color(0xFF344561)),
          );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: destaque
          ? FilledButton.icon(
              style: estilo,
              onPressed: onPressed,
              icon: Icon(icone),
              label: Text(texto),
            )
          : OutlinedButton.icon(
              style: estilo,
              onPressed: onPressed,
              icon: Icon(icone),
              label: Text(texto),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizada = _posicao != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1020),
        title: const Text('GeoProfile',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
              children: [
                const Text(
                  'Seu perfil, seu momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registre uma foto e descubra sua localização atual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFA9B8D3)),
                ),
                const SizedBox(height: 26),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF67B7FF),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 68,
                      backgroundColor: const Color(0xFF1E304D),
                      backgroundImage:
                          _foto != null ? FileImage(_foto!) : null,
                      child: _foto == null
                          ? const Icon(Icons.person_rounded,
                              size: 80, color: Color(0xFFB5C9E5))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nomeController,
                  maxLength: 40,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nome do perfil',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: const Color(0xFF16233A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _botao(
                  texto: 'Tirar foto',
                  icone: Icons.camera_alt_rounded,
                  destaque: true,
                  onPressed: _selecionandoFoto
                      ? null
                      : () => _escolherFoto(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _botao(
                  texto: _foto == null
                      ? 'Escolher da galeria'
                      : 'Trocar foto pela galeria',
                  icone: Icons.photo_library_rounded,
                  onPressed: _selecionandoFoto
                      ? null
                      : () => _escolherFoto(ImageSource.gallery),
                ),
                if (_foto != null) ...[
                  const SizedBox(height: 10),
                  _botao(
                    texto: 'Remover foto',
                    icone: Icons.delete_outline_rounded,
                    onPressed: _removerFoto,
                  ),
                ],
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16233A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF2D405F)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        localizada
                            ? Icons.location_on_rounded
                            : Icons.location_searching_rounded,
                        size: 43,
                        color: localizada
                            ? const Color(0xFF5DE0B0)
                            : const Color(0xFF9AAAC4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _mensagemLocalizacao,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (localizada) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Latitude: ${_posicao!.latitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Longitude: ${_posicao!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 17),
                        ),
                        if (_ultimaAtualizacao != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Atualizada em ${_formatarData(_ultimaAtualizacao!)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFA9B8D3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _buscandoLocalizacao
                              ? null
                              : _obterLocalizacao,
                          icon: _buscandoLocalizacao
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  localizada
                                      ? Icons.refresh_rounded
                                      : Icons.my_location_rounded,
                                ),
                          label: Text(
                            _buscandoLocalizacao
                                ? 'Obtendo localização...'
                                : localizada
                                    ? 'Atualizar localização'
                                    : 'Usar minha localização',
                          ),
                        ),
                      ),
                    ],
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
