import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
//const request =
//

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final size = MediaQuery.of(context).size.height;
  String _search = '';
  int _offSet = 0;
  var searchController = TextEditingController();
  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == '') {
      response = await http.get(
        Uri.parse(
            "https://api.giphy.com/v1/gifs/trending?api_key=2UQpufweWIMJa8be19N8GTC6fmSDATrw&limit=25&rating=g"),
      );
    } else {
      response = await http.get(
        Uri.parse(
            "https://api.giphy.com/v1/gifs/search?api_key=2UQpufweWIMJa8be19N8GTC6fmSDATrw&q=$_search&limit=25&offset=$_offSet&rating=g&lang=en"),
      );
    }
    return json.decode(response.body);
  }

  setSearch(controller) {
    _search = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .09,
                    child: TextFormField(
                      cursorHeight: MediaQuery.of(context).size.height * .04,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        labelText: 'Pesquise aqui',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      //
                      //
                      controller: searchController,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .09,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        setSearch(searchController.text);
                        _getGifs();
                        searchController.text = '';
                      });
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    style: TextButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ),
              ),
              //
              //
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );

                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: Image.network(
                snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GifPage(snapshot.data["data"][index]),
                  ),
                );
              },
            );
          } else {
            return GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70,
                  ),
                  Text(
                    'Carregar mais...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
              },
            );
          }
        });
  }
}
