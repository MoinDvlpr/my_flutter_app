import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/controllers/cart_controller.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import '../dbservice/db_helper.dart';
import '../model/address_model.dart';
import '../model/usermodel.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/home/home_screen.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_snackbars.dart';
import 'dashboard_controller.dart';
import 'product_controller.dart';
import 'package:location/location.dart' as loc;

class AuthController extends GetxController {
  @override
  void onInit() {
    fetchUserLocation();

    super.onInit();
  }

  final dashboardController = Get.put(DashboardController());

  GetStorage storage = GetStorage();
  RxString loginmessage = "".obs;
  RxBool isLoading = false.obs;

  //Text Editing Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repassController = TextEditingController();

  // login
  Future<void> login() async {
    final user = await DatabaseHelper.instance.loginUser(
      emailController.text,
      passController.text,
    );
    if (user != null) {
      clearController();
      log("user is $user");
      storage.write(IS_LOGGED_IN, true);
      storage.write(USERID, user[USERID]);
      storage.write(CONTACT, user[CONTACT]);
      storage.write(ROLE, user[ROLE]);
      storage.write(USERNAME, user[USERNAME]);
      storage.write(EMAIL, user[EMAIL]);
      storage.write(PASSWORD, user[PASSWORD]);
      if (user[ROLE] == "admin") {
        Get.put(DashboardController());
        Get.put(ProductController());
        Get.offAll(() => AdminDashboard());
      } else {
        Get.offAll(() => HomeScreen());
      }
    } else {
      Get.closeAllSnackbars();
      AppSnackbars.error(
        "Login failed",
        'Invalid credential or user not exists!',
      );
    }
  }

  // addEditUser
  Future<void> signUp() async {
    try {
      if (!(passController.text.trim() == repassController.text.trim())) {
        Get.closeAllSnackbars();
        AppSnackbars.warning('Failed', 'Password not matched!');
        return;
      }

      isLoading.value = true;
      final user = UserModel(
        userName: nameController.text.trim(),
        contact: int.parse(contactController.text.trim()),
        email: emailController.text.trim(),
        password: passController.text.trim(),
        role: "User",
      );
      var result = await DatabaseHelper.instance.insertUser(user);
      if (result != null && result != 0) {
        clearController();
        Get.to(() => LoginScreen());
        Get.closeAllSnackbars();
        AppSnackbars.success('Success', "You've successfully signed up!");
        log("User signed up successfully!");
      } else {
        Get.closeAllSnackbars();
        AppSnackbars.error('Failed', 'Email already exists!');
        log("failed to sign up user!");
      }
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error('Error!', 'Something went wrong!');
      log("error (signUp) : : : --> ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  final Completer<GoogleMapController> mapController = Completer();
  final loc.Location location = loc.Location();
  Rx<LatLng?> userLocation = Rx<LatLng?>(null);

  Rx<Marker?> selectedMarker = Rx<Marker?>(null);
  RxString address = "Tap on map to get address".obs;

  // FETCH CURRENT LOCATION
  Future<void> fetchUserLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    final loc.LocationData locData = await location.getLocation();

    userLocation.value = LatLng(locData.latitude!, locData.longitude!);
  }

  final CameraPosition initialCameraPosition = CameraPosition(
    // target: LatLng(21.1702, 72.8311), // surat
    target: LatLng(22.3039, 70.8022), // rajkot
    zoom: 16.0,
  );

  void onMapCreated(GoogleMapController controller) async {
    print(controller.mapId);
    if (controller.mapId == 0) {
      mapController.complete(controller);
    }

    if (userLocation.value != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLocation.value!, zoom: 16),
        ),
      );
    }
  }

  LatLng? selectedPosition;
  Future<void> onMapTap(LatLng position) async {
    try {
      selectedPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];

        address.value =
            "${place.name},${place.locality}, ${place.administrativeArea}, ${place.country}, ${place.postalCode}";
      } else {
        address.value = "No address found";
      }

      selectedMarker.value = Marker(
        markerId: MarkerId("tapped_location"),
        position: position,
        infoWindow: InfoWindow(
          title: "Selected Location",
          snippet: address.value,
        ),
      );
    } catch (e) {
      address.value = "Error: $e";
    }
  }

  final addressFromMap = ''.obs;
  final fullNameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final zipCodeController = TextEditingController();

  double lati = 0.0;
  double longi = 0.0;

  Future<void> setMapAddress() async {
    if (selectedPosition != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedPosition!.latitude,
        selectedPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        addressController.text = "${place.name}";
        cityController.text = "${place.locality}";
        stateController.text = "${place.administrativeArea}";
        countryController.text = "${place.country}";
        zipCodeController.text = "${place.postalCode}";
        lati = selectedPosition!.latitude;
        longi = selectedPosition!.longitude;
        print("latitude : : :  $lati longitude :::: $longi");
        Get.back();
      }
    }
  }

  // Add address
  Future<void> saveAddress() async {
    try {
      isLoading.value = true;
      print("inside save address latitude $lati");
      print("inside save address longitude $longi");
      AddressModel modelData = AddressModel(
        userId: storage.read(USERID),
        fullName: fullNameController.text,
        phone: int.parse(contactController.text),
        address: addressController.text,
        city: cityController.text,
        state: stateController.text,
        country: countryController.text,
        zipcode: zipCodeController.text,
        isDefault: false,
        latitude: lati,
        longitude: longi,
      );
      var result = await DatabaseHelper.instance.insertAddress(modelData);
      if (result != null && result != 0) {
        clearController();
        Get.closeAllSnackbars();
        AppSnackbars.success('Success!', "Address added successfully!");
        await fetchAllAddress();
        await fetchDefaultAddress();
        Get.back();
      } else {
        Get.closeAllSnackbars();
        AppSnackbars.error('Failed', "Failed to add address");
      }
    } catch (e) {
      log("error (saveAddress) : : : --> ${e.toString()}");
      Get.closeAllSnackbars();
      AppSnackbars.error('Error!', "Something went wrong!");
    } finally {
      isLoading.value = false;
    }
  }

  // Edit address
  Future<void> editAddress(int addressID) async {
    try {
      isLoading.value = true;
      AddressModel modelData = AddressModel(
        addressId: addressID,
        userId: storage.read(USERID),
        address: addressController.text,
        fullName: fullNameController.text,
        phone: int.parse(contactController.text),
        city: cityController.text,
        state: stateController.text,
        country: countryController.text,
        zipcode: zipCodeController.text,
        isDefault: isDefault,
        latitude: lati,
        longitude: longi,
      );
      var result = await DatabaseHelper.instance.updateAddress(
        modelData,
        addressID: addressID,
      );
      if (result != null && result != 0) {
        clearController();
        Get.closeAllSnackbars();
        AppSnackbars.success('Success!', "Address updated successfully!");
        await fetchAllAddress();
        await fetchDefaultAddress();
        Get.back();
      } else {
        Get.closeAllSnackbars();
        AppSnackbars.error('Failed', "Failed to update address");
      }
    } catch (e) {
      log("error (editAddress) : : : --> ${e.toString()}");
      Get.closeAllSnackbars();
      AppSnackbars.error('Error!', "Something went wrong!");
    } finally {
      isLoading.value = false;
    }
  }

  // fetch All Address
  RxList<AddressModel> allAddress = <AddressModel>[].obs;
  Future<void> fetchAllAddress() async {
    try {
      allAddress.value = await DatabaseHelper.instance.getAllAddress(
        userID: storage.read(USERID),
      );
      print("this is now address length : : ::  ${allAddress.length}");
    } catch (e) {
      log("error (fetchAllAddress) : : : --> ${e.toString()}");
    }
  }

  // delete address
  Future<void> removeAddress(int addressID, bool isDefault) async {
    try {
      if (isDefault) {
        DialogUtils.showWarningDialog(
          title: 'Oops!',
          message: 'default address cannot be deleted !',
        );
        return;
      }
      var result = await DatabaseHelper.instance.deleteAddress(
        addressID: addressID,
        userID: storage.read(USERID),
      );
      if (result != null && result != 0) {
        await fetchAllAddress();
      }
    } catch (e) {
      log("error (removeAddress) : : : ${e.toString()}");
    }
  }

  // set default address
  Future<void> setAsDefault(int addressID) async {
    try {
      await DatabaseHelper.instance.setAddressAsDefault(
        storage.read(USERID),
        addressID,
      );
      await fetchAllAddress();
      await fetchDefaultAddress();
    } catch (e) {
      log("error (setAsDefault) : : : ${e.toString()}");
    }
  }

  // fetch address for edit
  bool isDefault = false;

  Future<void> fetchAddressByID(int addressID) async {
    try {
      var data = await DatabaseHelper.instance.getAddressByID(addressID);

      if (data != null) {
        isDefault = data.isDefault;
        fullNameController.text = data.fullName;
        addressController.text = data.address;
        cityController.text = data.city;
        stateController.text = data.state;
        contactController.text = data.phone.toString().trim();
        countryController.text = data.country;
        zipCodeController.text = data.zipcode;
      } else {
        log("failed (fetchAddressByID) failed to fetch data");
      }
    } catch (e) {
      log("error(fetchAddressByID) : : : ${e.toString()}");
    }
  }

  void clearController() {
    nameController.clear();
    emailController.clear();
    passController.clear();
    repassController.clear();
    addressController.clear();
    address.value = "Tap on map to get address";
    fullNameController.clear();
    contactController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    zipCodeController.clear();
  }

  clearAddress() {
    fullName.value = "";
    shippingAddress.value = "";
    cityName.value = "";
    stateName.value = "";
    countryName.value = "";
    zipcode.value = "";
    lati = 0.0;
    longi = 0.0;
  }

  RxString fullName = "".obs;
  RxString shippingAddress = "".obs;
  RxString cityName = "".obs;
  RxString stateName = "".obs;
  RxString countryName = "".obs;
  RxString zipcode = "".obs;

  // fetch Shipping address For Current User
  Future<void> fetchDefaultAddress() async {
    try {
      clearAddress();
      var result = await DatabaseHelper.instance.getDefaultAddress(
        storage.read(USERID),
      );
      if (result != null) {
        fullName.value = result.fullName;
        shippingAddress.value = result.address;
        cityName.value = result.city;
        stateName.value = result.state;
        countryName.value = result.state;
        countryName.value = result.country;
        zipcode.value = result.zipcode.toString();
        lati = result.latitude;
        longi = result.longitude;
      } else {
        log("failed to fetch default address");
      }
    } catch (e) {
      log("error (fetchDefaultAddress) : : : : ${e.toString()}");
    }
  }

  // logout
  Future<void> logout() async {
    Future.delayed(Duration(milliseconds: 200), () {
      Get.delete<DashboardController>();
    });
    Get.delete<CartController>();
    await storage.erase();
    Get.offAll(() => LoginScreen());
  }
}
