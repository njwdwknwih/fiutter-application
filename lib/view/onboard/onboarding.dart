// ignore_for_file: unused_import

import 'package:babyshophub/controller/auth_controller.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _pageController = PageController();

  int _currentpage = 0;

  final List<OnboardingItem> _item = [
    OnboardingItem(
      description: 'Explore the newest babies fashion trends and find your baby style', 
      title: 'Discover Latest Trends', 
      image: 'assets/images/onboard_img1.png' 
      ),
          OnboardingItem(
      description: 'Shop primium quality products from top brands worldwide', 
      title: 'Quality Products', 
      image: 'assets/images/onoard_img2.png'
      ),
          OnboardingItem(
      description: 'Simple and secure shopping experience in your fingertips', 
      title: 'Easy Shopping', 
      image: 'assets/images/onboard_img3.png'
      )
  ];

  // handle Get Start button

  void _handleGetStarted(){

    final AuthController authController = Get.find<AuthController>();
    authController.setFirstTimeDone();
    Get.off(() =>  SignInScreen());
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _item.length,
            onPageChanged: (index){
              setState(() {
                _currentpage = index;
              });
            },
            itemBuilder: (context,index){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _item[index].image,
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                 const SizedBox(height: 40,),

                 Text(
                  _item[index].title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.withColor(AppTextStyle.h1, Theme.of(context).textTheme.bodyLarge!.color!),
                 ),

                  const SizedBox(height: 40,),

                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 30),
                   child: Text(
                    _item[index].description,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.withColor(AppTextStyle.bodyLarge, 
                    isDark?Colors.grey[400]! :Colors.grey[600]!),
                   ),
                 ),
                 
                ],
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_item.length, (index) => AnimatedContainer(
                duration: const Duration(microseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentpage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentpage == index ? Theme.of(context).primaryColor : 
                  (isDark? Colors.grey[700] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(4),

                ),
                ) ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                onPressed: () => _handleGetStarted(), 
                child: Text(
                  'Skip',
                  style: AppTextStyle.withColor(AppTextStyle.bodyMedium,
                  isDark? Colors.grey[400]! : Colors.grey[600]!),
                )
                ),
                ElevatedButton(onPressed: (){
                  if (_currentpage < _item.length -1) {
                    _pageController.nextPage(
                      duration:Duration(milliseconds: 300) , 
                      curve: Curves.easeInOut,
                      );
                  }else{
                    _handleGetStarted();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                 child: Text(
                  _currentpage < _item.length - 1 ? 'Next' : 'Get Started',
                  style: AppTextStyle.withColor(AppTextStyle.bodyMedium, Colors.white),
                 )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingItem {
   final String image;
   final String title;
   final String description;

   OnboardingItem({
    required this.description,
    required this.title,
    required this.image,
   });
}