import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:transporter/models/bidedOrders.dart';
import 'package:transporter/providers/biddedOrdersProvider.dart';
import 'package:transporter/providers/transporterDataProvider.dart';
import 'package:transporter/widgets/map_details.dart';
import 'package:transporter/widgets/order_details.dart';
import 'package:transporter/widgets/personal_details.dart';

class OrderPage extends StatefulWidget {
  final args;
  const OrderPage({Key? key, this.args}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState(args);
}

class _OrderPageState extends State<OrderPage> {
  double newBid = 0;
  final int index;
  _OrderPageState(this.index);
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final orderData =
        context.watch<BiddedOrdersProvider>().biddedOrdersData[index];
    updateBid() async {
      var updateData = jsonEncode(<String, dynamic>{
        'orderNo': orderData.orderNo,
        'userName':
            context.read<TransporterDataProvider>().transporterData.userName,
        'bidAmount': newBid
      });

      var url = "http://10.0.2.2:7000/bid/";
      var response = await http.patch(Uri.parse(url),
          headers: {'Content-Type': 'application/json'}, body: updateData);
      var responseBody = await jsonDecode(response.body);
      context
          .read<BiddedOrdersProvider>()
          .updateOrder(BiddedOrders.fromMap(responseBody));
      Navigator.pushNamed(context, '/homepage');
      final snackBar = SnackBar(
        content: Row(children: [
          Icon(
            Icons.verified_outlined,
            color: Colors.green,
          ),
          Text("Bid Updated"),
        ]),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    bool compareTime =
        DateTime.parse(orderData.biddingTime.end).isBefore(DateTime.now());
    Size size = MediaQuery.of(context).size;

    Widget buttons(BuildContext context) {
      return Column(
        children: [
          TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF399DBC))),
            onPressed: () {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: AlertDialog(
                        title: Icon(
                          Icons.money,
                          size: 40,
                          color: Colors.green,
                        ),
                        content: Column(children: [
                          Text(
                            'Confirm Bid',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              'Your Bid: ${orderData.bids.bidAmount[0]}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  wordSpacing: 5,
                                  fontSize: 15),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Lowest Bid: ${orderData.bids.bidAmount.reduce((curr, next) => curr < next ? curr : next)}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  wordSpacing: 5,
                                  fontSize: 15),
                            ),
                          ),
                          SizedBox(height: 10),
                          Form(
                            key: _formkey,
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "* New bid cannot be Empty";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    newBid = double.parse(value);
                                  });
                                }
                              },
                              textAlign: TextAlign.left,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                prefixIcon: Icon(Icons.attach_money_outlined,
                                    color: Colors.green),
                                hintText: "New bid",
                              ),
                            ),
                          )
                        ]),
                        actions: [
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    updateBid();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('Confirm')),
                          ),
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel')),
                          ),
                        ],
                      ),
                    );
                  });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.update,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Update Bid",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Cancel Bid",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFDBE4FF),
      body: SafeArea(
        child: Hero(
          tag: 0,
          child: orderData == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leadingWidth: 0,
                      backgroundColor: Color(0xFF399DBC).withOpacity(0.65),
                      pinned: true,
                      collapsedHeight: 60,
                      expandedHeight: 200,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        collapseMode: CollapseMode.parallax,
                        background: Image.network(
                          orderData.shipmentPhoto,
                          fit: BoxFit.cover,
                        ),
                        stretchModes: [StretchMode.zoomBackground],
                        title: Container(
                          width: size.width,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  padding: EdgeInsets.all(3),
                                  child: Container(
                                    height: 40,
                                    child: Column(children: [
                                      Text(
                                        "Order No: ${orderData.orderNo}",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "My Bid: ${orderData.bids.bidAmount[0]}",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ]),
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          OrderDetail(
                            args: orderData,
                          ),
                          MapDetail(
                              startPoint: orderData.startPoint,
                              endPoint: orderData.destination),
                          PersonalDetail(),
                          Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: !compareTime ? buttons(context) : null),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
