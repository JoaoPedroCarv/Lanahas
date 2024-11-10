import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanahas/detalhe_receita_banco.dart';

class ListaReceitasPage extends StatefulWidget {
  const ListaReceitasPage({super.key});

  @override
  State<ListaReceitasPage> createState() => _ListaReceitasPageState();
}

class _ListaReceitasPageState extends State<ListaReceitasPage> {
  List _receitas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buscarReceitasSalvas(); // Busca as receitas ao iniciar a página
  }

  Future<void> _buscarReceitasSalvas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('receitas').get();
      setState(() {
        _receitas = querySnapshot.docs;
      });
    } catch (e) {
      print('Erro ao buscar receitas salvas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6E648),
        automaticallyImplyLeading: false,
        title: const Text(
          'Receitas Salvas',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _receitas.length,
                        itemBuilder: (context, index) {
                          final receita = _receitas[index];
                          return GestureDetector(
                            onTap: () {
                              // Navegar para a tela de detalhes passando o ID do documento
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetalheReceitaFirebasePage(
                                    receitaId:
                                        receita.id, // Passa o ID do documento
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(8, 0, 0, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 0, 0, 4),
                                                    child: Text(
                                                      receita['nome'] ??
                                                          'Nome não disponível',
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 4),
                                                    child: Text(
                                                      'Receita deliciosa',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
