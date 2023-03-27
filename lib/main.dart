import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_insta/flutter_insta.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  FlutterInsta flutterInsta = FlutterInsta();
  TextEditingController usernameController = TextEditingController();
  TextEditingController reelController = TextEditingController();
  TabController? tabController;

  String? username, followers = " ", following, bio, website, profileimage;
  bool pressed = false;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, initialIndex: 1, length: 2);
    initializeDownloader();
    downloadReels();
  }

  void initializeDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
  }

  void downloadReels() async {
    var s = await flutterInsta
        .downloadReels("https://www.instagram.com/p/CDlGkdZgB2y");
    print(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package example app'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              text: "Home",
            ),
            Tab(
              text: "Reels",
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          homePage(), //  // home screen for Getting profile details
          reelPage() // reel download Screen
        ],
      ),
    );
  }

//get data from api
  Future printDetails(String username) async {
    await flutterInsta.getProfileData(username);
    setState(() {
      this.username = flutterInsta.username; //username
      followers = flutterInsta.followers; //number of followers
      following = flutterInsta.following; // number of following
      website = flutterInsta.website; // bio link
      bio = flutterInsta.bio; // Bio
      profileimage = flutterInsta.imgurl; // Profile picture URL
      print(followers);
    });
  }

  Widget homePage() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            TextField(
              decoration:
                  const InputDecoration(contentPadding: EdgeInsets.all(10)),
              controller: usernameController,
            ),
            ElevatedButton(
              child: const Text("Print Details"),
              onPressed: () async {
                setState(() {
                  pressed = true;
                });

                printDetails(usernameController.text); //get Data
              },
            ),
            pressed
                ? SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Card(
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  "$profileimage",
                                  width: 120,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              Text(
                                "$username",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "$followers\nFollowers",
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "$following\nFollowing",
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              Text(
                                "$bio",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 10)),
                              Text(
                                "$website",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

//Reel Downloader page
  Widget reelPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextField(
          controller: reelController,
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              downloading = true;
            });
            download();
          },
          child: const Text("Download"),
        ),
        downloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container()
      ],
    );
  }

  void download() async {
    var myvideourl = await flutterInsta.downloadReels(reelController.text);

    await FlutterDownloader.enqueue(
      url: myvideourl,
      savedDir: '/sdcard/Download',
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    ).whenComplete(() {
      setState(() {
        downloading = false;
      });
    });
  }
}
