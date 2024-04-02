import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final sourceAPI = 'psgc.gitlab.io';
  final edgePadding = 12.0;
  Map<String, String> provinces = {};
  Map<String, String> regions = {};
  Map<String, String> cities = {};
  bool isRegionsLoaded = false;
  bool isProvincesLoaded = false;
  bool isCitiesLoaded = false;
  TextEditingController provinceController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRegions();
  }

  void callAPI() async {
    //https://psgc.gitlab.io/api/island-groups/
    var url = Uri.https(sourceAPI, 'api/island-groups/');
    var response = await http.get(url);
    print(response.statusCode);
    print(response.headers);
    print(response.body);
  }

  // Future<Map<String, String>> loadRegions() async {
  //   Map<String, String> regions = {};
  //   var url = Uri.https(sourceAPI, 'api/regions/');
  //   var response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     // print(response.body);
  //     List json = jsonDecode(response.body);
  //     //convert to map<key:value>
  //     json.forEach((element) {
  //       regions.addAll({element['code']: element['regionName']});
  //     });
  //   }
  //   return regions;
  // }

  Future<void> loadRegions() async {
    var url = Uri.https(sourceAPI, 'api/regions/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print(response.body);
      List json = jsonDecode(response.body);
      //convert to map<key:value>
      json.forEach((element) {
        regions.addAll({element['code']: element['regionName']});
      });
    }
    setState(() {
      isRegionsLoaded = true;
    });
  }

  Future<void> loadProvinces(String regionCode) async {
    provinces.clear();
    //https://psgc.gitlab.io/api/regions/010000000/provinces/
    var url = Uri.https(sourceAPI, 'api/regions/$regionCode/provinces/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print(response.body);
      List json = jsonDecode(response.body);
      //convert to map<key:value>
      json.forEach((element) {
        provinces.addAll({element['code']: element['name']});
      });
    }
    setState(() {
      isProvincesLoaded = true;
      provinceController.clear();
    });
  }

  Future<void> loadCities(String provinceCode) async {
    provinces.clear();
    //https://psgc.gitlab.io/api/provinces/012800000/cities-municipalities/
    var url = Uri.https(
        sourceAPI, 'api/provinces/$provinceCode/cities-municipalities/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print(response.body);
      List json = jsonDecode(response.body);
      //convert to map<key:value>
      json.forEach((element) {
        cities.addAll({element['code']: element['name']});
      });
    }
    setState(() {
      isCitiesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(edgePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isRegionsLoaded)
                DropdownMenu(
                  label: const Text('Region'),
                  width: screenWidth - edgePadding * 2,
                  dropdownMenuEntries: regions.entries.map((item) {
                    return DropdownMenuEntry(
                      label: item.value,
                      value: item.key,
                    );
                  }).toList(),
                  onSelected: (value) {
                    print(value);
                    loadProvinces(value!);
                  },
                )
              else
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (isProvincesLoaded)
                DropdownMenu(
                  controller: provinceController,
                  label: const Text('Province'),
                  width: screenWidth - edgePadding * 2,
                  dropdownMenuEntries: provinces.entries.map((item) {
                    return DropdownMenuEntry(
                      label: item.value,
                      value: item.key,
                    );
                  }).toList(),
                  onSelected: (value) {
                    print(value);
                    loadCities(value!);
                  },
                ),
              if (isCitiesLoaded)
                DropdownMenu(
                  // controller: provinceController,
                  label: const Text('Cities'),
                  width: screenWidth - edgePadding * 2,
                  dropdownMenuEntries: cities.entries.map((item) {
                    return DropdownMenuEntry(
                      label: item.value,
                      value: item.key,
                    );
                  }).toList(),
                  onSelected: (value) {
                    print(value);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
