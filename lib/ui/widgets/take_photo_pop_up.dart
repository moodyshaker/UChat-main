import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TakePhotoPopUp extends StatelessWidget {
  final void Function()? takeImageOnPressed;
  final void Function()? pickImageOnPressed;

  const TakePhotoPopUp(
      {Key? key, this.pickImageOnPressed, this.takeImageOnPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          Text(
            'Put image',
            style: Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(fontSize: 14),
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: takeImageOnPressed,
                child: Container(
                  height: 46,
                  width: 112,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Camera',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 16),
                  ),
                ),
              ),
              GestureDetector(
                onTap: pickImageOnPressed,
                child: Container(
                  height: 46,
                  width: 112,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Gallery',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
