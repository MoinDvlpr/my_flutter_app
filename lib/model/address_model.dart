import 'package:my_flutter_app/utils/app_constant.dart';

class AddressModel {
  final int? addressId;
  final int userId;
  final String fullName;
  final int phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final bool isDefault;
  final double latitude;
  final double longitude;

  AddressModel({
    this.addressId,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    required this.isDefault,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      addressId: map[ADDRESS_ID],
      userId: map[USERID],
      fullName: map[FULL_NAME],
      phone: map[PHONE],
      address: map[ADDRESS],
      city: map[CITY],
      state: map[STATE],
      country: map[COUNTRY],
      zipcode: map[ZIPCODE],
      isDefault: map[IS_DEFAULT] == 1,
      latitude: map[LATITUDE] ?? 0.0,
      longitude: map[LONGITUDE] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ADDRESS_ID: addressId,
      USERID: userId,
      FULL_NAME: fullName,
      PHONE: phone,
      ADDRESS: address,
      CITY: city,
      STATE: state,
      COUNTRY: country,
      ZIPCODE: zipcode,
      LATITUDE:latitude,
      LONGITUDE:longitude,
      IS_DEFAULT: isDefault ? 1 : 0,
    };
  }
}
