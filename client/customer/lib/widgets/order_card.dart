import 'package:customer/models/user_data.dart';
import 'package:customer/models/user_orders.dart';
import 'package:customer/providers/orderDataProvide.dart';
import 'package:customer/providers/userData.dart';
import 'package:customer/utils/mycolor.dart';
import 'package:customer/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class OrderCard extends StatelessWidget {
  final UserOrders userOrder;
  const OrderCard({
    Key? key,
    required this.userOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<UserDataProvide>().userData;
    return Container(
      margin: EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 89, 88, 88)),
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(18.0),
              topLeft: Radius.circular(18.0))),
      width: 230,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Card(
          elevation: 0,
          child: ListTile(
            onTap: () {
              context.read<OrderDataProvide>().changeData(userOrder);
              Navigator.pushNamed(context, MyRoutes.orderPage);
            },
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              backgroundImage: NetworkImage(userOrder.photo),
            ),
            title: Text("Order: ${userOrder.orderNo}"),
            subtitle: Column(
              children: [
                Text(
                  "${userOrder.shipments[0]}",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Max Budget: ${userOrder.maxBudget}",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Lowest bid : ${userOrder.lowestbids == 0 ? "No bid" : userOrder.lowestbids}",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
