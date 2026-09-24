import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'dart:async'; //3.1 Importar Timer

class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Control mostrar/ocultar Password
  bool _obscureText = true;
  //5.1 Variable de checkbox Remember Me
  bool isChecked = false;
  //Crear el cerebro de las Animaciones(StateMachine)
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  //2.1 Variable para el recorrido de la mirada
  SMINumber? _numLook;
  //3.2 Timer para detener la miarada al dejar de escribir
  Timer? _typingDebounce;

  //1.1 Crear variables para focusNode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  //4.1 Controllers para manipular el Texto escrito por el Usuario
  final emailController = TextEditingController();
  final passController = TextEditingController();

  //4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  //4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    //minimo 8, una mayuscula, una minuscula, un digito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Accion al boton
  void _onLogin() {
    //De lo que escribio el usuario, quita espacios en blanco
    final email = emailController.text.trim();
    final pass = passController.text;

    //Recalcular los Errores
    final eError = isValidEmail(email) ? null : 'Email Inválido';
    final pError = isValidPassword(pass) ? null : 'Contraseña Inválida';

    //4.5 Avisar si hubo error
    setState(() {
      emailError = eError;
      passError = pError;
    });

    //4.6 cerrar teclado (moviles) y bajar las manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _numLook?.value = 50; //Mirada Neutral

    //4.7 Activar triggers
    if (eError == null && pError == null) {
      //Delay para boton 1 activacion
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _trigSuccess?.fire();
      });
    } else {
      _trigFail?.fire();
    }
  }

  //1.2 Crear los listeners (Oyentes /Chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //Verificar que no sea nulo
        if (_isHandsUp != null) {
          //Manos arriba en el email
          _isHandsUp?.change(false);
          //2.2 Mirada Neutral
          _numLook?.value = 50;
        }
      }
    });
    _passwordFocusNode.addListener(() {
      //Manos arriba
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: size.width,
                  child: RiveAnimation.asset(
                    'assets/login_bear.riv',
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
                      //2.3 Vincular variable numLook
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                //Para separar widgets
                SizedBox(height: 10),
                //Campo de Texto Email
                TextField(
                  //1.3 Asignar el focus al textfield
                  focusNode: _emailFocusNode,
                  //4.8 Enlazar el controller alTextfield
                  controller: emailController,
                  onChanged: (value) {
                    if (_isHandsUp != null) {
                      //No se tapa los ojos
                      //_isHandsUp!.change(false);
                    }
                    //Si isChecking es nulo
                    if (_isChecking == null) return;
                    //Activar modo chismoso
                    _isChecking!.change(true);
                    //2.4 Implementar numLook
                    //Ajuste de limites de 0 a 100
                    //80 medida de calibracion
                    final look = (value.length / 60.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    );
                    //Clamp es el rango (abrazadera)
                    _numLook?.value = look;

                    //3.3 Debounce: si vuelve a teclar reinicia el contador
                    //Cancelar cualquier timer existente (buena practica)
                    _typingDebounce?.cancel();
                    //Crear un nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      //Si se cierra la pantalla (!mounted es que no este activa)
                      if (!mounted) return;
                      //Mirada neutra
                      _isChecking?.change(false);
                    });
                  },
                  //Para mostar un tipo de teclado
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    //4.9 Mostrar el error del texto
                    errorText: emailError,
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
                  focusNode: _passwordFocusNode,
                  controller: passController,
                  onChanged: (value) {
                    if (_isChecking != null) {
                      //No se tapa los ojos
                      //_isChecking!.change(false);
                    }
                    //Si isChecking es nulo
                    if (_isHandsUp == null) return;
                    //Activar modo chismoso
                    _isHandsUp!.change(true);
                  },
                  obscureText: _obscureText,
                  //Para mostar un tipo de teclado
                  decoration: InputDecoration(
                    errorText: passError,
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
                SizedBox(height: 10),
                //Texto Olvide Mi contraseña
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isChecked = newValue ?? true;
                            });
                          },
                        ),
                        const Text('Remember', textAlign: TextAlign.right),
                      ],
                    ),
                    const Text(
                      'Forgot password?',
                      textAlign: TextAlign.right,
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // 4.10 Vincular boton
                  onPressed: _onLogin,
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // ¿No tienes cuenta?
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Don´t have an account?'),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            //Subrayado
                            decoration: TextDecoration.underline,
                            //Negritas
                            fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    //Liberar memoria/recursos al salir de la pantalla
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    //3.4 Liberar timer
    _typingDebounce?.cancel();
    //4.11 Liberar controller
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}
