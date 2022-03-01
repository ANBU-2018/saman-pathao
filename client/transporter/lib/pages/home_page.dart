import 'package:flutter/material.dart';
import 'package:transporter/models/transporters.dart';
import 'package:transporter/widgets/order_cards.dart';

class Homepage extends StatefulWidget {
  final args;
  const Homepage({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState(args);
}

class _HomepageState extends State<Homepage> {
  final transporter;
  _HomepageState(this.transporter);
  @override
  Widget build(BuildContext context) {
    final Transporters transporterData = Transporters.fromMap(transporter);
    final imageUrl = transporterData.photo;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFDBE4FF),
        appBar: AppBar(
          backgroundColor: Color(0xFF399DBC).withOpacity(0.65),
          automaticallyImplyLeading: false,
          title: Text(
            "Saman Pathao",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40)),
                      child: Padding(
                          padding: EdgeInsets.all(8), child: Text("My Bids")),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40)),
                      child: Padding(
                          padding: EdgeInsets.all(8), child: Text("New Bids")),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(18))),
                padding: EdgeInsets.all(10),
                height: 170,
                child: !transporterData.biddedOrders.isEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: transporterData.biddedOrders.length,
                        itemBuilder: (context, index) {
                          return OrderedCard(
                              order_1: transporterData.biddedOrders[index]);
                        },
                      )
                    : Center(
                        child: Text("There are no orders"),
                      ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(children: [
                  Text(
                    "Delivery Orders",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Text(
                      "Currently No Delivery Orders",
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}