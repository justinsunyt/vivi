import 'package:Focal/constants.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_review/launch_review.dart';
import 'package:Focal/components/nav_button.dart';

class AboutPage extends StatefulWidget {
  final Function goToPage;

  AboutPage({@required this.goToPage, Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  void openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Couldn\'t find url');
    }
  }

  Widget textButton({@required VoidCallback onTap, @required String text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 150,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() => _version =
          'Version ${packageInfo.version} (${packageInfo.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => widget.goToPage(2),
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 50,
            child: Text(
              'About',
              style: blackHeaderTextStyle,
            ),
          ),
          Positioned(
            left: 5,
            top: 0,
            child: NavButton(
              onTap: () {
                widget.goToPage(2);
              },
              iconData: FeatherIcons.chevronLeft,
              color: black,
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            top: 100,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Image(
                    image:
                        AssetImage('assets/images/Focal Logo_Full Colored.png'),
                    width: 150,
                  ),
                ),
                Text(
                  _version,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              textButton(
                onTap: () {
                  LaunchReview.launch(
                      androidAppId: 'technology.focal.focal',
                      iOSAppId: '1526256598');
                },
                text: 'Rate Focal',
              ),
              textButton(
                onTap: () {
                  openUrl('https://getfocal.app/terms');
                },
                text: 'Terms and Conditions',
              ),
              textButton(
                onTap: () {
                  openUrl('https://getfocal.app/privacy');
                },
                text: 'Privacy Policy',
              ),
              textButton(
                onTap: () {
                  openUrl('https://getfocal.app');
                },
                text: 'Website',
              ),
            ],
          )),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Text(
                '© 2020 Focal LLC',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
