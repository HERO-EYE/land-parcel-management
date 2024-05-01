import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickalert/quickalert.dart';
import 'api.dart';
import 'parcel.dart';
import 'login.dart';

class MyHome extends StatefulWidget {
  MyHome({super.key, this.user});

  final Map<String, dynamic>? user;

  @override
  State<MyHome> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHome> {

  bool once = false;
  API api = API();
  late List<TabItem> tabItems;
  List<String> modes = ["list", "map"];
  String mode = "list";
  List<Parcel>? parcels = [];
  bool alert_mode = false;
  bool parcel_mode = false;
  Parcel? selected_parcel = null;
  bool loading = true;

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(23.5991786,58.3850251),
    zoom: 14.4746,
  );


  Set<Marker> markers = Set();
  Map<String, Color> status_color = {
    "created": Colors.blueGrey,
    "in_progress" : Color(0xFFDD9A00),
    "delivered" : Colors.green,
    "failed" : Colors.redAccent
  };


  @override
  void initState() {
    getAllParcels();
    super.initState();
  }

  CameraPosition initMapCamera(double latitude, double longitude) {

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude,longitude),
      zoom: 14.4746,
    );

    return cameraPosition;
  }

  void confirmLogout() {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Do you want to logout?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: Theme.of(context).colorScheme.primary,
        onConfirmBtnTap: () {
          print("Yes");
          Navigator.pop(context);
          print("log out");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ));
        },
        onCancelBtnTap: () {
          print("No");
          Navigator.pop(context);
        }
    );
  }

  void getAllParcels() async {
    loading = true;
    api.getLandParcels(widget.user!["id"]).then((value) {
      try {
        setState(() {
          parcels = value;
        });
      } catch(e) {}
      loading = false;
    });

  }

  String formatDatetime(String dtStr) {
    DateTime dt = DateTime.parse(dtStr);
    return dt.format("Y-n-d g:i A");
  }

  Widget parcelPagePart() {

    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            parcel_mode = false;
                          });
                        },
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                              onPressed: () {
                                setState(() {
                                  parcel_mode = false;
                                });
                              },
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text("Back", style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold), )
                          ],
                        ),
                      )
                  ),
                  Center(
                    child: Column(
                      children: [
                        Expanded(child: Image.asset( selected_parcel==null ? "assets/images/land_location.png" : (selected_parcel!.zoning==null ? "assets/images/land_location.png" : "assets/images/${selected_parcel!.zoning!["zoning_type"]}.png")),),
                      ],
                    ),
                  )
                ],
              )
          ),
        ),

        Expanded(
          flex: 7,
          child: Container(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: Text("Info", style: TextStyle(fontSize: maxHeight/50, color: Colors.white, fontWeight: FontWeight.bold),),
                                        ),

                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            // margin: EdgeInsets.fromLTRB(2, 0, 0, 0),
                                            child: Card(
                                              elevation: 5, // Adjust elevation as desired
                                              shape: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15), // Customize border radius
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Owenr', style: TextStyle(fontSize: maxHeight/65)),
                                                  Text(selected_parcel!=null ? selected_parcel!.owner!["name"] : "" , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            // margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                            child: Card(
                                              elevation: 5, // Adjust elevation as desired
                                              shape: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15), // Customize border radius
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Parcel Number', style: TextStyle(fontSize: maxHeight/65)),
                                                  Text(selected_parcel!=null ? selected_parcel!.parcel_number.toString() : ""  , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: Text("", style: TextStyle(fontSize: maxHeight/55, color: Colors.black54, fontWeight: FontWeight.bold),),
                                        ),

                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Card(
                                              elevation: 5, // Adjust elevation as desired
                                              shape: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15), // Customize border radius
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Area', style: TextStyle(fontSize: maxHeight/65)),
                                                  Text(selected_parcel!=null ? "${selected_parcel!.area.toString()} m\u00b2": "" , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Card(
                                              elevation: 5, // Adjust elevation as desired
                                              shape: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15), // Customize border radius
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Zoning Type', style: TextStyle(fontSize: maxHeight/65)),
                                                  Text(selected_parcel!=null ? (selected_parcel!.zoning==null ? "" : selected_parcel!.zoning!["zoning_type"]) : ""  , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    // color: Colors.red,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: Text("Location", style: TextStyle(fontSize: maxHeight/50, color: Colors.white, fontWeight: FontWeight.bold),),
                                        ),

                                        Expanded(
                                          flex: 2,
                                            child: Container(
                                              child: Card(
                                                elevation: 5, // Adjust elevation as desired
                                                shape: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(15), // Customize border radius
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('City', style: TextStyle(fontSize: maxHeight/65)),
                                                    Text(selected_parcel!=null ? selected_parcel!.city! : "" , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),

                                                  ],
                                                ),
                                              ),
                                            ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            // margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                              child: Card(
                                                elevation: 5, // Adjust elevation as desired
                                                shape: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(15), // Customize border radius
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text('Address', style: TextStyle(fontSize: maxHeight/65)),
                                                    Text(selected_parcel!=null ? (selected_parcel!.address==null ? "" : selected_parcel!.address!) : ""  , style: TextStyle(fontSize: maxHeight/55, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                  ],
                                                ),
                                              ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: GoogleMap(
                                    mapType: MapType.hybrid,
                                    initialCameraPosition: selected_parcel!.geometry_latitude==0 ? _kGooglePlex : initMapCamera(selected_parcel!.geometry_latitude!, selected_parcel!.geometry_longitude!),
                                    onMapCreated: (GoogleMapController controller) {
                                      _controller.complete(controller);

                                      if(selected_parcel!.geometry_latitude!=0) {
                                        controller.moveCamera(
                                            CameraUpdate.newLatLng(LatLng(
                                                selected_parcel!.geometry_latitude!,
                                                selected_parcel!.geometry_longitude!)));

                                        Marker newMarker = Marker(
                                          markerId: MarkerId(
                                              selected_parcel!.id.toString()),
                                          position: LatLng(
                                              selected_parcel!.geometry_latitude!,
                                              selected_parcel!.geometry_longitude!),
                                          infoWindow: InfoWindow(
                                            title: selected_parcel!.parcel_number,
                                          ),
                                        );

                                        setState(() {
                                          markers.add(newMarker);
                                        });
                                      }
                                    },
                                    markers: markers,
                                  ),
                                ),

                              ],
                            )
                        )

                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text("Delivery", style: TextStyle(fontSize: maxHeight/50, color: Colors.white, fontWeight: FontWeight.bold),),
                                  ),
                                ),

                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child: Card(
                                                      elevation: 5, // Adjust elevation as desired
                                                      shape: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(15), // Customize border radius
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text('Added Date', style: TextStyle(fontSize: maxHeight/65)),
                                                          Text(selected_parcel!=null ? ( selected_parcel!.delivery==null ? "" : formatDatetime(selected_parcel!.delivery!["created_date"])) : "" , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child: Card(
                                                      elevation: 5, // Adjust elevation as desired
                                                      shape: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(15), // Customize border radius
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text('Expected Deliv. Date', style: TextStyle(fontSize: maxHeight/65)),
                                                          Text(selected_parcel!=null ? ( selected_parcel!.delivery==null ? "--" : ( selected_parcel!.delivery!["delivery_date"]==null ? "--" : formatDatetime(selected_parcel!.delivery!["delivery_date"])) ) : "--"  , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ),

                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  // margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                  child: Card(
                                                    elevation: 5, // Adjust elevation as desired
                                                    shape: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15), // Customize border radius
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('Status', style: TextStyle(fontSize: maxHeight/65)),
                                                        Text(selected_parcel!=null ? ( selected_parcel!.delivery==null ? "" : selected_parcel!.delivery!["delivery_status"]) : "" , style: TextStyle(fontSize: maxHeight/50, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            )
                        )

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget ParcelWidget(Parcel parcel) {
    double maxHeight = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.tertiary
      ),
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      height: maxHeight/7,
      child: InkWell(
        onTap: () {
          setState(() {
            selected_parcel = parcel;
            parcel_mode = true;
          });
        },
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Parcel # ${parcel.parcel_number}" ,style: TextStyle(fontSize: maxHeight/55, color: Colors.white),),
                      Text( (parcel.city!=null ? "${parcel.city}" : "") + (parcel.address!=null ? " ${parcel.address}" : "") ,style: TextStyle(fontSize: maxHeight/55, color: Colors.white)),
                      Text(parcel.zoning!=null ? "${parcel.zoning!["zoning_type"]}" : "",style: TextStyle(fontSize: maxHeight/55, color: Colors.white)),
                    ],
                  ),
                )
            ),
            Expanded(
                flex: 3,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white54
                    ),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: parcel.delivery==null ? Container(): Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Date: ",style: TextStyle(fontSize: maxHeight/65, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            Text( formatDatetime(parcel!.delivery!["created_date"].toString()) ,style: TextStyle(fontSize: maxHeight/65, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Status: ",style: TextStyle(fontSize: maxHeight/65, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: status_color[parcel.delivery!["delivery_status"]]
                              ),
                              padding: EdgeInsets.all(5),
                              child: Text("${parcel.delivery!["delivery_status"]}",style: TextStyle(fontSize: maxHeight/65, color: Colors.white70, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text("Exp. Delivery: ",style: TextStyle(fontSize: maxHeight/65, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            Text(parcel.delivery!["delivery_date"]==null ? "--":"${parcel.delivery!["delivery_date"].toString().split("T")[0]}",style: TextStyle(fontSize: maxHeight/70, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                )
            )
          ],
        ),
      ),
    );
  }

  Future<Uint8List> getImages(String path, int width) async{
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return(await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Widget parcelsMap() {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) async {
        try {
          if(!_controller.isCompleted) _controller.complete(controller);
        } catch(e) {}

        markers = Set<Marker>();
        parcels!.forEach((parcel) async {
          if (parcel!.geometry_latitude!=0 && parcel!.geometry_longitude!=0) {
            String zoningType = parcel.zoning!["zoning_type"];
            String zoningImage = "assets/images/$zoningType.png";
            final Uint8List markIcons = await getImages(zoningImage, 50);

            Marker marker = Marker(
              markerId: MarkerId('${parcel.id}'),
              position: LatLng(parcel!.geometry_latitude!, parcel!.geometry_longitude!),
              icon: BitmapDescriptor.fromBytes(markIcons),
              infoWindow: InfoWindow(
                title: parcel!.parcel_number,
              ),
            );

            setState(() {
              markers.add(marker);
            });
          }
        });
        await Future.delayed(const Duration(seconds: 1)).then((value) => _moveToFitMarkers());
      },
      markers: markers,
    );
  }

  void _moveToFitMarkers() async {
    GoogleMapController controller = await _controller.future;

    LatLngBounds bounds = _createBounds(markers);
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));

  }

  LatLngBounds _createBounds(Set<Marker> markers) {

    LatLngBounds bounds = LatLngBounds(southwest: markers.first.position, northeast: markers.first.position);


    for (int i=1 ; i<markers.length ; i++) {
      bounds = LatLngBounds(
        southwest: LatLng(min(bounds.southwest.latitude, markers.elementAt(i).position.latitude),
            min(bounds.southwest.longitude, markers.elementAt(i).position.longitude)),
        northeast: LatLng(max(bounds.northeast.latitude, markers.elementAt(i).position.latitude),
            max(bounds.northeast.longitude, markers.elementAt(i).position.longitude)),
      );
    }

    return bounds;
  }

  @override
  Widget build(BuildContext context) {

    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;

    tabItems = List.of([
      TabItem(Icons.home, "Home", Theme.of(context).colorScheme.primary, labelStyle: TextStyle(fontWeight: FontWeight.bold)),
      TabItem(Icons.navigation, "Mission", Theme.of(context).colorScheme.primary, labelStyle: TextStyle(fontWeight: FontWeight.bold)),
      TabItem(Icons.layers, "Reports", Theme.of(context).colorScheme.primary, labelStyle: TextStyle(fontWeight: FontWeight.bold)),
      TabItem(Icons.notifications, "Notifications", Theme.of(context).colorScheme.primary, labelStyle: TextStyle(fontWeight: FontWeight.bold)),
    ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: Center(child: Text("LAND-GRID", style: TextStyle(color: Colors.white, fontSize: maxHeight/33),),),
        leading: const Text(""),
        actions: [
          IconButton(onPressed: (){
            confirmLogout();
          }, icon: Icon(Icons.logout, color: Colors.white,))
        ],
      ),
      body: parcel_mode ?
      parcelPagePart()
          :
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Image.asset("assets/images/logo.png"),
              ),
            ),

            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text("Welcome " + widget.user!["name"], style: TextStyle(fontSize: maxHeight/44, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),),
                    ),
                  ],
                )
            ),

            Expanded(
                flex: 9,
                child: Container(
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primary.withAlpha(80)
                  ),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          mode = modes.first;
                                        });
                                      },
                                      child: Container(
                                        decoration: mode=="list" ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Theme.of(context).colorScheme.tertiary,
                                        ) : BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(width: 5, color: Theme.of(context).colorScheme.tertiary)
                                        ),
                                        margin: EdgeInsets.all(10),
                                        child: Center(child: Text("List", style: TextStyle(color: mode=="list" ? Colors.white : Theme.of(context).colorScheme.tertiary, fontSize: maxHeight/40, fontWeight: FontWeight.bold),),),
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          mode = modes.last;
                                        });
                                      },
                                      child: Container(
                                        decoration: mode=="map" ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Theme.of(context).colorScheme.tertiary,
                                        ) : BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(width: 5, color: Theme.of(context).colorScheme.tertiary)
                                        ),
                                        margin: EdgeInsets.all(10),
                                        child: Center(child: Text("Map", style: TextStyle(color: mode=="map" ? Colors.white : Theme.of(context).colorScheme.tertiary, fontSize: maxHeight/40, fontWeight: FontWeight.bold),),),
                                      ),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),

                      Expanded(
                          flex: 7,
                          child: (mode==modes.first) ?
                        loading ?  const Center(child: CircularProgressIndicator(),) : Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 5, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children:
                                parcels!.map((e) => ParcelWidget(e)).toList(),
                              ),
                            ),

                          )
                              :
                              parcelsMap()
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
