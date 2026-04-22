// import 'package:get/get.dart';
// import '../services/splash_service.dart';

// class SplashController extends GetxController {
//   final SplashService _splashService = SplashService();
  
//   @override
//   void onInit() {
//     super.onInit();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     // Simulate initialization tasks
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     // Check if user is logged in
//     final isLoggedIn = await _splashService.checkAuthentication();
    
//     // Perform any other initialization
//     await _splashService.initializeServices();
    
//     // Navigate to appropriate screen
//     if (isLoggedIn) {
//       Get.offAllNamed('/home');
//     } else {
//       Get.offAllNamed('/welcome');
//     }
//   }
// }