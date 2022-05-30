import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jobsapp/models/email.model.dart';
import 'package:jobsapp/models/estudios.model.dart';
import 'package:jobsapp/models/password.model.dart';
import 'package:jobsapp/models/user.model.dart';
import 'package:jobsapp/models/experiencia.model.dart';
import 'package:jobsapp/sharepreference/preferenciasUsuario.dart';

class UsuariosProvider {
  final String _url = 'https://jobstesis.herokuapp.com';
  final preferencias = PreferenciasUsuario();
  


  Future<Map<String, dynamic>> login(String correo, String password) async {
    final authData = {'email': correo, 'password': password};

    final url = Uri.parse('$_url/api/login');
    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(authData));

    print(resp.body);
    print(resp.statusCode);
    if (resp.statusCode == 503) {
      return {'ok': false, 'msg': 'Servicio No Disponible'};
    }

    if (resp.statusCode == 200) {
      final decodeData = json.decode(resp.body);
  print('LOGIN: ${decodeData}');
      preferencias.token = decodeData['token'];
      preferencias.idUsuario = decodeData['usuarioDB']['uid'];
      preferencias.nombres = decodeData['usuarioDB']['nombres'];
      preferencias.passwordActual = password;
      return {'ok': true};
    }
    if(resp.statusCode == 404){
      final decodeData = json.decode(resp.body);
      return {'ok': false, 'msg': decodeData['msg']};
    } 
    else {
      final decodeData = json.decode(resp.body);
      return {'ok': false, 'msg': decodeData['msg']};
    }
  }

  Future<Map<String, dynamic>?> crearUsuario(Usuario usuario) async {
    final Uri url = Uri.parse('$_url/api/usuarios');
    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        //cambiamos aca usuariotoJson
        body: json.encode(usuario));

    if (resp.statusCode == 503) {
      return {'ok': false, 'msg': 'Servicio No Disponible'};
    }
    if (resp.statusCode == 200) {
      final decodeData = json.decode(resp.body);

      preferencias.token = decodeData['token'];
      return {'ok': true};
    } else {
      final decodeData = json.decode(resp.body);
      return {'ok': false, 'msg': decodeData['msg']};
    }
  }

    Future<bool> verificarToken() async {
    final url = '$_url/api/usuarios/validar/token?token=${preferencias.token}';
    bool result;
    final resp = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: preferencias.token
    );

    print('CODE: ${resp.body}');
    //Si el código es de acceso no autorizado, retorna false
     if(resp.statusCode == 404){
      result = true;
    }
    else {
      result = false;
    }
    return result;
  }

    Future<Map<String, dynamic>> obtenerUsuario() async{
    final url = '$_url/api/usuarios/' + preferencias.idUsuario;
    final resp = await http.get( Uri.parse(url), headers: {"Content-Type": "application/json"},);
    
    print('edstado: ${resp.statusCode}');
    if(resp.statusCode == 200){
      final body = json.decode(resp.body);
      
      return body;
    }else{
      final body = json.decode(resp.body);
      return {'ok': false, 'msg': body['msg']};
    }
  }

    Future<Map<String, dynamic>> obtenerUsuarioEspecifico(String id) async{
    final url = '$_url/api/usuarios/'+id;
    final resp = await http.get( Uri.parse(url), headers: {"Content-Type": "application/json"},);
    if(resp.statusCode == 200){
      final body = json.decode(resp.body);
      //print(resp.body);
      return body;
    }else{
      final body = json.decode(resp.body);
      return {'ok': false, 'msg': body['msg']};
    }
  }


  Future<http.StreamedResponse> actualizarImagen(String filePath) async{
    final url = '$_url/api/upload/usuarios/${preferencias.idUsuario}';
    var request = http.MultipartRequest('PUT', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath("imagen", filePath));

    request.headers.addAll(
      {
        "Content-Type": "multipart/form-data",
        'x-token': preferencias.token
      }
      );
      var response = request.send();
      return response;
  }




  Future<Map<String, dynamic>> editarDatosDelPerfilUsuario(Usuario usuario) async{

//print('DESDE PROVIDER: ${usuario.experiencia.toString()}');
    var data = {};
    
   if(usuario.nombres.toString().isNotEmpty){
      data = {
            "nombres": usuario.nombres,
            "apellidos": usuario.apellidos,
            "bio": usuario.bio,
            "numeroDeCelular": usuario.numeroDeCelular,
            "email": usuario.email,
            };
    }if(usuario.redesSociales.twitter.isNotEmpty || usuario.redesSociales.facebook.isNotEmpty
    || usuario.redesSociales.linkedin.isNotEmpty || usuario.redesSociales.instagram.isNotEmpty){
      data = {
        'redesSociales': {
          'twitter': usuario.redesSociales.twitter,
          'facebook': usuario.redesSociales.facebook,
          'linkedin': usuario.redesSociales.linkedin,
          'instagram': usuario.redesSociales.instagram,
        }
      };
    }
     
     //print('DESDE PROVIDER: ${data}');

    final url = Uri.parse('$_url/api/usuarios/${preferencias.idUsuario}');
    final respuesta = await http.put(url, headers: {
      "Content-Type": "application/json",
      'x-token': preferencias.token
      }, body: json.encode(data));
      print('OK DATA: ${respuesta.statusCode}');
      print('OK preferencias: ${preferencias.idUsuario}');
    if(respuesta.statusCode == 200){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      data = {};
      return body;
    }if(respuesta.statusCode == 500){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      data = {};
      return {'ok': false, 'msg':'El número de celular ingresado ya existe'};
    }else{
      final body = json.decode(respuesta.body);
      print('RESPONSE: ${body['msg']}');
      print('RESPONSE: ${body}');
      data = {};
      return body;
    }
    
  }

Future<bool> editarSkillsDelUsuario(Usuario usuario) async{

print('DESDE PROVIDER: ${usuario.skills.toString()}');
    var data = {};
    
      data = {
            "skills": usuario.skills,
            };
     
     print('DESDE PROVIDER: ${data}');

    final url = Uri.parse('$_url/api/usuarios/${preferencias.idUsuario}');
    final respuesta = await http.put(url, headers: {
      "Content-Type": "application/json",
      'x-token': preferencias.token
      }, body: json.encode(data));
      print('OK DATA: ${respuesta.statusCode}');
      print('OK preferencias: ${preferencias.idUsuario}');
    if(respuesta.statusCode == 200){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      data = {};
      return true;
    }else{
      final body = json.decode(respuesta.body);
      print('RESPONSE: ${body['msg']}');
      print('RESPONSE: ${body}');
      data = {};
      return true;
    }
    
  }


  Future<bool> editarExperienciaDelUsuario(UsuarioClass usuario) async{

    final url = Uri.parse('$_url/api/usuarios/${preferencias.idUsuario}');
    final respuesta = await http.put(url, headers: {
      "Content-Type": "application/json",
      'x-token': preferencias.token
      }, body: json.encode(usuario));
      print('OK DATA: ${json.encode(usuario)}');
      print('OK preferencias: ${preferencias.idUsuario}');
    if(respuesta.statusCode == 200){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      return true;
    }else{
      final body = json.decode(respuesta.body);
      print('RESPONSE: ${body['msg']}');
      print('RESPONSE: ${body}');
      return true;
    }
  }

    Future<bool> editarEstudioDelUsuario(EstudioClass usuario) async{

    final url = Uri.parse('$_url/api/usuarios/${preferencias.idUsuario}');
    final respuesta = await http.put(url, headers: {
      "Content-Type": "application/json",
      'x-token': preferencias.token
      }, body: json.encode(usuario));
      print('OK DATA: ${json.encode(usuario)}');
      print('OK preferencias: ${preferencias.idUsuario}');
    if(respuesta.statusCode == 200){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      return true;
    }else{
      final body = json.decode(respuesta.body);
      print('RESPONSE: ${body['msg']}');
      print('RESPONSE: ${body}');
      return true;
    }
  }

    Future<bool> editarPasswordDelUsuario(Password usuario) async{

    final url = Uri.parse('$_url/api/usuarios/cambio/${preferencias.idUsuario}');
    final respuesta = await http.put(url, headers: {
      "Content-Type": "application/json",
      'x-token': preferencias.token
      }, body: json.encode(usuario));
      print('OK DATA: ${json.encode(usuario)}');
      print('OK preferencias: ${preferencias.idUsuario}');
    if(respuesta.statusCode == 200){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      return true;
    }else{
      final body = json.decode(respuesta.body);
      print('RESPONSE: ${body['msg']}');
      print('RESPONSE: ${body}');
      return true;
    }
  }

     Future<Map<String, dynamic>>  editarEmailDelUsuario(Email usuario) async{

    final url = Uri.parse('$_url/api/resetear-password/');
    final respuesta = await http.put(url, headers: {
      "Content-Type": "application/json"
      }, body: json.encode(usuario));
      print('OK DATA: ${json.encode(usuario)}');
      print('OK preferencias: ${preferencias.idUsuario}');
    if(respuesta.statusCode == 200){
      final body = json.decode(respuesta.body);
      print('USUARIO OBTENIDO: ${body}');
      return {'ok': true};
    }else{
      final body = json.decode(respuesta.body);
      print('RESPONSE: ${body['msg']}');
      print('RESPONSE: ${body}');
      return {'ok': false, 'msg': body['msg']};
    }
  }


}
