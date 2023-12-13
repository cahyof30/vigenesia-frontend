// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:vigenesia/Models/Motivasi_Model.dart';
import 'package:vigenesia/Screen/EditPage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'Login.dart';
import 'package:another_flushbar/flushbar.dart';

class MainScreens extends StatefulWidget {
  final String? nama;
  final String? iduser;
  final String? isi_motivasi;
  const MainScreens({Key? key, this.nama, this.iduser, this.isi_motivasi})
      : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl = "http://localhost/vigenesia/";
  var dio = Dio();
  TextEditingController isiController = TextEditingController();
  List<MotivasiModel> listMotivasi = [];
  String selectedRadio =
      "all"; // Variabel untuk melacak radio button yang dipilih

  Future<dynamic> sendMotivasi(String isi_motivasi, String iduser) async {
    dynamic data = {"isi_motivasi": isi_motivasi, "iduser": iduser};
    try {
      var response = await dio.post(
        "$baseurl/api/dev/POSTmotivasi/",
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      print("Respon -> ${response.data} + ${response.statusCode}");

      return response;
    } catch (e) {
      if (e is DioError) {
        print("Error di -> ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("Error di -> $e");
      }
    }
  }

  Future<List<MotivasiModel>> getData() async {
    var response = await dio.get('$baseurl/api/dev/Get_motivasi/');

    print(" ${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();

      if (selectedRadio == "all") {
        // Tampilkan semua motivasi
        return listUsers;
      } else if (selectedRadio == "user") {
        // Tampilkan motivasi yang sesuai dengan user yang sedang login
        return listUsers
            .where((motivasi) => motivasi.iduser == widget.iduser)
            .toList();
      } else if (selectedRadio == "lain") {
        // Tampilkan "Motivasi Lain" hanya jika iduser motivasi null atau tidak sama dengan iduser yang sedang login
        return listUsers
            .where((motivasi) =>
                motivasi.iduser == null || motivasi.iduser != widget.iduser)
            .toList();
      } else {
        // Return default jika tidak ada pemfilteran yang sesuai
        return listUsers;
      }
    }
    // listMotivasi = listUsers
    //     .where((motivasi) => motivasi.iduser == widget.iduser)
    //     .toList();

    //   return listMotivasi;
    // }
    else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> deletePost(String id) async {
    try {
      dynamic data = {"id": id};
      var response = await dio.delete(
        '$baseurl/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {"Content-type": "application/json"},
        ),
      );

      print("Response from delete: ${response.data}");

      var resbody = jsonDecode(response.data);
      return resbody;
    } catch (e) {
      print("Error during delete operation: $e");
      throw e; // Rethrow the error to propagate it further if needed
    }
  }

  Future<void> _getData() async {
    try {
      // Lakukan operasi GET untuk mendapatkan data terbaru
      List<MotivasiModel> updatedData = await getData();

      setState(() {
        listMotivasi = updatedData;
      });

      if (widget.isi_motivasi != null) {
        await sendMotivasi(
          isiController.text.toString(),
          widget.iduser ?? "",
        ).then((value) => {
              if (value != null)
                {
                  Flushbar(
                    message: "Berhasil Test",
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.greenAccent,
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context)
                }
            });
      }
    } catch (e) {
      print("Failed to get updated data or perform additional actions: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    isiController = TextEditingController();
    _getData();
    selectedRadio = "all"; // Inisialisasi nilai radio button pada initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hallo  ${widget.nama}",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        child: const Icon(Icons.logout),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const Login(),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  FormBuilderTextField(
                    controller: isiController,
                    name: "isi_motivasi",
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        await sendMotivasi(
                          isiController.text,
                          widget.iduser.toString(),
                        ).then((value) => {
                              if (value != null)
                                {
                                  Flushbar(
                                    message: "Berhasil Submit Motivasi",
                                    duration: const Duration(seconds: 5),
                                    backgroundColor: Colors.greenAccent,
                                    flushbarPosition: FlushbarPosition.TOP,
                                  ).show(context)
                                }
                            });

                        _getData();
                        print("Sukses");
                      },
                      child: const Text("Submit"),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      _getData(); // Memanggil _getData() saat tombol refresh ditekan
                    },
                  ),
                  // Container untuk tiga radio button
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Radio(
                              value: "all",
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadio = value.toString();
                                  _getData(); // Perbarui data saat radio button berubah
                                });
                              },
                            ),
                            Text("Semua Motivasi"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: "user",
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadio = value.toString();
                                  _getData(); // Perbarui data saat radio button berubah
                                });
                              },
                            ),
                            Text("Motivasi Saya"),
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              value: "lain",
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadio = value.toString();
                                  _getData(); // Perbarui data saat radio button berubah
                                });
                              },
                            ),
                            Text("Motivasi Lain"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<MotivasiModel>>(
                    future: getData(), // Panggil getData() dari FutureBuilder
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MotivasiModel>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("No Data");
                      } else {
                        return Column(
                          children: [
                            for (var item in snapshot.data!)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.isiMotivasi.toString()),
                                    if (item.iduser == widget.iduser)
                                      Row(
                                        children: [
                                          TextButton(
                                            child: const Icon(Icons.settings),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          EditPage(
                                                    id: item.id,
                                                    isi_motivasi:
                                                        item.isiMotivasi,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          TextButton(
                                            child: const Icon(Icons.delete),
                                            onPressed: () {
                                              deletePost(item.id!)
                                                  .then((value) => {
                                                        if (value != null)
                                                          {
                                                            Flushbar(
                                                              message:
                                                                  "Ber hasil Delete",
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                              flushbarPosition:
                                                                  FlushbarPosition
                                                                      .TOP,
                                                            ).show(context)
                                                          }
                                                      });
                                              _getData();
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
