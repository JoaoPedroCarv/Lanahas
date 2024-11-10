import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detalhesReceita != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome da Receita
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _detalhesReceita!['nome'] ?? 'Nome não disponível',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Categoria da Receita
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
                      // Instruções
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
                      // Ingredientes
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
                    ],
                  ),
                )
              : const Center(child: Text('Receita não encontrada')),
    );
  }
}
