import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpClient;
import 'package:wallpaper_api/models/color_model.dart';
import 'package:wallpaper_api/models/wallpaper.dart';
import 'package:wallpaper_api/screens/wallpaper_details.dart';

class WallPaperPage extends StatefulWidget {
  const WallPaperPage({super.key});

  @override
  State<WallPaperPage> createState() => _WallPaperPageState();
}

class _WallPaperPageState extends State<WallPaperPage> {
  var searchController = TextEditingController();
  Future<WallpaperDataModel?>? mData;
  Future<WallpaperDataModel?>? mTrendingData;

  List<ColorModel> mColorList = [
    ColorModel(colorValue: Colors.white, colorCode: "ffffff"),
    ColorModel(colorValue: Colors.black, colorCode: "000000"),
    ColorModel(colorValue: Colors.blue, colorCode: "0000ff"),
    ColorModel(colorValue: Colors.green, colorCode: "00ff00"),
    ColorModel(colorValue: Colors.red, colorCode: "ff0000"),
    ColorModel(colorValue: Colors.purple, colorCode: "9C27B0"),
    ColorModel(colorValue: Colors.orange, colorCode: "FF9800"),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   mData = getSearchWallpaper();
    mTrendingData = getTrendingWallpaper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Wallpaper"),
        ),
        body: Column(
          children: [
            searchUi(),
            SizedBox(
              height: 70,
              //color: Colors.grey,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                  itemCount: mColorList.length,
                  itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: (){
                          mData = getSearchWallpaper(query: searchController.text.toString(), colorCode: mColorList[index].colorCode!);
                          setState(() {

                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: Colors.grey
                            ),
                            color: mColorList[index].colorValue
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 250,
              child: FutureBuilder<WallpaperDataModel?>(
                future: mTrendingData,
                builder: (_, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }else {
                    if(snapshot.hasError){
                      return Center(
                        child: Text("Network Error: ${snapshot.error.toString()}"),
                      );
                    }else if(snapshot.hasData){
                      var data = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                          itemCount: data.photos!.length,
                          itemBuilder: (_, index){
                            var eachPhoto = data.photos![index].src!.portrait!;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: (){
                                  navigateToDetailsPage(eachPhoto);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(eachPhoto, fit: BoxFit.cover,),
                                ),
                              ),
                            );

                      });
                    }
                  }
                  return Container();
                },
              ),
            ),

            Expanded(
              child: FutureBuilder<WallpaperDataModel?>(
                  future: mData, builder: (_,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    }else{
                      if(snapshot.hasError){
                        return Center(child: Text("Network Error : ${snapshot.error.toString() }"),);
                      }else if(snapshot.hasData){
                        return snapshot.data != null && snapshot.data!.photos!.isNotEmpty
                            ? GridView.builder(
                          itemCount: snapshot.data!.photos!.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 11,
                              mainAxisSpacing: 11,
                              childAspectRatio: 9 / 16),
                          itemBuilder: (context, index) {
                            var eachPhoto = snapshot.data!.photos![index].src!.portrait!;
                            return InkWell(

                              onTap: (){
                                navigateToDetailsPage(eachPhoto);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  eachPhoto,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );
                          },
                        )
                            : Container();
                      }
                    }
                    return Container();
              }),
            )
          ],
        ));
  }

  void navigateToDetailsPage(String url){
Navigator.push(context, MaterialPageRoute(builder: (context) => WallpaperDetailsPage(wallUrl: url,)));
  }

  //search
  Widget searchUi() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search wallpaper",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          )),
          IconButton(onPressed: () {
           mData = getSearchWallpaper(query: searchController.text.toString());
           setState(() {

           });
          }, icon: const Icon(Icons.search))
        ],
      ),
    );
  }

  Future<WallpaperDataModel?> getSearchWallpaper({String query = "nature", String colorCode = ""}) async {
    var mApiKey = "Jt9ZDXtpT4QRvU16OCHVCOVTePdlewwMQzXHSZnZWcYCnad4nmcfGjl3";
    var uri = Uri.parse("https://api.pexels.com/v1/search?query=$query&color=$colorCode");
    var response =
        await httpClient.get(uri, headers: {"Authorization": mApiKey});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(response.body);
     var data = WallpaperDataModel.fromJson(rawData);
      return data;
    }else{
      return null;
    }
  }
  Future<WallpaperDataModel?> getTrendingWallpaper({String query = "nature", String colorCode = ""}) async {
    var mApiKey = "Jt9ZDXtpT4QRvU16OCHVCOVTePdlewwMQzXHSZnZWcYCnad4nmcfGjl3";
    var uri = Uri.parse("https://api.pexels.com/v1/curated");
    var response =
        await httpClient.get(uri, headers: {"Authorization": mApiKey});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(response.body);
     var data = WallpaperDataModel.fromJson(rawData);
      return data;
    }else{
      return null;
    }
  }
}
