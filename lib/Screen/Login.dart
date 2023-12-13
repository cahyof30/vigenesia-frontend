import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:dio/dio.dart';
import 'MainScreens.dart';
import 'Register.dart';
import 'package:flutter/gestures.dart';
import 'package:vigenesia/Models/Login_Model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Future<LoginModels?> postLogin(String email, String password) async {
    var dio = Dio();
    String baseurl =
        "http://localhost/vigenesia/"; // ganti dengan ip address kamu / tempat kamu menyimpan backend

    Map<String, dynamic> data = {"email": email, "password": password};

    try {
      final response = await dio.post("$baseurl/api/login/",
          data: data,
          options: Options(headers: {'Content-type': 'application/json'}));

      print("Respon -> ${response.data} + ${response.statusCode}");

      if (response.statusCode == 200) {
        final loginModel = LoginModels.fromJson(response.data);
        return loginModel;
      }
    } catch (e) {
      print("Failed To Load $e");
    }
    return null;
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Security System-Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 50),
                Center(
                  child: Form(
                    key: _fbKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: "email",
                            controller: emailController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(),
                                labelText: "Email"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            obscureText: true,
                            name: "password",
                            controller: passwordController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(),
                                labelText: "Password"),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Dont Have Account ? ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextSpan(
                                    text: 'Sign Up',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                    Register()));
                                      },
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueAccent,
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: () async {
                                  await postLogin(emailController.text,
                                      passwordController.text)
                                      .then((value) {
                                    if (value != null &&
                                        value.isActive == true) {
                                      String? iduser = value.data?.iduser;

                                      if (iduser != null) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                MainScreens(
                                                  nama: value.data?.nama,
                                                  iduser: iduser,
                                                ),
                                          ),
                                        );
                                      }
                                    } else {
                                      Flushbar(
                                        message: "Check Your Email / Password",
                                        duration: Duration(seconds: 5),
                                        backgroundColor: Colors.redAccent,
                                        flushbarPosition: FlushbarPosition.TOP,
                                      ).show(context);
                                    }
                                  });
                                },
                                child: Text("Sign In")),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
