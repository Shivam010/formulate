import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  // SystemChrome.setEnabledSystemUIOverlays([]);
  return runApp(Main());
}

const Color DarkGray = Color(0xFF333333);
const Color LightGrey = Color(0xFFA6A6A6);
const Color ActiveGrey = Color(0xFF222222);
const Color Orange = Color(0xFFDE9500);
const Color Greyish = Color(0xFF696969);
const Color Yellowish = Color(0xFFFEB000);
const Color White = Color(0xCCFFFFFF);
const Color TransBlack = Color(0x00111111);

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Formulate",
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Pt-Serif',
        ),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Presentor(),
        ),
      );
}

class Presentor extends StatefulWidget {
  @override
  _PresentorState createState() => _PresentorState();
}

class _PresentorState extends State<Presentor> {
  bool isHighActive;
  double high, low;
  String highS, lowS;
  double sell, buy;
  AverageData data = AverageData(error: "", buy: 0, min: 0, sell: 0, max: 0);

  @override
  void initState() {
    super.initState();
    reset();
  }

  reset() {
    setState(() {
      isHighActive = true;
      highS = "";
      lowS = "";
      high = 0.0;
      low = 0.0;
      sell = 0.0;
      buy = 0.0;
      calculate();
    });
  }

  changeActive(String to) {
    setState(() {
      if (to == "") {
        isHighActive = !isHighActive;
      } else if (to == "High") {
        isHighActive = true;
      } else if (to == "Low") {
        isHighActive = false;
      }
      calculate();
    });
  }

  btnPress(String val) {
    int maxLength = val == "00" || val == "•" ? 7 : 8;

    if (double.tryParse(val) != null) {
      if (isHighActive) {
        if (highS.length < maxLength) highS += val;
      } else {
        if (lowS.length < maxLength) lowS += val;
      }
      calculate();
      return;
    }

    // if some other operation
    if (val == '»') {
      changeActive("");
    } else if (val == "ac") {
      reset();
    } else if (val == 'c') {
      setState(() {
        if (isHighActive) {
          highS = "";
        } else {
          lowS = "";
        }
      });
    } else if (val == '-') {
      setState(() {
        if (isHighActive) {
          if (highS.length > 1) {
            highS = highS.substring(0, highS.length - 1);
          }
        } else {
          if (lowS.length > 1) {
            lowS = lowS.substring(0, lowS.length - 1);
          }
        }
      });
    } else if (val == '•') {
      if (isHighActive) {
        if (!highS.contains(".") && highS.length < maxLength) {
          highS += ".";
        }
      } else {
        if (!lowS.contains(".") && lowS.length < maxLength) {
          lowS += ".";
        }
      }
    }
    calculate();
  }

  calculate() {
    high = double.tryParse(highS);
    low = double.tryParse(lowS);
    high = high == null ? 0 : high;
    low = low == null ? 0 : low;
    setState(() {
      double c = (high - low) / 4;
      sell = high - c;
      buy = low + c;
    });
  }

  void _showModalSheet(AverageData d) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                color: ActiveGrey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(
                      "API Output",
                      style: TextStyle(
                        fontSize: 30,
                        color: Orange,
                      ),
                      textAlign: TextAlign.right,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        display("Sell Cap", data.sell.toStringAsFixed(2)),
                        display("Buy Cap", data.buy.toStringAsFixed(2)),
                      ],
                    ),
                    data.error != null
                        ? Text(
                            "Error: " + data.error.toString(),
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        : Container(),
                    SizedBox(height: 5.0),
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (_) {
        Future<AverageData> res = fetchData();
        res.then((d) {
          setState(() {
            data = d;
          });
        });
        _showModalSheet(data);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            "FORMULATE",
            style: TextStyle(
              fontSize: 30,
              color: Yellowish,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            textWidthBasis: TextWidthBasis.parent,
          ),
          SizedBox(height: 5.0),
          Container(
            color: TransBlack,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    display("High", highS == "" ? "0.00" : highS),
                    display("Low", lowS == "" ? "0.00" : lowS),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    display("Sell Cap", sell.toStringAsFixed(2)),
                    display("Buy Cap", buy.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              btn('7', true),
              // SizedBox(width: 3),
              btn('8', true),
              SizedBox(width: 3),
              btn('9', true),
              SizedBox(width: 3),
              btn('ac', false),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              btn('4', true),
              SizedBox(width: 3),
              btn('5', true),
              SizedBox(width: 3),
              btn('6', true),
              SizedBox(width: 3),
              btn('c', false),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              btn('1', true),
              // SizedBox(width: 3),
              btn('2', true),
              SizedBox(width: 3),
              btn('3', true),
              SizedBox(width: 3),
              btn('-', false),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              btn('0', true),
              SizedBox(width: 3),
              btn('00', true),
              SizedBox(width: 3),
              btn('•', true),
              SizedBox(width: 3),
              btn('»', false),
            ],
          ),
          SizedBox(height: 10.0)
        ],
      ),
    );
  }

  Widget display(String label, String value) {
    bool isHigh = label == "High";
    bool isInput = label == "High" || label == "Low";
    return GestureDetector(
      onTap: () => isInput ? changeActive(label) : () {},
      child: Container(
        width: 7 + MediaQuery.of(context).size.width / 2.1,
        decoration: new BoxDecoration(
          color: isInput && isHigh == isHighActive ? ActiveGrey : DarkGray,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.all(
            width: 2,
            color: isInput && isHigh == isHighActive ? ActiveGrey : DarkGray,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
              textWidthBasis: TextWidthBasis.parent,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
              textWidthBasis: TextWidthBasis.parent,
            ),
          ],
        ),
      ),
    );
  }

  Widget btn(String btntext, bool normalColor) {
    return Container(
      padding: EdgeInsets.only(left: 10, bottom: 10),
      child: RaisedButton(
        child: Text(
          btntext,
          style: TextStyle(
            fontSize: 40.0,
            color: Colors.white,
          ),
        ),
        onPressed: () => btnPress(btntext),
        elevation: 10,
        highlightElevation: 2,
        color: normalColor ? DarkGray : Orange,
        padding: EdgeInsets.all(20.0),
        splashColor: normalColor ? Greyish : Yellowish,
        highlightColor: normalColor ? Greyish : Yellowish,
        shape: CircleBorder(),
      ),
    );
  }
}

class AverageData {
  double min, max;
  double buy, sell;
  String error;

  AverageData({this.min, this.max, this.buy, this.sell, this.error});

  factory AverageData.fromJson(Map<String, dynamic> json) {
    if (json['error'] != "") {
      return AverageData(error: json['error'], buy: 0, min: 0, sell: 0, max: 0);
    }
    AverageData data = AverageData(
      min: json['data']['average']['min'].toDouble(),
      max: json['data']['average']['max'].toDouble(),
      buy: json['data']['average']['buy_cap'].toDouble(),
      sell: json['data']['average']['sell_cap'].toDouble(),
    );
    return data;
  }
}

Future<AverageData> fetchData() async {
  print("called");
  final response = await http
      .get('https://shivam010.herokuapp.com/api/v1?commodity=Crudeoil');

  if (response.statusCode == 200) {
    return AverageData.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load post');
  }
}
