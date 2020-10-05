import 'package:flutter/material.dart';
// import 'package:ricker_app/services/vehicle_service.dart';

class YourVehicleText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Text(
        '',
        // VehicleService.currentVehicle != null
        //   ? 'Seu veículo atual é um ${VehicleService.currentVehicle.vehicleModel.name}'
        //   : 'Você ainda não selecionou nenhum veículo',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }
}
