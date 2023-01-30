import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({Key? key, required this.title, this.imagePath})
      : super(key: key);

  final String? imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          if (imagePath == null)
            Container(
              height: 56,
              width: 56,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).cardColor,
                  width: 2,
                ),
              ),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).backgroundColor,
                ),
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: Theme.of(context).cardColor,
                ),
              ),
            )
          else
            Container(
              height: 56,
              width: 56,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.12),
                    Theme.of(context).primaryColor,
                  ],
                ),
              ),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: AssetImage(imagePath!),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 4,
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
