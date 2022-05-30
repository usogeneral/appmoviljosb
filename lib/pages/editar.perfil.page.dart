import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobsapp/bloc/perfil_bloc.dart';
import 'package:jobsapp/bloc/provider.dart';
import 'package:jobsapp/models/user.model.dart';
import 'package:jobsapp/pages/dashboard.page.dart';
import 'package:jobsapp/provider/usuario.provider.dart';
import 'package:jobsapp/sharepreference/preferenciasUsuario.dart';
import 'package:jobsapp/utils/utils.dart';


class EditarPerfilPage extends StatefulWidget {
  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {


    Map<String, dynamic> dataRedesSociales = {};
     List<String> skillsParaWidget = [];




  PickedFile _imageFile = PickedFile('');
  final _globalKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final ImagePicker _picker = ImagePicker();

  bool circularProgress = false;
  PerfilBloc perfilBloc = PerfilBloc();
  final usuarioProvider = UsuariosProvider();
  final preferencias =  PreferenciasUsuario();
  Usuario user = Usuario(skills: [], fechaCreacion: DateTime.now(), experiencia: [], estudios: [], redesSociales: RedesSociales());


  bool estaLogueado = false;
    final String _url = 'https://jobstesis.herokuapp.com/uploads/';


  Future<void> verificarToken() async{
    bool verify = await usuarioProvider.verificarToken();
    if(verify){
      estaLogueado = false;
      preferencias.clear();
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => DashboardPage()), (Route<dynamic> route) => false); 
    }else{
      estaLogueado = true;
      print('Token válido ${preferencias.token}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      verificarToken();
    });
  }

  TextEditingController _nombresController = TextEditingController();
  TextEditingController _apellidosController = TextEditingController();
  TextEditingController _biografiaController = TextEditingController();
  TextEditingController _celularController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _habilidadesController = TextEditingController();

  String id = '';
  String fotoUser = '';

  @override
  Widget build(BuildContext context) {
    perfilBloc = Provider.perfilBloc(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text('Perfil de usuario'),
        ),
        key: scaffoldKey,
        //drawer: MenuWidget(),
        body: 
            Form(
              key: _globalKey,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                children: [
                  FutureBuilder(
                    future: perfilBloc.cargarUsuario(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.hasError) {
                        print("eroro: " + snapshot.hasError.toString());
                      }
                      if (snapshot.hasData && snapshot.data!['usuario'] != null) {
                        _nombresController.text = snapshot.data!['usuario']['nombres'];
                        _apellidosController.text = snapshot.data!['usuario']['apellidos'];
                        _biografiaController.text = snapshot.data!['usuario']['bio'].toString();
                        _celularController.text = snapshot.data!['usuario']['numeroDeCelular'].toString();
                        _emailController.text = snapshot.data!['usuario']['email'].toString();
                        
                        
                        /*AGREGANDO DATOS AL OBJETO
                        user.nombres = snapshot.data!['usuario']['nombres'];
                        user.apellidos = snapshot.data!['usuario']['apellidos'];
                        user.email = snapshot.data!['usuario']['email'];
                        user.numeroDeCelular = snapshot.data!['usuario']['numeroDeCelular'];
                        user.experiencia = snapshot.data!['usuario']['experiencia'];
                        user.estudios = snapshot.data!['usuario']['estudios'];
                        user.img = snapshot.data!['usuario']['img'];
                        user.bio = snapshot.data!['usuario']['bio'].toString();
                        user.esAdmin = snapshot.data!['usuario']['esAdmin'];
                        dataRedesSociales = snapshot.data!['usuario']['redesSociales'];
                        user.redesSociales = dataRedesSociales.toString();
                        user.fechaCreacion = DateTime.parse(snapshot.data!['usuario']['fechaCreacion']);
                        user.activo = snapshot.data!['usuario']['activo'];
                        user.uid = snapshot.data!['usuario']['uid'];
                        user.documentoDeIdentidad = snapshot.data!['usuario']['documentoDeIdentidad'];
              */
                        for (var item in snapshot.data!['usuario']['skills']) {
                          skillsParaWidget.add(item);
                        }
                        user.skills = skillsParaWidget;
              
              
              
                        if(snapshot.data!['usuario']['img'].toString().isNotEmpty){
                          fotoUser = snapshot.data!['usuario']['img'];
                        }else{
                          fotoUser = URLFOTOPERFIL;
                        }
                          //print('IMG: ${_imageFile.path}');
                          //print('IMG2: ${fotoUser}');
                        //user = snapshot.data!['usuario'];
                        print(user);
                        return Column(
                          children: [
                            actualizarImagenPerfilUsuario(),
                            _imageFile.path.isNotEmpty?_crearBotonActualizarFoto():Container(),
                            _crearNombre(perfilBloc),
                            SizedBox(
                              height: 15.0,
                            ),
                            _crearApellido(perfilBloc),
                            SizedBox(
                              height: 15.0,
                            ),
                            _crearbiografia(perfilBloc),
                            SizedBox(
                              height: 15.0,
                            ),
                            _crearCelular(perfilBloc),
                            SizedBox(
                              height: 15.0,
                            ),
                            _crearemail(perfilBloc),
                            SizedBox(
                              height: 15.0,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _crearBoton(perfilBloc),
                              ],
                            ),
                            
                          ],
                        );
                      }else {
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
                                    
                                    Text("No hay información del perfil",
                                        style: TextStyle(
                                            fontSize: 19.0,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(53, 80, 112, 1.0))),
                                    SizedBox(
                                      height: 30.0,
                                    ),FadeInImage(
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


  _crearBoton(PerfilBloc bloc) {
    return StreamBuilder(
      //stream: bloc.formValidStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return RaisedButton(
            child: Container(
              child: Text('Actualizar Perfil'.toUpperCase()),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 5.0,
            color: Color.fromRGBO(53, 80, 112, 1.0),
            textColor: Colors.white,
            onPressed: () => _editarPerfilUsuario(context, bloc));
      },
    );
  }

  _crearBotonActualizarFoto() {
    return (_imageFile == null)
        ? Container()
        : RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15.0),
            child: Container(
              child: Text(
                'Actualizar imagen',
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 4.0,
            color: Color.fromRGBO(29, 53, 87, 1.0),
            textColor: Colors.white,
            onPressed: _imageFile != null
                ? () async {
                    if (mounted)
                      setState(() {
                        circularProgress = true;
                      });

                    if (_imageFile.path != null) {
                      var imagenResponse =
                          await perfilBloc.actualizarImagen(_imageFile.path);
                      mostrarSnackBar('Imagen actualizada exitosamente');
                      Navigator.pushReplacementNamed(context, 'verperfil');

                      if (imagenResponse.statusCode == 200) {
                        if (mounted)
                          setState(() {
                            circularProgress = false;
                            _imageFile = PickedFile('');
                            print('PATH luego de subir foto: ${_imageFile.path}');
                          });
                        //Navigator.pushReplacementNamed(context, 'perfil');

                        /* Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (route) => false);*/
                      }
                    } else {
                      if (mounted)
                        setState(() {
                          circularProgress = false;
                        });
                      //Navigator.pushReplacementNamed(context, 'perfil');

                      /*Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false);*/
                    }
                  }
                : null,
          );
  }

  _editarPerfilUsuario(BuildContext context, PerfilBloc bloc) async {
    /*String nombre = bloc.nombre.toString();
    String apellido = bloc.apellido.toString();
    String biografia = bloc.biografia.toString();
    String celular = bloc.celular.toString();
    String email = bloc.email.toString();*/
    if (!_globalKey.currentState!.validate()) return;
    

    user.nombres = _nombresController.text.toString();
    user.apellidos = _apellidosController.text.toString();
    user.bio = _biografiaController.text.toString();
    user.numeroDeCelular = _celularController.text.toString();
    user.email = _emailController.text.toString();

    /*user.nombre = nombre;
    user.apellido = apellido;
    user.biografia = biografia;
    user.movil = celular;
    user.convencional = email;
    user.id = id;*/

    //print(user.nombre);

    //print(user.id);

    final respuesta = await perfilBloc.editarDatosDelPerfilUsuario(user);
    if(respuesta['ok'] == true){
      print('USER WIDGET: ${user.esAdmin}');
    print('Respuesta: ${respuesta}');
    Navigator.pushReplacementNamed(context, 'verperfil');
    }
    mostrarSnackBar(respuesta['msg']);
  }

  void mostrarSnackBar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1800),
      backgroundColor: Color.fromRGBO(29, 53, 87, 1.0),
    );
    scaffoldKey.currentState!.showSnackBar(snackbar);
  }

  actualizarImagenPerfilUsuario() {
    return Center(
      child: Stack(
        children: [
         Container(
           width: 200.0,
           height: 120.0,
           child: Semantics(
                child: _imageFile.path.toString().isNotEmpty? Image.file(File(_imageFile.path)):Image.network(_url+fotoUser),
              ),
         ),
          Positioned(
            bottom: 70.0,
            right: 5.0,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: ((builder) => botonDeActualizarPerfil()));
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.redAccent,
                size: 40.0,
              ),
            ),
          ),
        ],
      ),
    );
  }


/*Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFile.path)
                  : Image.file(File(_imageFile.path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }*/

  botonDeActualizarPerfil() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          Text(
            "Buscar foto de perfil",
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  tomarFotografia(ImageSource.camera);
                },
                label: Text("Cámara"),
              ),
              FlatButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  tomarFotografia(ImageSource.gallery);
                },
                label: Text("Galería"),
              )
            ],
          )
        ],
      ),
    );
  }

  tomarFotografia(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
    );
    if (mounted)
      setState(() {
        _imageFile = pickedFile!;
        //_crearBotonActualizarFoto();
      });
  }

  _crearNombre(PerfilBloc bloc) {
    return StreamBuilder(
      //initialData: _nombresController.text.toString(),
      //stream: bloc.nombreStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            onSaved: (value) => _nombresController.text = value!,
            validator: (value) {
              if (value!.length <= 0) {
                return 'Ingrese sus nombres';
              } else {
                return null;
              }
            },
            controller: _nombresController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Color.fromRGBO(53, 80, 112, 1.0),
                ),
                labelText: 'Nombres',
                counterText: snapshot.data,
                //errorText: snapshot.error
                ),
            //onChanged: bloc.changeNombre,
          ),
        );
      },
    );
  }

  _crearApellido(PerfilBloc bloc) {
    return StreamBuilder(
      //initialData: _apellidosController.text.toString(),
      //stream: bloc.apellidoStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            onSaved: (value) => _apellidosController.text = value!,
            validator: (value) {
              if (value!.length <= 0) {
                return 'Ingrese sus apellidos';
              } else {
                return null;
              }
            },
            controller: _apellidosController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Color.fromRGBO(53, 80, 112, 1.0),
                ),
                labelText: 'Apellidos',
                counterText: snapshot.data,
                //errorText: snapshot.error
                ),
            // onChanged: bloc.changeApellido,
          ),
        );
      },
    );
  }

  _crearbiografia(PerfilBloc bloc) {
    return StreamBuilder(
      //initialData: _biografiaController.text.toString(),
      //stream: bloc.biografiaStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            maxLines: 2,
            textAlign: TextAlign.justify,
            onSaved: (value) => _biografiaController.text = value!,
            validator: (value) {
              if (value!.length <= 0 || value.length <10) {
                return 'Ingrese su biografía';
              } else {
                return null;
              }
            },
            controller: _biografiaController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.markunread_mailbox_outlined,
                  color: Color.fromRGBO(53, 80, 112, 1.0),
                ),
                labelText: 'Biografía',
                counterText: snapshot.data,
                //errorText: snapshot.error
                ),
            //onChanged: bloc.changebiografia,
          ),
        );
      },
    );
  }

  _crearCelular(PerfilBloc bloc) {
    return StreamBuilder(
      //initialData: _celularController.text.toString(),
      //stream: bloc.celularStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            onSaved: (value) => _celularController.text = value!,
            validator: (value) {
              if (value!.length <= 0 || value.length <10) {
                return 'Ingrese su número de celular';
              } else if(value.length>10){
                return 'Debe contener 10 dígitos';
              }else {
                return null;
              }
            },
            controller: _celularController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.phone_android,
                  color: Color.fromRGBO(53, 80, 112, 1.0),
                ),
                labelText: 'Celular',
                counterText: snapshot.data,
               //errorText: snapshot.error
                ),
            //onChanged: bloc.changeCelular,
          ),
        );
      },
    );
  }

  _crearemail(PerfilBloc bloc) {
    return StreamBuilder(
      //initialData: _emailController.text.toString(),
      //stream: bloc.emailStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            onSaved: (value) => _emailController.text = value!,
            validator: (value) {
              if (value!.length <= 0) {
                return 'Ingrese su correo electrónico';
              } else {
                return null;
              }
            },
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.phone_callback,
                  color: Color.fromRGBO(53, 80, 112, 1.0),
                ),
                labelText: 'Correo',
                counterText: snapshot.data,
                //errorText: snapshot.error
                ),
            //onChanged: bloc.changeemail,
          ),
        );
      },
    );
  }


    _crearHabilidades() {
    return StreamBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            onSaved: (value) => _habilidadesController.text = value!,
            controller: _habilidadesController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.person,
                  color: Color.fromRGBO(53, 80, 112, 1.0),
                ),
                labelText: 'Habilidades',
                counterText: snapshot.data,
          ),
        ));
      },
    );
  }

}
