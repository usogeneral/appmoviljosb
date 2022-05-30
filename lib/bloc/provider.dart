import 'package:flutter/material.dart';
import 'package:jobsapp/bloc/login.bloc.dart';
import 'package:jobsapp/bloc/oferta.bloc.dart';
import 'package:jobsapp/bloc/perfil_bloc.dart';
export 'package:jobsapp/bloc/login.bloc.dart';

class Provider extends InheritedWidget{

   /*static  Provider _instancia = Provider._internal(child: null,);

  factory Provider({Key? key, child}){
    if(_instancia == null){
      _instancia = new Provider._internal(key: key, child: child);
    }
    return _instancia;
  }*/

  final _loginBloc = LoginBloc();
  final _ofertaBloc = OfertaBloc();
  final _perfilBloc = PerfilBloc();

  Provider({Key? key, child}): super (key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static LoginBloc? of (BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<Provider>()?._loginBloc;
  }

  static OfertaBloc? ofertaBloc(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<Provider>()?._ofertaBloc;
  }

  static PerfilBloc? perfilBloc(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<Provider>()?._perfilBloc;
  }

}