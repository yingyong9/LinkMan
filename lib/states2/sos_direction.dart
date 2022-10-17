// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:admanyout/models/sos_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SosDirection extends StatefulWidget {
  final SosModel sosModel;
  const SosDirection({
    Key? key,
    required this.sosModel,
  }) : super(key: key);

  @override
  State<SosDirection> createState() => _SosDirectionState();
}

class _SosDirectionState extends State<SosDirection> {
  SosModel? sosModel;
  Map<MarkerId, Marker> mapMarker = {};

  @override
  void initState() {
    super.initState();
    sosModel = widget.sosModel;

    createMapMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
              sosModel!.sosGeopoint.latitude, sosModel!.sosGeopoint.longitude),
          zoom: 16,
        ),
        onMapCreated: (controller) {},
        markers: Set<Marker>.of(mapMarker.values),
      ),
    );
  }

  Future<void> createMapMarker() async {
    MarkerId markerId = const MarkerId('value');
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
          sosModel!.sosGeopoint.latitude, sosModel!.sosGeopoint.longitude),
    );
    mapMarker[markerId] = marker;
  }
}
