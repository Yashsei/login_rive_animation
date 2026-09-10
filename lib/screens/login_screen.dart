import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Control mostrar/ocultar Password
  bool _obscureText = true;
  //Crear el cerebro de las Animaciones(StateMachine)
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                width: size.width,
                child: RiveAnimation.asset(
                  'login_bear.riv',
                  stateMachines: ['Login Machine'],
                  //Al iniciar animacion
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );

                    //Verificar que todo inicio Bien
                    if (_controller == null) return;
                    //Agregar el Controlador al tablero/escenario
                    artboard.addController(_controller!);
                    //Vincular variables
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSuccess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                  },
                ),
              ),
              //Para separar widgets
              SizedBox(height: 10),
              //Campo de Texto Email
              TextField(
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    //No se tapa los ojos
                    _isHandsUp!.change(false);
                  }
                  //Si isChecking es nulo
                  if (_isChecking == null) return;
                  //Activar modo chismoso
                  _isChecking!.change(true);
                },
                //Para mostar un tipo de teclado
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    //Borde Redondeado
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //Campo de texto contraseña
              TextField(
                onChanged: (value) {
                  if (_isChecking != null) {
                    //No se tapa los ojos
                    _isChecking!.change(false);
                  }
                  //Si isChecking es nulo
                  if (_isHandsUp == null) return;
                  //Activar modo chismoso
                  _isHandsUp!.change(true);
                },
                obscureText: _obscureText,
                //Para mostar un tipo de teclado
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    //If ternario
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      //Refresca el Icono al ser seleccionado
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    //Borde Redondeado
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
