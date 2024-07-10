import 'package:flutter/material.dart';
import 'package:chatacter/config/app_icons.dart';
import 'package:chatacter/config/app_routes.dart';
import 'package:chatacter/config/app_strings.dart';
import 'package:chatacter/styles/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Spacer(
                  flex: 2,
                ),
                Text(
                  AppStrings.helloWelcome,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  AppStrings.loginToContinue,
                  style: TextStyle(
                    color: AppColors.white,
                  ),
                ),
                Spacer(),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppStrings.username,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppStrings.password,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        print("Forgot Password Clicked");
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        AppStrings.forgorPassword,
                        style: TextStyle(color: AppColors.font),
                      )),
                ),
                SizedBox(
                  height: 32,
                ),
                SizedBox(
                  height: 300.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 39.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.main);
                              },
                              child: Text(
                                AppStrings.login,
                                style: TextStyle(color: AppColors.black),
                              )),
                        ),
                        Spacer(),
                        Text(
                          AppStrings.orSignInWith,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.videoCall);
                              print("Google is clicked");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppIcons.googleIcon,
                                  width: 22,
                                  height: 22,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  AppStrings.loginWithGoogle,
                                  style: TextStyle(color: AppColors.black),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.video);
                              print("Facebook is clicked");
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppIcons.facebookIcon,
                                  width: 22,
                                  height: 22,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  AppStrings.loginWithFacebook,
                                  style: TextStyle(color: AppColors.black),
                                )
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.dontHaveAccount,
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRoutes.otp);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.amber,
                              ),
                              child: Text(
                                AppStrings.signup,
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.amber),
                              ),
                            )
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
