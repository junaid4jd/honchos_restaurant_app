import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:honchos_restaurant_app/constants.dart';
import 'package:honchos_restaurant_app/model/orderModel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as dp;
import 'package:geolocator/geolocator.dart';
import 'package:honchos_restaurant_app/model/order_model.dart';
import 'package:honchos_restaurant_app/model/session_model.dart';
import 'package:honchos_restaurant_app/view/chooseDriver/choose_driver_screen.dart';
import 'package:honchos_restaurant_app/view/home/home_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/restaurant_model.dart';


class OrderDetailScreen extends StatefulWidget {
  final RestaurantOrdersModel orderModel;
  const OrderDetailScreen({Key? key, required this.orderModel}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int total = 0;

  List<RestaurantModel> restaurantList = [];
  String distance = '', address = '', restaurantID = '';
  double distanceInKm = 0.0;
  bool isLoading = false;


  totalAmount() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getString('userId') != null) {
      setState(() {
        restaurantID = prefs.getString('userId').toString();
      });
      print(restaurantID + ' userId');
    }


    for(int i=0; i<widget.orderModel.ordersItems!.length; i++) {

      setState(() {
        total = total + (int.parse(widget.orderModel.ordersItems![i].payment.toString()) * int.parse(widget.orderModel.ordersItems![i].quantity.toString()));
      });

    }

  }



  updateStatus(String status) async {

    var headers = {

      'Cookie': 'restaurant_session=$cookie'
    };
    var request = http.MultipartRequest('POST', Uri.parse('http://restaurant.wettlanoneinc.com/api/restaurant/order_update_status/${widget.orderModel.id}'));
    request.fields.addAll({
      'status': status,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // setState(() {
      //   assigning = false;
      // });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RestaurantHomeScreen()),
      ).then((value) {

        var snackBar = SnackBar(content: Text('Status successfully changed to $status ',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.green,);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      });



    }
    else {
      print(response.reasonPhrase);

      // setState(() {
      //   assigning = false;
      // });

      var snackBar = SnackBar(content: Text('Something went wrong. Check your internet',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }


  }



//   void _getAddressFromLatLng() async {
//   print(widget.orderModel.order!.user!.userAddress!.latitude.toString());
//   print(widget.orderModel.order!.user!.userAddress!.longitude.toString());
// //  final coordinates =  dp.Coordinates(double.parse(widget.orderModel.order!.user!.userAddress!.latitude!), double.parse(widget.orderModel.order!.user!.userAddress!.longitude!));
//     try {
//
//
//       // final currentAddress = await GeoCode().reverseGeocoding(
//       //     latitude: currentLocation.latitude,
//       //     longitude: currentLocation.longitude);
//
//
//       List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
//           double.parse(widget.orderModel.order!.user!.userAddress!.latitude!), double.parse(widget.orderModel.order!.user!.userAddress!.longitude!)).whenComplete(() {
//
//
//
//       });
//
//       geocoding.Placemark place = placemarks[0];
//       setState(() {
//         address = '${place.street}, ${place.subLocality},${place.subAdministrativeArea} ${place.postalCode}';
//       });
//
//       // await geocoding.placemarkFromCoordinates(
//       //     double.parse(widget.orderModel.order!.user!.userAddress!.latitude!), double.parse(widget.orderModel.order!.user!.userAddress!.longitude!) )
//       //     .then((List<geocoding.Placemark> placemarks) {
//       //
//       //
//       // }).catchError((e) {
//       //   debugPrint(e);
//       // });
//     } catch (er) {
//       print(er);
//     }
//
//
//   }



  @override
  void initState() {
    // TODO: implement initState
   // _getAddressFromLatLng();
    setState(() {
      distance = '';
    });

    totalAmount();



    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
            'Order Detail',
          style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => DashBoardScreen(index:1)));
              // Scaffold.of(context).openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Image.asset(
                'assets/images/arrow_back.png',
                height: 20,
                width: 20,
                fit: BoxFit.scaleDown,
              ),
            )),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: size.width*0.8,
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
                        Text('Status ',
                          style: TextStyle(color: Colors.black,
                              fontSize: 14,fontWeight: FontWeight.w600),),


                        Container(
                          decoration: BoxDecoration(color:

                          widget.orderModel.status.toString() == 'Accepting order' || widget.orderModel.status.toString() == 'Pending' ? Colors.blue :
                          widget.orderModel.status.toString() == 'Ready for collection' ? Colors.teal :
                          widget.orderModel.status.toString() == 'Collected' ? Colors.deepOrangeAccent :
                          widget.orderModel.status.toString() == 'Delivered' ? Colors.green :
                          Colors.blue
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(

                              widget.orderModel.status.toString(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 12,fontWeight: FontWeight.bold),),
                          ),
                        ),


                      ],),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(widget.orderModel.status.toString(),
                    //       style: TextStyle(color: Colors.blue,
                    //           fontSize: 14,fontWeight: FontWeight.bold),),
                    //
                    //   ],),

                    SizedBox(
                      height: size.height*0.01,
                    ),


                  ],
                ),
              ),
            ),
            widget.orderModel.deliveryType == null ? Container() :
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

                      Container(
                        width: size.width*0.8,
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
                                  Text('Delivery ',
                                    style: TextStyle(color: Colors.black,
                                        fontSize: 14,fontWeight: FontWeight.w600),),

                                  Container(
                                    decoration: BoxDecoration(
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.orderModel.deliveryType.toString(),
                                        style: TextStyle(color: Colors.blue,
                                            fontSize: 15,fontWeight: FontWeight.bold),),
                                    ),
                                  ),

                                ],),

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
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => OrderDetailScreen(order: ordersList[index])),
                // );
              },
              child: Center(
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

                            Container(
                              width: size.width*0.8,
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
                                        Text('Order Number : ${widget.orderModel.orderNo!.toString()}',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),
                                      ],),

                                    SizedBox(
                                      height: size.height*0.01,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat.yMMMMd().format(DateTime.parse(widget.orderModel.createdAt.toString())).toString()
                                              + ' '  +DateFormat.jm().format(DateTime.parse(widget.orderModel.createdAt.toString())).toString()

                                          ,
                                          style: TextStyle(color: Color(0xFF585858),
                                              fontSize: 13,fontWeight: FontWeight.w500),),


                                        // Text('\$30.99',
                                        //   style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w600),),

                                      ],),

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

                            Container(
                              width: size.width*0.8,
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
                                        Text('Delivered To ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w600),),

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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${widget.orderModel.user!.name.toString()}\n${widget.orderModel.user!.email.toString()}\n${widget.orderModel.user!.phoneNo.toString()} ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),

                                      ],),

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

                  widget.orderModel.address != null ?
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

                            Container(
                              width: size.width*0.8,
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
                                        Text('Delivery Address ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w600),),

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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: size.width*0.7,
                                          child: Text(widget.orderModel.address.toString(),
                                            style: TextStyle(color: Colors.black,
                                                fontSize: 14,fontWeight: FontWeight.w500),),
                                        ),

                                      ],),

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
                  ) : Container(),

                  widget.orderModel.ordersItems!.isEmpty  ? Container(
                    child: Text('No order item found',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),),
                  ) :
                  SizedBox(
                    // height: size.height*0.25,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.orderModel.ordersItems!.length,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context,index
                          ) {
                        return Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16,),
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
                                padding: const EdgeInsets.all(0.0),
                                child: Row(
                                  children: [

                                    Container(
                                      decoration: BoxDecoration(
                                        color: lightButtonGreyColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          height: size.height*0.07,
                                          width: size.width*0.2,
                                          fit: BoxFit.cover,
                                          imageUrl: imageConstUrlProduct+widget.orderModel.ordersItems![index].product!.image.toString(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      height: size.height*0.07,
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
                                                Text(widget.orderModel.ordersItems![index].product!.name.toString(),
                                                  style: TextStyle(color: Color(0xFF585858),
                                                      fontSize: 14,fontWeight: FontWeight.w500),),

                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height*0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Quantity : ' + widget.orderModel.ordersItems![index].quantity.toString(),
                                                  //quantity.toString(),
                                                  style: TextStyle(color: Color(0xFF585858), fontSize: 14,fontWeight: FontWeight.w600),),
                                               // widget.order.ordersItems![index].product!.price.toString()
                                                Text('ZAR '+ '${
                                                int.parse(widget.orderModel.ordersItems![index].product!.price.toString())*int.parse(widget.orderModel.ordersItems![index].quantity.toString())
                                                }',
                                                  style: TextStyle(color: Color(0xFF585858), fontSize: 12,fontWeight: FontWeight.w600),),
                                              ],
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

                        ],);
                      },

                    ),
                  ),

                  SizedBox(
                    height: size.height*0.03,
                  ),

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

                            Container(
                              width: size.width*0.8,
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
                                        Text('Order Total : ',
                                          style: TextStyle(color: Colors.black,
                                              fontSize: 14,fontWeight: FontWeight.w500),),
                                        Text('ZAR '+total.toString(),
                                          style: TextStyle(color: Colors.red,
                                              fontSize: 12,fontWeight: FontWeight.w600),),
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
              ),
            ),



            SizedBox(
              height: size.height*0.05,
            ),
            isLoading ? Center(child: CircularProgressIndicator(
              color: darkRedColor,
              strokeWidth: 1,
            )) :

            (widget.orderModel.status.toString() == 'Collected' || widget.orderModel.status.toString() == 'Delivered')  ? Container() :
            Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: Container(

                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26, offset: Offset(0, 4), blurRadius: 5.0)
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [
                      darkRedColor,
                      lightRedColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(Size(size.width, 50)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      // elevation: MaterialStateProperty.all(3),
                      shadowColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {

                      if(widget.orderModel.deliveryType.toString() == 'Self') {

                        if(widget.orderModel.status.toString() == 'Accepting order') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Preparing your meal');
                        } else if(widget.orderModel.status.toString() == 'Preparing your meal') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Ready for collection');
                        } else if(widget.orderModel.status.toString() == 'Ready for collection') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Collected');
                        }


                      }
                      else if(widget.orderModel.deliveryType.toString() == 'Driver') {

                        if(widget.orderModel.status.toString() == 'Accepting order') {
                          setState(() {
                            isLoading = true;
                          });
                          updateStatus('Preparing your meal');
                        } else if(widget.orderModel.status.toString() == 'Preparing your meal') {

                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChooseDriverScreen(orderModel: widget.orderModel,resId: restaurantID,)));
                          // setState(() {
                          //   isLoading = true;
                          // });
                          // updateStatus('Ready for collection');
                        }



                      }
                      else {
                        var snackBar = SnackBar(content: Text('Its an old order with no delivery type'
                          ,style: TextStyle(color: Colors.white),),
                          backgroundColor: Colors.green,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }











                    }, child: Text(
                    widget.orderModel.status.toString() == 'Accepting order' ? 'Accept' :
                    widget.orderModel.status.toString() == 'Preparing your meal' && widget.orderModel.deliveryType.toString() == 'Self'  ? 'Ready' :
                    widget.orderModel.status.toString() == 'Ready for collection' && widget.orderModel.deliveryType.toString() == 'Self'  ? 'Collect' :
                    widget.orderModel.status.toString() == 'Preparing your meal' && widget.orderModel.deliveryType.toString() == 'Driver'  ? 'Assign Driver' :




                    'Submit'
                    , style: buttonStyle)),
              ),
            ),

            SizedBox(
              height: size.height*0.05,
            ),

        ],),
      ),

    );
  }
}
