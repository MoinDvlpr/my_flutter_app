import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';

class GlobalAppSubmitBtn extends StatelessWidget {
  const GlobalAppSubmitBtn({super.key,required this.title,this.height,this.onTap,this.bgcolor,this.isLoading=false});
final String title;
final Color? bgcolor;
final double? height;
final void Function()? onTap;
final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? () {} :  onTap,
      child: Container(
      height: height ?? 40,
        decoration: BoxDecoration(color: bgcolor ?? primary,borderRadius: BorderRadius.circular(20.0)),
        child: Row( mainAxisAlignment: MainAxisAlignment.center,children: [ isLoading ? Center(child:Transform.scale(scale: 0.5,child: CircularProgressIndicator(color: white,))) :  Text(title,style: AppTextStyle.lableStyle.copyWith(color: white),)],),),
    );
  }
}
