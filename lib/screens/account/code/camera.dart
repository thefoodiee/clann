import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/colors.dart';

class CameraCodeScreen extends StatelessWidget {
  const CameraCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double scanSize = constraints.maxWidth * 0.8;
          // final scanRect = Rect.fromCenter(
          //   center: Offset(
          //     constraints.maxWidth / 2,
          //     constraints.maxHeight / 2,
          //   ),
          //   width: scanSize,
          //   height: scanSize,
          // );

          return Stack(
            children: [
              // Camera
              // MobileScanner(
              //   onDetect: (result) {
              //     final value = result.barcodes.first.rawValue;
              //     if (value != null) {
              //       debugPrint("Scanned: $value");
              //     }
              //   },
              //   scanWindow: scanRect,
              // ),

              // Overlay with transparent cut-out
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: scanSize,
                    height: scanSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // Back button on top
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: mainBlue),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white)
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
