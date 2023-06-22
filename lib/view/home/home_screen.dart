import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/order_model.dart';
import 'package:honchos_restaurant_app/view/auth/login/login_screen.dart';
import 'package:honchos_restaurant_app/view/home/orderDetail/order_detail_screen.dart';
import 'package:honchos_restaurant_app/view/splash/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RestaurantHomeScreen extends StatefulWidget {

  const RestaurantHomeScreen({Key? key, }) : super(key: key);

  @override
  _RestaurantHomeScreenState createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {

  String? renterEmail = '', renterName = '', renterUid = '',  readyToCollect = '', collect = '',delivered = '';
  List<RestaurantOrdersModel> ordersList = [];
  bool isLoading = false;
  String isListEmpty = '';

  // git init
  // git add README.md
  // git commit -m "first commit"
  // git branch -M main
  // git remote add origin https://github.com/junaid4jd/honchos_restaurant_app.git
  // git push -u origin main

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isListEmpty = 'yes';
      isLoading = true;
      renterName = '';
      renterEmail = '';
      renterUid = '';
      readyToCollect = '';
      collect = '';
      delivered = '';
    });
    getOrders();
    super.initState();
  }


  getOrders() async {
    var headers = {
      'Cookie': 'restaurant_session=NUZ9J67CmsrRkWPqW765evDXDBCttdgnKtygvzSR'
    };
    var request = http.Request('GET', Uri.parse('http://restaurant.wettlanoneinc.com/api/restaurant/orders'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {

      setState(() {
        ordersList = List<RestaurantOrdersModel>.from(json.decode(responseData).map((x) => RestaurantOrdersModel.fromJson(x)));



      });


      for(int i=0 ; i<ordersList.length; i++) {

        if(ordersList[i].status.toString() == 'Accepting order') {
         setState(() {
           readyToCollect = 'yes';
         });
        } else if (ordersList[i].status.toString() == 'Ready for collection') {

          setState(() {

            collect = 'yes';
          });

        }

      }

      if(ordersList.isEmpty) {
        setState(() {
          isListEmpty = 'yes';
          isLoading = false;
        });
      } else {
        setState(() {
          isListEmpty = 'no';
          isLoading = false;
        });
      }

    }
    else if (response.statusCode == 420) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var snackBar = SnackBar(content: Text('Session expires login to continue'
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      await preferences.clear().then((value){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
    else {
      print(response.reasonPhrase);
      setState(() {
        isListEmpty = 'yes';
        isLoading = false;
      });
    }

  }


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    return

      DefaultTabController(
        length: 2,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WillPopScope(
            onWillPop:  showExitPopup,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                // iconTheme: IconThemeData(color: Colors.white),

                actions: [
                  IconButton(onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    if( prefs.getString('userEmail') != null) {

                      prefs.remove('userPhone');
                      prefs.remove('userEmail');

                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()));

                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()));
                    }


                  },icon: Icon(Icons.logout,color: Colors.white,),),
                ],
                // git remote add origin https://github.com/junaid4jd/honchos_restaurant_app.git
                // git push -f origin main
                backgroundColor: lightRedColor,
                bottom: TabBar(
                  onTap: (index) {
                    // Tab index when user select it, it start from zero
                  },
                  tabs: [
                    Tab(text: 'New',),
                    Tab(text: 'Completed',),
                  ],
                ),
                centerTitle: true,
                title: Text('Restaurant'),
              ),
              body: TabBarView(
                children: [
                  isLoading && isListEmpty == '' ? Center(child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  )) :
                  (ordersList.isEmpty && isListEmpty == 'yes') || readyToCollect == ''   ? Center(
                    child: Container(
                      child: Text('No new orders found'),

                    ),
                  ) :
                  SizedBox(
                    // height: size.height*0.25,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ordersList.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context,index
                          ) {

                        // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                        //   totalAmount = totalAmount +
                        // }

                        return
                          ordersList[index].status.toString() == "Accepting order" ?

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrderDetailScreen(orderModel: ordersList[index],)),
                              ).then((value) {
                                setState(() {
                                  isListEmpty = 'yes';
                                });
                                getOrders();
                              });
                            },
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8,),
                                child: Container(
                                  width: size.width*0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: lightButtonGreyColor,
                                          spreadRadius: 2,
                                          blurRadius: 3
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [

                                        SizedBox(
                                          height: size.height*0.08,
                                          width: size.width*0.25,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('assets/images/order.png', fit: BoxFit.scaleDown,
                                              height: size.height*0.08,
                                              width: size.width*0.25,
                                              // height: 80,
                                              // width: 80,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          width: size.width*0.6,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('Products : ${ordersList[index].ordersItems!.length}',
                                                      style: TextStyle(color: Colors.black,
                                                          fontSize: 14,fontWeight: FontWeight.w500),),
                                                  ],),

                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text('Order Number: ${ordersList[index].orderNo.toString()}',
                                                      style: TextStyle(color: Color(0xFF585858),
                                                          fontSize: 12,fontWeight: FontWeight.w400),),
                                                  ],),
                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
                                                          + ' '  +DateFormat.jm().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()

                                                      ,
                                                      style: TextStyle(color: Color(0xFF585858),
                                                          fontSize: 12,fontWeight: FontWeight.w500),),


                                                    // Text('\$30.99',
                                                    //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),

                                                  ],),

                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(ordersList[index].status.toString(),
                                                          style: TextStyle(color: Colors.white,
                                                              fontSize: 12,fontWeight: FontWeight.w600),),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),




                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            ],),
                          )

                              : Container();
                      },

                    ),
                  ),


                  isLoading && isListEmpty == '' ? Center(child: CircularProgressIndicator(
                    color: darkRedColor,
                    strokeWidth: 1,
                  )) :


                  (ordersList.isEmpty && isListEmpty == 'yes') || delivered == '' ? Center(
                    child: Container(
                      child: Text('No delivered orders found'),

                    ),
                  ) :
                  SizedBox(
                    // height: size.height*0.25,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ordersList.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context,index
                          ) {

                        // for(int i=0; i<ordersList[index].ordersItems!.length ; i++) {
                        //   totalAmount = totalAmount +
                        // }

                        return
                          ordersList[index].status.toString() == "Delivered" ?

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrderDetailScreen(orderModel: ordersList[index],)),
                              ).then((value) {
                                setState(() {
                                  isListEmpty = 'yes';
                                });
                                getOrders();
                              });
                            },
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8,),
                                child: Container(
                                  width: size.width*0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: lightButtonGreyColor,
                                          spreadRadius: 2,
                                          blurRadius: 3
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [

                                        SizedBox(
                                          height: size.height*0.08,
                                          width: size.width*0.25,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('assets/images/order.png', fit: BoxFit.scaleDown,
                                              height: size.height*0.08,
                                              width: size.width*0.25,
                                              // height: 80,
                                              // width: 80,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          width: size.width*0.6,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('Products : ${ordersList[index].ordersItems!.length}',
                                                      style: TextStyle(color: Colors.black,
                                                          fontSize: 14,fontWeight: FontWeight.w500),),

                                                    // SizedBox(
                                                    //   height: 20,
                                                    //   width: 20,
                                                    //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                                    //
                                                    //     // height: 80,
                                                    //     // width: 80,
                                                    //   ),
                                                    //),
                                                  ],),

                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text('Order Number: ${ordersList[index].orderNo.toString()}',
                                                      style: TextStyle(color: Color(0xFF585858),
                                                          fontSize: 12,fontWeight: FontWeight.w400),),
                                                    // SizedBox(
                                                    //   height: 20,
                                                    //   width: 20,
                                                    //   child: Image.asset('assets/images/cross.png', fit: BoxFit.scaleDown,
                                                    //
                                                    //     // height: 80,
                                                    //     // width: 80,
                                                    //   ),
                                                    //),
                                                  ],),
                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateFormat.yMMMMd().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()
                                                          + ' '  +DateFormat.jm().format(DateTime.parse(ordersList[index].createdAt.toString())).toString()

                                                      ,
                                                      style: TextStyle(color: Color(0xFF585858),
                                                          fontSize: 12,fontWeight: FontWeight.w500),),


                                                    // Text('\$30.99',
                                                    //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),

                                                  ],),

                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.green
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(ordersList[index].status.toString(),
                                                          style: TextStyle(color: Colors.white,
                                                              fontSize: 12,fontWeight: FontWeight.w600),),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(
                                                  height: size.height*0.01,
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),




                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            ],),
                          ) :
                          Container();
                      },

                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      );
  }

  Future<bool> showExitPopup() async {


      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit the App?'),
          actions:[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: primaryColor,
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(false),
              //return false when click on "NO"
              child:Text('No'),
            ),

            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },



              //return true when click on "Yes"
              style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              child:Text('Yes'),
            ),

          ],
        ),
      )??false;

    //if showDialouge had returned null, then return false
  }

}
