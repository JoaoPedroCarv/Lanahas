import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DetalheReceitaFirebasePage extends StatefulWidget {
  final String receitaId;

  const DetalheReceitaFirebasePage({super.key, required this.receitaId});

  @override
  State<DetalheReceitaFirebasePage> createState() =>
      _DetalheReceitaFirebasePageState();
}

class _DetalheReceitaFirebasePageState
    extends State<DetalheReceitaFirebasePage> {
  Map<String, dynamic>? _detalhesReceita;
  bool _isLoading = false;
  final TextEditingController _observacaoController = TextEditingController();
  String? _minhaObservacao;
  bool _showLottieAnimation = false;

  @override
  void initState() {
    super.initState();
    _buscarDetalhesReceita();
  }

  Future<void> _buscarDetalhesReceita() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('receitas')
          .doc(widget.receitaId)
          .get();

      if (doc.exists) {
        setState(() {
          _detalhesReceita = doc.data() as Map<String, dynamic>?;
          _minhaObservacao = _detalhesReceita?['observacao'];
        });
      } else {
        print('Documento não encontrado.');
      }
    } catch (e) {
      print('Erro ao buscar detalhes da receita: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _salvarObservacao() async {
    if (_observacaoController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('receitas')
            .doc(widget.receitaId)
            .update({
          'observacao': _observacaoController.text,
        });

        setState(() {
          _minhaObservacao = _observacaoController.text;
          _showLottieAnimation = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Observação salva com sucesso!')),
        );

        _observacaoController.clear();

        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _showLottieAnimation = false;
          });
        });
      } catch (e) {
        print('Erro ao salvar a observação: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar a observação.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6E648),
        title: const Text(
          'Detalhes da Receita',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _detalhesReceita != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _detalhesReceita!['nome'] ??
                                  'Nome não disponível',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Categoria: ${_detalhesReceita!['categoria'] ?? 'Categoria não disponível'}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Instruções:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  _detalhesReceita!['instrucoes'] ??
                                      'Instruções não disponíveis',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ingredientes:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 8),
                                ...?_detalhesReceita!['ingredientes']
                                    ?.map<Widget>((ingrediente) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      ingrediente,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_minhaObservacao != null &&
                              _minhaObservacao!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Minhas Observações:',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    _minhaObservacao!,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Adicionar Observação:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Divider(color: Colors.grey),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _observacaoController,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Escreva sua observação aqui...',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _salvarObservacao,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Salvar Observação',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('Receita não encontrada')),
          if (_showLottieAnimation)
            Center(
              child: Lottie.asset(
                'success_animation.json',
                width: 150,
                height: 150,
                repeat: false,
              ),
            ),
        ],
      ),
    );
  }
}
