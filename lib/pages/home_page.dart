import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '/authentication/login_screen.dart';
import '/global/global_var.dart';
import '/global/trip_var.dart';
import '/methods/common_methods.dart';
import '/methods/manage_drivers_methods.dart';
import '/methods/push_notification_service.dart';
import '/models/direction_details.dart';
import '/models/online_nearby_drivers.dart';
import '/pages/about_page.dart';
import '/pages/search_destination_page.dart';
import '/pages/trips_history_page.dart';
import '/widgets/info_dialog.dart';
import '/widgets/payment_card.dart';

import '../../../appInfo/app_info.dart';
import '../../../widgets/loading_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 0;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;
  bool requestingDirectionDetailsInfo = false;

  // Variáveis do seu NG EXPRESS
  String _activeTab = 'enviar';
  bool _showDestinationForm = false;
  bool _showSenderForm = false;
  bool _showVehicleSelection = false;
  bool _showItemDetails = false;
  bool _deliveryAddressSet = false;
  bool _showDeliveryDetails = false;
  bool _showPayment = false;
  String _selectedVehicle = 'moto';
  String _selectedPaymentMethod = 'cash';
  String _selectedItemType = 'Itens pessoais';
  String _itemValue = '';
  String _deliveryNotes = '';

  // Mapeamentos do seu NG EXPRESS
  final Map<String, String> _paymentMethodDisplay = {
    'cash': 'Dinheiro',
    'card': 'Cartão',
    'pix': 'PIX',
    'wallet': 'Carteira Digital',
  };

  final Map<String, IconData> _paymentMethodIcons = {
    'cash': Icons.payments,
    'card': Icons.credit_card,
    'pix': Icons.pix,
    'wallet': Icons.account_balance_wallet,
  };

  final Map<String, Color> _paymentMethodColors = {
    'cash': Colors.green,
    'card': Colors.purple,
    'pix': Colors.blue,
    'wallet': Colors.orange,
  };

  final Map<String, String> _paymentMethodBalances = {
    'cash': 'Saldo disponível: R\$0,36',
    'card': 'Cartão salvo',
    'pix': 'PIX disponível',
    'wallet': 'Saldo: R\$125,00',
  };

  final Map<String, IconData> _itemIcons = {
    'Itens pessoais': Icons.person,
    'Alimentação': Icons.fastfood,
    'Vestuário': Icons.checkroom,
    'Eletrônicos': Icons.devices,
    'Documentos': Icons.description,
    'Chaves': Icons.key,
    'Medicamentos': Icons.medical_services,
    'Outros': Icons.more_horiz,
  };

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Configuração inicial do mapa
    setState(() {
      searchContainerHeight = 276;
      bottomMapPadding = 300;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (tripStreamSubscription != null) {
      tripStreamSubscription!.cancel();
    }
    super.dispose();
  }

  void _switchTabs(String newTab) {
    if (newTab != _activeTab) {
      _animationController.forward(from: 0.0).then((_) {
        setState(() {
          _activeTab = newTab;
        });
        _animationController.reverse();
      });
    }
  }

  makeDriverNearbyCarIcon() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(
        context,
        size: Size(0.5, 0.5),
      );
      BitmapDescriptor.fromAssetImage(
        configuration,
        "assets/images/tracking.png",
      ).then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes(
      "themes/night_style.json",
    ).then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
      currentPositionOfUser!.latitude,
      currentPositionOfUser!.longitude,
    );

    CameraPosition cameraPosition = CameraPosition(
      target: positionOfUserInLatLng,
      zoom: 15,
    );
    controllerGoogleMap!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    // FIXED: Changed to instance method
    // await cMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
    // currentPositionOfUser!,
    // context,
    //);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => LoginScreen()),
          );
          cMethods.displaySnackBar(
            "Você foi bloqueado. Contate o admin: alizeb875@gmail.com",
            context,
          );
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => LoginScreen()),
        );
      }
    });
  }

  displayUserRideDetailsContainer() async {
    await retrieveDirectionDetails();

    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 242;
      isDrawerOpened = false;
    });
  }

  retrieveDirectionDetails() async {
    var pickUpLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).dropOffLocation;

    if (pickUpLocation == null || dropOffDestinationLocation == null) {
      return;
    }

    var pickupGeoGraphicCoOrdinates = LatLng(
      pickUpLocation.latitudePosition!,
      pickUpLocation.longitudePosition!,
    );
    var dropOffDestinationGeoGraphicCoOrdinates = LatLng(
      dropOffDestinationLocation.latitudePosition!,
      dropOffDestinationLocation.longitudePosition!,
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Calculando rota..."),
    );

    // FIXED: Changed to instance method
    var detailsFromDirectionAPI = await cMethods.getDirectionDetailsFromAPI(
      pickupGeoGraphicCoOrdinates,
      dropOffDestinationGeoGraphicCoOrdinates,
    );
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    Navigator.pop(context);

    // Desenhar rota do pickup ao destino
    PolylinePoints pointsPolyline = PolylinePoints();
    // FIXED: Changed to static method call
    List<PointLatLng> latLngPointsFromPickUpToDestination = PolylinePoints()
        .decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);

    polylineCoOrdinates.clear();
    if (latLngPointsFromPickUpToDestination.isNotEmpty) {
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint) {
        polylineCoOrdinates.add(
          LatLng(latLngPoint.latitude, latLngPoint.longitude),
        );
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.orange[400]!,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    // Ajustar mapa para mostrar toda a rota
    LatLngBounds boundsLatLng;
    if (pickupGeoGraphicCoOrdinates.latitude >
            dropOffDestinationGeoGraphicCoOrdinates.latitude &&
        pickupGeoGraphicCoOrdinates.longitude >
            dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: dropOffDestinationGeoGraphicCoOrdinates,
        northeast: pickupGeoGraphicCoOrdinates,
      );
    } else if (pickupGeoGraphicCoOrdinates.longitude >
        dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
          pickupGeoGraphicCoOrdinates.latitude,
          dropOffDestinationGeoGraphicCoOrdinates.longitude,
        ),
        northeast: LatLng(
          dropOffDestinationGeoGraphicCoOrdinates.latitude,
          pickupGeoGraphicCoOrdinates.longitude,
        ),
      );
    } else if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
          dropOffDestinationGeoGraphicCoOrdinates.latitude,
          pickupGeoGraphicCoOrdinates.longitude,
        ),
        northeast: LatLng(
          pickupGeoGraphicCoOrdinates.latitude,
          dropOffDestinationGeoGraphicCoOrdinates.longitude,
        ),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: pickupGeoGraphicCoOrdinates,
        northeast: dropOffDestinationGeoGraphicCoOrdinates,
      );
    }

    controllerGoogleMap!.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 72),
    );

    // Adicionar marcadores de pickup e destino
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: pickUpLocation.placeName,
        snippet: "Local de coleta",
      ),
    );

    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: dropOffDestinationLocation.placeName,
        snippet: "Local de entrega",
      ),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });

    // Adicionar círculos nos pontos
    Circle pickUpPointCircle = Circle(
      circleId: const CircleId('pickupCircleID'),
      strokeColor: Colors.orange[400]!,
      strokeWidth: 3,
      radius: 12,
      center: pickupGeoGraphicCoOrdinates,
      fillColor: Colors.orange[100]!,
    );

    Circle dropOffDestinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.orange[400]!,
      strokeWidth: 3,
      radius: 12,
      center: dropOffDestinationGeoGraphicCoOrdinates,
      fillColor: Colors.orange[100]!,
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationPointCircle);
    });
  }

  resetAppNow() {
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = 'Motorista está a caminho';
    });
  }

  cancelRideRequest() {
    if (tripRequestRef != null) {
      tripRequestRef!.remove();
    }
    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    makeTripRequest();
  }

  updateAvailableNearbyOnlineDriversOnMap() {
    setState(() {
      // Remove apenas marcadores de motoristas
      markerSet.removeWhere(
        (element) => element.markerId.value.contains("driver"),
      );
    });

    Set<Marker> markersTempSet = Set<Marker>();

    for (OnlineNearbyDrivers eachOnlineNearbyDriver
        in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(
        eachOnlineNearbyDriver.latDriver!,
        eachOnlineNearbyDriver.lngDriver!,
      );

      Marker driverMarker = Marker(
        markerId: MarkerId(
          "driver ID = " + eachOnlineNearbyDriver.uidDriver.toString(),
        ),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver ?? BitmapDescriptor.defaultMarker,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      markerSet.addAll(markersTempSet);
    });
  }

  initializeGeoFireListener() {
    // FIXED: Initialize GeoFire - make sure you have this class imported properly
    Geofire.initialize("onlineDrivers");
    Geofire.queryAtLocation(
      currentPositionOfUser!.latitude,
      currentPositionOfUser!.longitude,
      22,
    )!.listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];

        switch (onlineDriverChild) {
          case Geofire.onKeyEntered:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            ManageDriversMethods.nearbyOnlineDriversList.add(
              onlineNearbyDrivers,
            );

            if (nearbyOnlineDriversKeysLoaded == true) {
              updateAvailableNearbyOnlineDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
            updateAvailableNearbyOnlineDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            ManageDriversMethods.updateOnlineNearbyDriversLocation(
              onlineNearbyDrivers,
            );
            updateAvailableNearbyOnlineDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;
            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  makeTripRequest() {
    tripRequestRef = FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .push();

    var pickUpLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(
      context,
      listen: false,
    ).dropOffLocation;

    Map pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map dropOffDestinationCoOrdinatesMap = {
      "latitude": dropOffDestinationLocation!.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map driverCoOrdinates = {"latitude": "", "longitude": ""};

    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffDestinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,
      "vehicleType": _selectedVehicle,
      "itemType": _selectedItemType,
      "itemValue": _itemValue,
      "deliveryNotes": _deliveryNotes,
      "paymentMethod": _selectedPaymentMethod,
      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new",
    };

    tripRequestRef!.set(dataMap);

    tripStreamSubscription = tripRequestRef!.onValue.listen((
      eventSnapshot,
    ) async {
      if (eventSnapshot.snapshot.value == null) {
        return;
      }

      if ((eventSnapshot.snapshot.value as Map)["driverName"] != null) {
        nameDriver = (eventSnapshot.snapshot.value as Map)["driverName"];
      }

      if ((eventSnapshot.snapshot.value as Map)["driverPhone"] != null) {
        phoneNumberDriver =
            (eventSnapshot.snapshot.value as Map)["driverPhone"];
      }

      if ((eventSnapshot.snapshot.value as Map)["driverPhoto"] != null) {
        photoDriver = (eventSnapshot.snapshot.value as Map)["driverPhoto"];
      }

      if ((eventSnapshot.snapshot.value as Map)["carDetails"] != null) {
        carDetailsDriver = (eventSnapshot.snapshot.value as Map)["carDetails"];
      }

      if ((eventSnapshot.snapshot.value as Map)["status"] != null) {
        status = (eventSnapshot.snapshot.value as Map)["status"];
      }

      if ((eventSnapshot.snapshot.value as Map)["driverLocation"] != null) {
        double driverLatitude = double.parse(
          (eventSnapshot.snapshot.value as Map)["driverLocation"]["latitude"]
              .toString(),
        );
        double driverLongitude = double.parse(
          (eventSnapshot.snapshot.value as Map)["driverLocation"]["longitude"]
              .toString(),
        );
        LatLng driverCurrentLocationLatLng = LatLng(
          driverLatitude,
          driverLongitude,
        );

        if (status == "accepted") {
          updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng);
        } else if (status == "arrived") {
          setState(() {
            tripStatusDisplay = 'Motorista chegou';
          });
        } else if (status == "ontrip") {
          updateFromDriverCurrentLocationToDropOffDestination(
            driverCurrentLocationLatLng,
          );
        }
      }

      if (status == "accepted") {
        displayTripDetailsContainer();
        // FIXED: Geofire.stopListener() should be called
        Geofire.stopListener();

        setState(() {
          markerSet.removeWhere(
            (element) => element.markerId.value.contains("driver"),
          );
        });
      }

      if (status == "ended") {
        if ((eventSnapshot.snapshot.value as Map)["fareAmount"] != null) {
          double fareAmount = double.parse(
            (eventSnapshot.snapshot.value as Map)["fareAmount"].toString(),
          );

          var responseFromPaymentDialog = await showDialog(
            context: context,
            builder: (BuildContext context) =>
                PaymentDialog(fareAmount: fareAmount.toString()),
          );

          if (responseFromPaymentDialog == "paid") {
            tripRequestRef!.onDisconnect();
            tripRequestRef = null;

            tripStreamSubscription!.cancel();
            tripStreamSubscription = null;

            resetAppNow();

            // Mostrar tela de confirmação
            _showDeliveryConfirmation();
          }
        }
      }
    });
  }

  void _showDeliveryConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Entrega Concluída!',
          style: TextStyle(color: Colors.orange[600]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Sua entrega foi concluída com sucesso!'),
            SizedBox(height: 8),
            Text(
              'Obrigado por usar o NG EXPRESS',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.orange[600])),
          ),
        ],
      ),
    );
  }

  displayTripDetailsContainer() {
    setState(() {
      requestContainerHeight = 0;
      tripContainerHeight = 291;
      bottomMapPadding = 281;
    });
  }

  updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var userPickUpLocationLatLng = LatLng(
        currentPositionOfUser!.latitude,
        currentPositionOfUser!.longitude,
      );

      // FIXED: Changed to instance method
      var directionDetailsPickup = await cMethods.getDirectionDetailsFromAPI(
        driverCurrentLocationLatLng,
        userPickUpLocationLatLng,
      );

      if (directionDetailsPickup == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            "Motorista a caminho - ${directionDetailsPickup.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  updateFromDriverCurrentLocationToDropOffDestination(
    driverCurrentLocationLatLng,
  ) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var dropOffLocation = Provider.of<AppInfo>(
        context,
        listen: false,
      ).dropOffLocation;
      var userDropOffLocationLatLng = LatLng(
        dropOffLocation!.latitudePosition!,
        dropOffLocation.longitudePosition!,
      );

      // FIXED: Changed to instance method
      var directionDetailsPickup = await cMethods.getDirectionDetailsFromAPI(
        driverCurrentLocationLatLng,
        userDropOffLocationLatLng,
      );

      if (directionDetailsPickup == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            "A caminho do destino - ${directionDetailsPickup.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  noDriverAvailable() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => InfoDialog(
        title: "Nenhum motorista disponível",
        description:
            "Não encontramos motoristas na sua região. Tente novamente em alguns instantes.",
      ),
    );
  }

  searchDriver() {
    if (availableNearbyOnlineDriversList!.length == 0) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    var currentDriver = availableNearbyOnlineDriversList![0];
    sendNotificationToDriver(currentDriver);
    availableNearbyOnlineDriversList!.removeAt(0);
  }

  sendNotificationToDriver(OnlineNearbyDrivers currentDriver) {
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");

    currentDriverRef.set(tripRequestRef!.key);

    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();
        PushNotificationService.sendNotificationToSelectedDriver(
          deviceToken,
          context,
          tripRequestRef!.key.toString(),
        );
      }

      const oneTickPerSec = Duration(seconds: 1);

      var timerCountDown = Timer.periodic(oneTickPerSec, (timer) {
        // FIXED: Using renamed import
        trip_var.requestTimeoutDriver = trip_var.requestTimeoutDriver - 1;

        if (stateOfApp != "requesting") {
          timer.cancel();
          currentDriverRef.set("cancelled");
          currentDriverRef.onDisconnect();
          trip_var.requestTimeoutDriver = 20;
        }

        currentDriverRef.onValue.listen((dataSnapshot) {
          if (dataSnapshot.snapshot.value.toString() == "accepted") {
            timer.cancel();
            currentDriverRef.onDisconnect();
            trip_var.requestTimeoutDriver = 20;
          }
        });

        if (trip_var.requestTimeoutDriver == 0) {
          currentDriverRef.set("timeout");
          timer.cancel();
          currentDriverRef.onDisconnect();
          trip_var.requestTimeoutDriver = 20;
          searchDriver();
        }
      });
    });
  }

  // Widgets do seu NG EXPRESS
  Widget _buildSearchContent() {
    return SingleChildScrollView(
      key: ValueKey(_activeTab),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Local de coleta
          GestureDetector(
            onTap: () {
              _showSenderFormDialog();
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange[400],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeTab == 'enviar'
                              ? 'Rua Olga Bernardes Amorim, 101'
                              : 'Enviar de',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_activeTab == 'enviar') SizedBox(height: 2),
                        if (_activeTab == 'enviar')
                          Text(
                            'Gabriele · 47996412384',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Local de entrega
          GestureDetector(
            onTap: () async {
              var responseFromSearchPage = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => SearchDestinationPage()),
              );

              if (responseFromSearchPage == "placeSelected") {
                displayUserRideDetailsContainer();
              }
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange[400]!, width: 2),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _activeTab == 'enviar'
                          ? 'Entregar para'
                          : 'Rua Olga Bernardes Amorim, 101',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          ElevatedButton(
            onPressed: _deliveryAddressSet
                ? () {
                    setState(() {
                      _showDeliveryDetails = true;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _deliveryAddressSet
                  ? Colors.orange[400]
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text(
              _deliveryAddressSet
                  ? 'Continuar'
                  : 'Selecione o endereço de entrega',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSenderFormDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informações do Remetente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Digite seu nome',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Digite seu telefone',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _showDeliveryDetails = false;
            });
          },
        ),
        title: Text('Detalhes da entrega'),
        backgroundColor: Colors.orange[400],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Endereços
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Rua Olga Bernardes Amorim, 101',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Icon(Icons.arrow_downward, color: Colors.orange[400]),
                    SizedBox(height: 8),
                    Text(
                      'Local de entrega selecionado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Opções de veículo
              Text(
                'Selecione o veículo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = 'moto';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedVehicle == 'moto'
                              ? Colors.orange[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedVehicle == 'moto'
                                ? Colors.orange[400]!
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.two_wheeler,
                              color: _selectedVehicle == 'moto'
                                  ? Colors.orange[600]
                                  : Colors.grey[500],
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Moto',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedVehicle == 'moto'
                                    ? Colors.orange[600]
                                    : Colors.grey[700],
                              ),
                            ),
                            Text(
                              'R\$5,20',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicle = 'carro';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedVehicle == 'carro'
                              ? Colors.orange[50]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedVehicle == 'carro'
                                ? Colors.orange[400]!
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: _selectedVehicle == 'carro'
                                  ? Colors.orange[600]
                                  : Colors.grey[500],
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Carro',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedVehicle == 'carro'
                                    ? Colors.orange[600]
                                    : Colors.grey[700],
                              ),
                            ),
                            Text(
                              'R\$9,20',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // Botão para solicitar entrega
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showDeliveryDetails = false;
                    stateOfApp = "requesting";
                    displayRequestContainer();

                    // Buscar motoristas disponíveis
                    availableNearbyOnlineDriversList =
                        ManageDriversMethods.nearbyOnlineDriversList;
                    searchDriver();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'Solicitar entrega',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcon();

    if (_showDeliveryDetails) {
      return _buildDeliveryDetailsScreen();
    }

    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            children: [
              // Header do drawer
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange[400]!, Colors.orange[500]!],
                  ),
                ),
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName.substring(0, 1)
                                : 'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[600],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              userPhone,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Itens do menu
              ListTile(
                leading: Icon(Icons.history, color: Colors.grey[700]),
                title: Text(
                  'Histórico',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => TripsHistoryPage()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.payments, color: Colors.grey[700]),
                title: Text(
                  'Carteira',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                onTap: () {
                  // Implementar tela de carteira
                },
              ),

              ListTile(
                leading: Icon(Icons.info, color: Colors.grey[700]),
                title: Text('Sobre', style: TextStyle(color: Colors.grey[700])),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => AboutPage()),
                  );
                },
              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitialPosition!,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);

              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 300;
              });

              getCurrentLiveLocationOfUser();
            },
          ),

          // Botão do drawer
          Positioned(
            top: 36,
            left: 19,
            child: GestureDetector(
              onTap: () {
                if (isDrawerOpened == true) {
                  sKey.currentState!.openDrawer();
                } else {
                  resetAppNow();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.orange[400],
                  radius: 20,
                  child: Icon(
                    isDrawerOpened == true ? Icons.menu : Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Header personalizado do NG EXPRESS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.orange[400],
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        sKey.currentState!.openDrawer();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.red[400]!, Colors.pink[400]!],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName.substring(0, 1)
                                : 'U',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Olá, ${userName.isNotEmpty ? userName.split(' ')[0] : 'Usuário'}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo de busca (abaixo do header)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 40, bottom: 20),
                    child: Column(
                      children: [
                        Text(
                          'VOCÊ PRECISA,',
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.orange[400],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.chevron_right,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'NG EXPRESS Entrega',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botões Enviar/Receber
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _switchTabs('enviar'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Enviar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _activeTab == 'enviar'
                                        ? Colors.black
                                        : Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (_activeTab == 'enviar')
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[400],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(2),
                                        topRight: Radius.circular(2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => _switchTabs('receber'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Receber',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _activeTab == 'receber'
                                        ? Colors.black
                                        : Colors.grey[400],
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (_activeTab == 'receber')
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[400],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(2),
                                        topRight: Radius.circular(2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Área de busca com animação
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0.0, 0.5),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                    child: _buildSearchContent(),
                  ),
                ],
              ),
            ),
          ),

          // Container de detalhes da corrida
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: rideDetailsContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        height: 190,
                        child: Card(
                          elevation: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .70,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!
                                                    .distanceTextString!
                                              : "",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!
                                                    .durationTextString!
                                              : "",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  // Ícone do NG EXPRESS
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _selectedVehicle == 'moto'
                                            ? Icons.two_wheeler
                                            : Icons.directions_car,
                                        size: 40,
                                        color: Colors.orange[600],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  Text(
                                    (tripDirectionDetailsInfo != null)
                                        ? "R\$ ${(cMethods.calculateFareAmount(tripDirectionDetailsInfo!)).toString()}"
                                        : "",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.orange[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    _selectedVehicle == 'moto'
                                        ? 'Entrega de Moto'
                                        : 'Entrega de Carro',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Botão de confirmar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showDeliveryDetails = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 0),
                        ),
                        child: Text(
                          'Solicitar entrega',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Container de solicitação
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 12),

                    // Loading animado
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange[400]!,
                      ),
                      strokeWidth: 3,
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Procurando motorista...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Aguarde enquanto encontramos um motorista próximo',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        resetAppNow();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.grey[300]!,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[700],
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Container de detalhes da viagem
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: tripContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),

                    // Status da viagem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tripStatusDisplay,
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 19),

                    Divider(height: 1, color: Colors.grey[300], thickness: 1),

                    SizedBox(height: 19),

                    // Informações do motorista
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.orange[100],
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.orange[600],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameDriver.isNotEmpty ? nameDriver : "Motorista",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              carDetailsDriver.isNotEmpty
                                  ? carDetailsDriver
                                  : "NG EXPRESS",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 19),

                    Divider(height: 1, color: Colors.grey[300], thickness: 1),

                    SizedBox(height: 19),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => TripsHistoryPage()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 24, color: Colors.grey[600]),
                  SizedBox(height: 4),
                  Text(
                    'Histórico',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: FloatingActionButton(
                onPressed: () {
                  // Botão central de busca
                },
                backgroundColor: Colors.orange[400],
                elevation: 4,
                child: Icon(Icons.search, size: 28, color: Colors.white),
              ),
            ),

            GestureDetector(
              onTap: () {
                // Abrir carteira
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payments, size: 24, color: Colors.grey[600]),
                  SizedBox(height: 4),
                  Text(
                    'Carteira',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
