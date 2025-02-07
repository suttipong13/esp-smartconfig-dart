import 'dart:convert';
import 'dart:typed_data';

/// Provisioning request
class ProvisioningRequest {
  static final ssidLengthMax = 32;
  static final passwordLengthMin = 0;
  static final passwordLengthMax = 64;
  static final reservedDataLengthMax = 127;
  static final bssidLength = 6;
  static final encryptionKeyLength = 16;

  /// SSID (max length: 32 bytes)
  final Int8List ssid;

  /// BSSID (fixed 6 bytes)
  final Int8List bssid;

  /// Password (max length: 64 bytes).
  /// Not required if WiFi network is Public (not protected)
  final Int8List? password;

  /// Reserved data for EspTouchV2 (max length: 127 bytes)
  final Int8List? reservedData;

  /// Encryption key for EspTouchV2 (null or fixed length of 16 bytes)
  final Int8List? encryptionKey;

  ProvisioningRequest({
    required this.ssid,
    required this.bssid,
    this.password,
    this.reservedData,
    this.encryptionKey,
  }) {
    _validate();
  }

  /// Create request from string values
  ///
  /// [bssid] shoud be in format aa:bb:cc:dd:ee:ff
  factory ProvisioningRequest.fromStrings({
    required String ssid,
    required String bssid,
    String? password,
    String? reservedData,
    String? encryptionKey,
  }) {
    return ProvisioningRequest(
      ssid: Int8List.fromList(utf8.encode(ssid)),
      bssid: Int8List.fromList(
          bssid.split(':').map((hex) => int.parse(hex, radix: 16)).toList()),
      password:
          password == null ? null : Int8List.fromList(utf8.encode(password)),
      reservedData: reservedData == null
          ? null
          : Int8List.fromList(utf8.encode(reservedData)),
      encryptionKey: encryptionKey == null
          ? null
          : Int8List.fromList(utf8.encode(encryptionKey)),
    );
  }

  void _validate() {
    if (ssid.length > ssidLengthMax) {
      throw ArgumentError("SSID length is greater than $ssidLengthMax");
    }

    if (bssid.length != bssidLength) {
      throw ArgumentError(
          "Invalid BSSID. Length should be $bssidLength. Got ${bssid.length}");
    }

    if (password != null) {
      if (password!.length < passwordLengthMin) {
        throw ArgumentError("Minimum length of password is $passwordLengthMin");
      }

      if (password!.length > passwordLengthMax) {
        throw ArgumentError(
            "Password length is greater than $passwordLengthMax");
      }
    }

    if (reservedData != null && reservedData!.length > reservedDataLengthMax) {
      throw ArgumentError(
          "ReservedData length is greater than $reservedDataLengthMax");
    }

    if (encryptionKey != null && encryptionKey!.length != encryptionKeyLength) {
      throw ArgumentError(
          "Length of encryption key must be fixed $encryptionKeyLength bytes");
    }
  }
}
