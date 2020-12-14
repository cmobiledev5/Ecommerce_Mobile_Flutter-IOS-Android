import 'package:flutter/material.dart';
import '../components/search_field.dart';
import '../../../components/icon_button_with_counter.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SearchField(),
        IconButtonWithCounter(
          svgSrc: "assets/icons/Cart Icon.svg",
          numOfItems: 0,
          press: () {},
        ),
        IconButtonWithCounter(
          svgSrc: "assets/icons/Bell.svg",
          numOfItems: 3,
          press: () {},
        ),
      ],
    );
  }
}
