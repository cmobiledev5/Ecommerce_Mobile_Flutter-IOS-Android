import 'package:e_commerce_app_flutter/components/default_button.dart';
import 'package:e_commerce_app_flutter/components/product_short_detail_card.dart';
import 'package:e_commerce_app_flutter/constants.dart';
import 'package:e_commerce_app_flutter/models/CartItem.dart';
import 'package:e_commerce_app_flutter/models/OrderedProduct.dart';
import 'package:e_commerce_app_flutter/models/Product.dart';
import 'package:e_commerce_app_flutter/screens/cart/components/checkout_card.dart';
import 'package:e_commerce_app_flutter/screens/product_details/product_details_screen.dart';
import 'package:e_commerce_app_flutter/services/database/product_database_helper.dart';
import 'package:e_commerce_app_flutter/services/database/user_database_helper.dart';
import 'package:e_commerce_app_flutter/size_config.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

import '../../../utils.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  double cartTotal = 0.0;
  List<CartItem> cartItems;
  List<Product> cartProducts;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenHeight(10)),
          Text(
            "Your Cart",
            style: headingStyle,
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          Expanded(
            child: buildCartItemsList(),
          ),
        ],
      ),
    );
  }

  Widget buildCartItemsList() {
    return StreamBuilder<List<CartItem>>(
        stream: UserDatabaseHelper().allCartItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
          cartItems = snapshot.data;
          cartTotal = 0.0;
          cartProducts = List<Product>.filled(cartItems.length, null);
          return Column(
            children: [
              DefaultButton(
                text: "Proceed to Payment",
                press: () {
                  Scaffold.of(context).showBottomSheet((context) {
                    return CheckoutCard(
                      cartTotal: cartTotal,
                      onCheckoutPressed: checkoutButtonCallback,
                    );
                  });
                },
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    if (index >= cartItems.length) {
                      return SizedBox(height: getProportionateScreenHeight(80));
                    }
                    return buildCartItemDismissible(
                        context, cartItems[index], index);
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget buildCartItemDismissible(
      BuildContext context, CartItem cartItem, int index) {
    return Dismissible(
      key: Key(cartItem.productID),
      direction: DismissDirection.startToEnd,
      dismissThresholds: {
        DismissDirection.startToEnd: 0.65,
      },
      background: buildDismissibleBackground(),
      child: buildCartItem(cartItem, index),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
            context,
            "Remove Product from Cart?",
          );
          if (confirmation) {
            if (direction == DismissDirection.startToEnd) {
              final result =
                  await UserDatabaseHelper().removeProductFromCart(cartItem.id);
              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Product Removed from Cart"),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Couldnt remove Product from Cart"),
                  ),
                );
              }
              return result;
            }
          }
        }
        return false;
      },
      onDismissed: (direction) {},
    );
  }

  Widget buildCartItem(CartItem cartItem, int index) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 4,
        top: 4,
        right: 4,
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<Product>(
        future: ProductDatabaseHelper().getProductWithID(cartItem.productID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
          Product product = snapshot.data;
          cartProducts[index] = product;
          cartTotal += (cartItem.itemCount * product.discountPrice);
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: ProductShortDetailCard(
                  product: product,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: kTextColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.arrow_drop_up,
                          color: kTextColor,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(height: 8),
                      Text(
                        "${cartItem.itemCount}",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: kTextColor,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildDismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkoutButtonCallback() async {
    bool cartLoaded = true;
    if (cartItems == null) {
      cartLoaded = false;
    } else {
      for (final product in cartItems) {
        if (product == null) {
          cartLoaded = false;
          break;
        }
      }
    }
    if (cartLoaded == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cart loading... Please wait"),
        ),
      );
      return;
    }
    final confirmation = await showConfirmationDialog(
      context,
      "This is just a Project Testing App so, no actual Payment Interface is available.\nDo you want to proceed for Mock Ordering of Products?",
    );
    if (confirmation == false) {
      return;
    }
    final orderFuture = orderAllCartProducts();
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          orderFuture,
          message: Text("Placing the Order"),
        );
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ordered all Products"),
      ),
    );
  }

  Future orderAllCartProducts() async {
    for (int i = 0; i < cartItems.length; i++) {
      final productAddedToOrderedList =
          await UserDatabaseHelper().addOrderedProduct(OrderedProduct(
        null,
        productUid: cartItems[i].productID,
        orderDate: "",
      ));
      if (productAddedToOrderedList) {
        await UserDatabaseHelper().removeProductFromCart(cartItems[i].id);
      }
    }
  }
}
