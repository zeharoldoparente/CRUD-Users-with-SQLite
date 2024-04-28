import 'package:crud_flutter/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  var _allData = <Map<String, dynamic>>[];

  bool _isLoading = true;

// Função para atualizar os dados da tela buscando do banco de dados
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

// Função para validar o campo de email
  String? _validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Insira um email válido';
    }
    return null;
  }

// Função para validar o campo de senha
  String? _validatePassword(String? value) {
    if (value == null || value.length < 5) {
      return 'A senha deve ter pelo menos 5 caracteres';
    }
    return null;
  }

// Função para adicionar novos dados
  Future<void> _addData() async {
    // Verifica se o formulário é válido e então realiza a inclusão do dos dados no banco e atualiza as informações na tela.
    if (_formKey.currentState!.validate()) {
      await SQLHelper.createData(_nameController.text, _emailController.text,
          _passwordController.text);
      _refreshData();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

// Função para atualizar dados existentes
  Future<void> _updateData(int id) async {
    // Verifica se o formulário é válido e então atualiza os dados no banco mostra um snackbar informando que o usuário foi modificado e atualiza as informações na tela
    if (_formKey.currentState!.validate()) {
      await SQLHelper.updateData(id, _nameController.text,
          _emailController.text, _passwordController.text);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.indigo, content: Text("Usuário Modificado")));
      _refreshData();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

// Função para excluir dados
  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent, content: Text("Usuário Excluído")));
    _refreshData();
  }

//Controladores dos campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

// Função para exibir o modal de adição/edição de dados
  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingData['name'];
      _emailController.text = existingData['email'];
      _passwordController.text = existingData['password'];
    }

// Exibe o modal de adição/edição de dados
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Exibe uma mensagem de erro se o formulário não for válido
              if (_formKey.currentState != null &&
                  !_formKey.currentState!.validate())
                const Center(
                  child: Text(
                    'Por favor, corrija os erros destacados.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Nome",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Senha",
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 10),
              // Botão para adicionar ou editar usuário
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (id == null) {
                        await _addData();
                      } else {
                        await _updateData(id);
                      }
                      _nameController.text = "";
                      _emailController.text = "";
                      _passwordController.text = "";
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      (id == null ? "Adicionar" : "Editar"),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

// Função para confirmar a edição de um item
  void _confirmEdit(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Edição"),
          content: const Text("Deseja realmente editar este item?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showBottomSheet(id);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

// Função para confirmar a exclusão de um item
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text("Deseja realmente excluir este item?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteData(id);
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

// Método responsável por construir a interface da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text(
          "Crud Usuários",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _allData.isEmpty
              ? const Center(
                  child: Text(
                    "Sem usuários cadastrados no momento",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              // Cria uma lista que exibe os usuários cadastrados
              : ListView.builder(
                  itemCount: _allData.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _allData[index]['name'],
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      subtitle: Text(_allData[index]['email']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botão para editar o usuário
                          IconButton(
                            onPressed: () {
                              _confirmEdit(_allData[index]['id']);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.indigo,
                            ),
                          ),
                          IconButton(
                            // Botão para excluir o usuário
                            onPressed: () {
                              _confirmDelete(_allData[index]['id']);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        backgroundColor: Colors.indigo,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
