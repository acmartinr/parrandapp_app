import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/components/confirm_delete_dialog.dart';
import 'package:lexi/pages/login/LoginPage.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _passwordController;
  DateTime? _birthDate; // Fecha seleccionada
  String imageId = "";
  bool _obscureText = true; // Controla la visibilidad de la contraseña
  bool _notificationsEnabled = false;
  String fcmToken = "";
  String firstName = ""; // Ejemplo de nombre
  String email = ""; // Ejemplo de nombre
  String password = ""; // Ejemplo de nombre
  String lastName = ""; // Ejemplo de apellido
  int age = 18; // Ejemplo de edad
  String birthdate = "";
  String gender = "Masculino"; // Inicialmente "Masculino"
  String genderPref = "h"; // Inicialmente "Masculino"
  int id = 0;
  bool edited = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: email);
    _ageController = TextEditingController(text: age.toString());
    _passwordController = TextEditingController(text: password);
    getValues();
  }

  @override
  void dispose() {
    // Libera el controlador al desmontar el widget
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Cargar la preferencia de notificaciones desde SharedPreferences
  void _loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    });
  }

  // Guardar la preferencia de notificaciones en SharedPreferences
  void _saveNotificationPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
  }

  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      String? token = await messaging.getToken();
      fcmToken = token!;
      print('FCM Token: $token');

      if (token != null) {
        // Optionally, save the token to your server or use it as needed.
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _editProfilePicture() async {
    print('Editando foto');
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
        edited = true;
      });
    }
  }

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    prefs.remove('id');
    prefs.remove('name');
    prefs.remove('lastname');
    prefs.remove('age');
    prefs.remove("userProfileId");
    // Lógica para cerrar sesión
    print('Sesión cerrada');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    LoginService loginService = LoginService(baseUrl: Utils.baseUrl);
    try {
      final response = await loginService
          .getUserById(id.toString()); // Llamada a la función login

      // Verifica el código de estado
      if (response.statusCode == 200) {
        // Decodificar la respuesta para buscar campo 'error'
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          // Si el código es 404, significa que el email no existe
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  data['error'] ?? 'El email no existe en la base de datos')));
          return;
        }
        print('Respuesta del servidor: ${data['profileimage']}');
        firstName = data['name'] ?? '';
        lastName = data['lastname'] ?? '';
        email = data['email'] ?? '';
        password = data['password'] ?? '';
        age = data['age'] ?? 18;
        birthdate = data['birthdate'] ?? '';
        genderPref = data['sex'] ?? "m";
        imageId =
            data['profileimage'] != null ? data['profileimage'].trim() : '';
        if (genderPref == "h") {
          gender = "Masculino";
        } else if (genderPref == "m") {
          gender = "Femenino";
        } else {
          gender = "No binario";
        }

        // Parsear la fecha de nacimiento (p. ej. "2006-12-31T23:00:00.000Z")
        if (data['birthdate'] != null &&
            data['birthdate'].toString().isNotEmpty) {
          DateTime utcDate = DateTime.parse(data['birthdate']);
          _birthDate = utcDate.toLocal();
          // Si antes guardabas birthdate como String, actualízalo:
          birthdate = '${_birthDate!.year.toString().padLeft(4, '0')}-'
              '${_birthDate!.month.toString().padLeft(2, '0')}-'
              '${_birthDate!.day.toString().padLeft(2, '0')}';
        }
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Hubo un error al cargar los datos, espere unos minutos')));
      }
    } catch (e) {
      print('Hubo un error al cargar los datos : $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    _firstNameController.text = firstName.trim();
    _lastNameController.text = lastName.trim();
    _emailController.text = email.trim();
    _ageController.text = age.toString();
    _passwordController.text = password.trim();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getToken();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/back.png',
            height: 17,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Configuración',
            style: TextStyle(
                color: Color(0xFF1D1B20),
                fontWeight: FontWeight.w700,
                fontSize: 22.0)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (imageId.isEmpty
                                ? AssetImage('assets/profile.png')
                                : NetworkImage(Utils.baseUrlImage +
                                    'uploads/$imageId?cb=$timestamp'))
                            as ImageProvider,
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.add, color: Color(0xFF056A9E), size: 40),
                        onPressed: _editProfilePicture,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Nombre y Apellido
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  // Si quieres cambiar el tamaño del label:
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    fontSize: 16, // aquí pones el tamaño que quieras
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                  ),

                  // O, si lo que usas es hintText en lugar de labelText, personaliza así:
                  // hintText: 'Nombre',
                  // hintStyle: TextStyle(
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.w700,
                  //   color: Color(0xFF1D1B20),
                  // ),
                ),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                onChanged: (value) {
                  setState(() {
                    edited = true;
                    firstName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                decoration: InputDecoration(
                    labelText: 'Apellidos',
                    labelStyle: TextStyle(
                      fontSize: 16, // aquí pones el tamaño que quieras
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    )),
                onChanged: (value) {
                  setState(() {
                    edited = true;
                    lastName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  // Campo de edad
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final initialDate = _birthDate ??
                            DateTime.now().subtract(Duration(days: 365 * 18));
                        final firstDate = DateTime(1900);
                        final lastDate = DateTime.now();

                        final picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) {
                          setState(() {
                            _birthDate = picked;
                            edited = true;

                            // Actualizar la cadena birthdate en formato YYYY-MM-DD
                            birthdate =
                                '${picked.year.toString().padLeft(4, '0')}-'
                                '${picked.month.toString().padLeft(2, '0')}-'
                                '${picked.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                        child: Text(
                          _birthDate != null
                              ? '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                  '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                  '${_birthDate!.year}'
                              : 'Selecciona tu fecha',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Espacio entre widgets
                  // Campo de género usando DropdownButtonFormField para agregar decoración
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1B20)),
                      value: gender,
                      decoration: InputDecoration(
                          labelText: 'Género',
                          labelStyle: TextStyle(
                            fontSize: 16, // aquí pones el tamaño que quieras
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D1B20),
                          ) // Opcional: para un look consistente
                          ),
                      onChanged: (String? newValue) {
                        setState(() {
                          edited = true;
                          if (newValue == "Masculino") {
                            genderPref = "h";
                          } else if (newValue == "Femenino") {
                            genderPref = "m";
                          } else {
                            genderPref = "n";
                          }
                          gender = newValue!;
                        });
                      },
                      items: <String>['Masculino', 'Femenino', 'No binario']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                decoration: InputDecoration(
                    labelText: 'Correo',
                    labelStyle: TextStyle(
                      fontSize: 16, // aquí pones el tamaño que quieras
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    )),
                onChanged: (value) {
                  setState(() {
                    edited = true;
                    email = value;
                  });
                },
              ),
              SizedBox(height: 16),
              // Campo de contraseña con toggle de visibilidad
              TextField(
                obscureText: _obscureText,
                controller: _passwordController,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    fontSize: 16, // aquí pones el tamaño que quieras
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                  ),
                  // SuffixIcon con imagen PNG de un ojito
                  suffixIcon: IconButton(
                    icon: _obscureText
                        ? Image.asset(
                            "assets/eyepasshidde.png",
                            height: 25,
                          ) // Imagen para contraseña oculta
                        : Image.asset(
                            "assets/eyepass.png",
                            height: 25,
                          ),
                    // Imagen para contraseña visible
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    edited = true;
                    password = value;
                  });
                },
              ),
              SizedBox(height: 16),
              // Notificaciones
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 80.0),
                // Ajusta el padding horizontal
                title: Text('Notificaciones'),
                trailing: Switch(
                  activeColor: Color(0xFF1D1B20),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      if (value) {
                        requestPermission();
                      }
                      _notificationsEnabled = value;
                      _saveNotificationPreference(value);
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              Opacity(
                  opacity: edited ? 1.0 : 0.39, // Cambia la opacidad
                  child: AbsorbPointer(
                    absorbing: edited ? false : true,
                    // Desactiva el botón si no se ha editado
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0, // Quita la elevación
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1B20)),
                        backgroundColor: Color(0xFF24B675), // Fondo verde
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Radio de 20
                        ),
                      ),
                      onPressed: () async {
                        if (_birthDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Debes ser mayor de edad')));
                          return;
                        }
                        final now = DateTime.now();
                        final diff = now.difference(_birthDate!);
                        final years = diff.inDays ~/ 365;
                        if (years < 18) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Debes ser mayor de edad')));
                          return;
                        }

                        try {
                          String? isoBirthdate;
                          if (_birthDate != null) {
                            final safeBirthDate = DateTime(
                              _birthDate!.year,
                              _birthDate!.month,
                              _birthDate!.day,
                              12, // <-- hora fija
                            );

                            isoBirthdate =
                                safeBirthDate.toUtc().toIso8601String();
                          }
                          LoginService loginService =
                              LoginService(baseUrl: Utils.baseUrl);
                          final response = await loginService.update(
                              firstName,
                              lastName,
                              email,
                              genderPref,
                              isoBirthdate!,
                              password,
                              id,
                              _pickedImage);
                          // Verifica el código de estado
                          if (response.statusCode == 200) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('name', firstName);
                            prefs.setString('lastname', lastName);
                            print("actualizado");
                            setState(() {
                              edited = false;
                            });
                            // Si la respuesta es 200, decodificamos el JSON
                            var data = jsonDecode(response.body);

                            // Acceder a los valores del JSON
                            print('email: ${data['email']}');
                            // Aquí puedes agregar la lógica para enviar los datos
                            // Aquí puedes agregar la lógica para actualizar los datos en tu backend o base de datos.
                            print('Datos actualizados');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Datos actualizados corréctamente')));
                            // Puedes guardar estos valores o realizar otras operaciones
                          } else if (response.statusCode == 400) {
                            print('Usuario o contraseña incorrectos');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error al registrar usuario')));
                          print('Error al realizar el login: $e');
                        }
                      },
                      child: Text('Guardar cambios',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  )),
              // Opción para actualizar datos

              SizedBox(height: 16),

              // Botón de cerrar sesión
              ElevatedButton(
                onPressed: () {
                  logOut();
                },
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Color(0xFF1D1B20)),
                ),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  // Sin elevación en ningún estado
                  textStyle: MaterialStateProperty.all(
                    TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  // Efecto hover y otros estados sin elevar el botón:
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.hovered))
                        return Color(0xFF1D1B20).withOpacity(
                            0.1); // Ligeramente oscuro al pasar el mouse
                      if (states.contains(MaterialState.focused) ||
                          states.contains(MaterialState.pressed))
                        return Color(0xFF1D1B20).withOpacity(
                            0.2); // Un poco más marcado cuando se presiona
                      return null;
                    },
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Radio de 20
                      side: BorderSide(
                        width: 3.0,
                        color: Color(
                            0xFF1D1B20), // Borde gris (o el color que definas)
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Botón de eliminar cuenta
              ElevatedButton(
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return const ConfirmDeleteDialog();
                    },
                  );
                  if (confirm == true) {
                    try {
                      LoginService loginService =
                          LoginService(baseUrl: Utils.baseUrl);
                      final response = await loginService.delete(id.toString());
                      print("Status ssss" + response.statusCode.toString());
                      // Verifica el código de estado
                      if (response.statusCode == 200) {
                        setState(() {
                          edited = false;
                        });
                        // Si la respuesta es 200, decodificamos el JSON
                        var data = jsonDecode(response.body);

                        // Acceder a los valores del JSON
                        print('email: ${data['user']}');
                        // Aquí puedes agregar la lógica para enviar los datos
                        // Aquí puedes agregar la lógica para actualizar los datos en tu backend o base de datos.
                        print('Usuario eliminado');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Usuario eliminado correctamente')));
                        logOut();
                        // Puedes guardar estos valores o realizar otras operaciones
                      } else if (response.statusCode == 400) {
                        print('Error al eliminar usuario');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al eliminar usuario')));
                      print('Error al eliminar usuario: $e');
                    }
                    // Lógica para eliminar cuenta
                    print('Cuenta eliminada');
                  }
                },
                child: Text('Eliminar Cuenta',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(
                      0xFFF5363D), // Usamos backgroundColor en lugar de 'primary'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
