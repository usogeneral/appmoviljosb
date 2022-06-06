import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jobsapp/bloc/perfil_bloc.dart';
import 'package:jobsapp/bloc/provider.dart';
import 'package:jobsapp/models/user.model.dart';
import 'package:jobsapp/pages/dashboard.page.dart';
import 'package:jobsapp/provider/usuario.provider.dart';
import 'package:jobsapp/sharepreference/preferenciasUsuario.dart';
import 'package:jobsapp/utils/utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class EditarHabilidadPage extends StatefulWidget {
  @override
  _EditarHabilidadPageState createState() => _EditarHabilidadPageState();
}

class _EditarHabilidadPageState extends State<EditarHabilidadPage> {
  TextEditingController _nombreHabilidadController = TextEditingController();

  List<String> skillsParaWidget = [];

  final _globalKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool circularProgress = false;
  PerfilBloc perfilBloc = PerfilBloc();
  final usuarioProvider = UsuariosProvider();
  final preferencias = PreferenciasUsuario();
  Usuario user = Usuario(
      skills: [],
      fechaCreacion: DateTime.now(),
      experiencia: [],
      estudios: [],
      redesSociales: RedesSociales());

  final String _url = URLFOTO;

  Future<void> verificarToken() async {
    bool verify = await usuarioProvider.verificarToken();
    if (verify) {
      preferencias.clear();
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => DashboardPage()),
          (Route<dynamic> route) => false);
    } else {
      print('Token válido ${preferencias.token}');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nombreHabilidadController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      verificarToken();
    });
  }

  String id = '';
  String fotoUser = '';

  @override
  Widget build(BuildContext context) {
    perfilBloc = Provider.perfilBloc(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Habilidades'),
        actions: [_botonAgregarHabilidad(context)],
      ),
      key: scaffoldKey,
      body: Form(
        key: _globalKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          children: [
            FutureBuilder(
              future: perfilBloc.cargarUsuario(),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                skillsParaWidget = [];

                if (snapshot.hasError) {
                  print("eroro: " + snapshot.hasError.toString());
                }
                if (snapshot.hasData && snapshot.data!['usuario'] != null) {
                  for (var item in snapshot.data!['usuario']['skills']) {
                    skillsParaWidget.add(item);
                  }
                  user.skills = skillsParaWidget;

                  return Column(
                    children: [
                      _skillsWidget(),
                    ],
                  );
                } else {
                  print("no hay datos ");
                  return Center(
                    child: Container(
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 45.0,
                              ),
                              Text("No tienes habilidades registradas",
                                  style: TextStyle(
                                      fontSize: 19.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(53, 80, 112, 2.0))),
                              SizedBox(
                                height: 30.0,
                              ),
                              FadeInImage(
                                placeholder:
                                    AssetImage('assets/img/buscando.png'),
                                image: AssetImage('assets/img/buscando.png'),
                                fit: BoxFit.cover,
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                            ],
                          ),
                        )),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  _botonAgregarHabilidad(BuildContext context) {
    return FlatButton(
      child: Icon(
        Icons.add,
        color: Colors.white,
        size: 40.0,
      ),
      onPressed: () {
        Alert(
            context: context,
            title: "Añadir Habilidad",
            content: Column(
              children: <Widget>[
                TextField(
                  controller: _nombreHabilidadController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.book),
                    labelText: 'Habilidad',
                  ),
                ),
              ],
            ),
            buttons: [
              DialogButton(
                onPressed: () async {
                  skillsParaWidget
                      .add(_nombreHabilidadController.text.toString());

                  user.skills = skillsParaWidget;
                  final respuesta =
                      await perfilBloc.editarSkillsDelUsuario(user);
                  _nombreHabilidadController.text = '';
                  skillsParaWidget = [];
                  mostrarSnackBar('Datos actualizados exitosamente');
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, 'editarhabilidad');
                },
                child: Text(
                  "Añadir Habilidad",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ]).show();
      },
    );
  }

  _skillsWidget() {
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: user.skills
              .map((item) => Column(
                    children: [
                      ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Color.fromRGBO(29, 53, 87, 1.0),
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: InkWell(
                          onTap: () async {
                            skillsParaWidget
                                .removeWhere((element) => (element == item));
                            print('REMOVED: ${skillsParaWidget}');

                            user.skills = skillsParaWidget;
                            final respuesta =
                                await perfilBloc.editarSkillsDelUsuario(user);
                            mostrarSnackBar('Datos actualizados exitosamente');
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'editarhabilidad');
                          },
                          child: Image.asset('assets/img/delete.png',
                              height: 25.0),
                        ),
                      )
                    ],
                  ))
              .toList()),
    );
  }

  void mostrarSnackBar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1800),
      backgroundColor: Color.fromRGBO(29, 53, 87, 1.0),
    );
    scaffoldKey.currentState!.showSnackBar(snackbar);
  }
}
