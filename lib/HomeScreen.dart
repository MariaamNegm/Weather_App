import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather/tempmodel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  int temp = 0;
  //temperature
  int woeid = 0;
  //id of that location on earth
  String weather = "Clear";
  //weather image
  String city = "city";
  //name of city
  String abbr = "c";
  //icon of weather

  Future<void> catchcity(String input) async {
    var url = Uri.parse(
        "https://www.metaweather.com/api/location/search/?query=$input");
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body)[0];
    setState(() {
      woeid = responsebody["woeid"];
      city = responsebody["title"];
    });
  }
//function to update the information of the city/location
  Future<List<tempmodel>> catchtemp() async {
    var url = Uri.parse("https://www.metaweather.com/api/location/$woeid");
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body)["consolidated_weather"];
    setState(() {
      temp = responsebody[0]["the_temp"].round();
      weather = responsebody[0]["weather_state_name"];
      abbr = responsebody[0]["weather_state_abbr"];
    });

    List<tempmodel> list = [];
    for (var i in responsebody) {
      tempmodel x = tempmodel(
          applicable_date: i["applicable_date"],
          max_temp: i["max_temp"],
          min_temp: i["min_temp"],
          weather_state_abbr: i["weather_state_abbr"]);
      list.add(x);
    }

    return list;
  }
//refreshing the data for the listviewBuilder as it is an api function to help us to get the wanted data
  Future<void> onSubmittedtext(String input) async {
    await catchcity(input);
    await catchtemp();
  }
  // calling the above two functions respectively but it has to wait for each other

  Widget build(BuildContext context) {
    return Container(
      // starting with that decoration box to have a background image
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/${weather}.jpg"),
          // it changes while updating from the function
          fit: BoxFit.cover,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,

          body: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                            child: Image.network(
                              "https://www.metaweather.com/static/img/weather/png/${abbr}.png",
                              // it changes with the updates icon weather
                              width: 130,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(
                            child: Text(
                              "$temp °C",
                              // it changes with the updates
                              style: TextStyle(fontSize:35, color: Colors.white),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                            child: Text(
                              "$city",
                              //name of the city updated with the changes
                              style: TextStyle(fontSize: 39, color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(27),
                        child: TextField(
                          // take input from the user in the textfield
                          onSubmitted: (String In) {
                            onSubmittedtext(In);
                            // while entering the name of the city
                          },
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                          ),
                          cursorHeight:12.0 ,
                          decoration: InputDecoration(
                            hintText: " Search for a City....",
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 33,
                                fontWeight: FontWeight.w500),
                            prefixIcon: Icon(
                              Icons.search_outlined,
                              size:35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 250,
                        child: FutureBuilder(
                          future: catchtemp(),
                          // calling the function in the future field
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              //checking if there is data or not
                              return ListView.builder(
                                //the length it depends on how much data handled
                                itemCount: snapshot.data.length,
                                scrollDirection: Axis.horizontal,
                                //context is where you are in the code instantly and i is the index
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      color: Color.fromRGBO(99, 122, 120,0.9),
                                      margin: EdgeInsets.all(10),
                                      shadowColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20)),
                                      ),
                                      elevation: 20.0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Container(
                                          color: Colors.transparent,
                                          height: 190,
                                          width: 180,
                                          child:Column(
                                            mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // display the data here
                                              Text(" Date: ${snapshot.data[i].applicable_date}",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w500),),
                                              Text(" City: ${city} ",style: TextStyle(fontSize:20,color: Colors.white,fontWeight: FontWeight.w500),),
                                              Image.network(
                                                "https://www.metaweather.com/static/img/weather/png/${snapshot.data[i].weather_state_abbr}.png",
                                                width: 50,
                                              ),
                                              Text(" Min: ${snapshot.data[i].min_temp.round()} ",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w500),),
                                              Text(" Max: ${snapshot.data[i].max_temp.round()} ",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.w500),),
                                            ],

                                          ) ,
                                        ),
                                      ),

                                    ),
                                  );
                                },
                              );
                            }
                            else {
                              return  Text(" ");

                            }
                          },),
                      )
                    ],
                  ),
                ],
              ),
            ],
          )
        ),
      );
  }
}
