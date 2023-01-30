import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedPopUp extends StatefulWidget {
  const AnimatedPopUp(
      {Key? key,
      this.onSelectCamera,
      this.onSelectGallery,
      this.onSelectAttach})
      : super(key: key);

  final Function()? onSelectCamera;
  final Function()? onSelectGallery;
  final Function()? onSelectAttach;

  @override
  State<StatefulWidget> createState() => AnimatedPopUpState();
}

class AnimatedPopUpState extends State<AnimatedPopUp>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: widget.onSelectCamera,
                      child: SvgPicture.asset(
                        'assets/svg/camera.svg',
                        color: Theme.of(context).primaryColor,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: widget.onSelectGallery,
                      child: SvgPicture.asset(
                        'assets/svg/gallery.svg',
                        color: Theme.of(context).primaryColor,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: widget.onSelectAttach,
                      child: SvgPicture.asset(
                        'assets/svg/attach.svg',
                        color: Theme.of(context).primaryColor,
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
