import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SpinKitDualRing(
              size: 100,
              color: Colors.orange,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 20, color: Colors.orange),
            )
          ],
        ),
      ),
    );
  }
}
