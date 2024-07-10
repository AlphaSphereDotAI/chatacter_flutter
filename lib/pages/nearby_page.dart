import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:chatacter/components/tool_bar.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/styles/app_colors.dart';

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToolBar(title: AppStrings.nearby),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
            initialCenter: LatLng(30.033333, 31.233334), initialZoom: 10),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.chatacter.flutter_map',
          ),
          MarkerLayer(markers: [
            Marker(
              point: LatLng(30.033333, 31.233334),
              width: 100,
              height: 60,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Text(
                      "Username",
                      style: TextStyle(color: AppColors.black),
                    ),
                  ),
                  SvgPicture.asset(
                    AppIcons.locationIcon,
                    colorFilter:
                        ColorFilter.mode(AppColors.black, BlendMode.srcIn),
                  )
                ],
              ),
            )
          ])
        ],
      ),
    );
  }
}
