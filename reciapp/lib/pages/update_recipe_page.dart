import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:reciapp/components/textbox_form.dart';
import 'package:reciapp/pages/recipe_detail.dart';
import '../components/bottom_bar.dart';
import '../components/dropdown_multiple_choice_button.dart';
import '../object/category_item.dart';
import '../object/method_item.dart';
import '../object/post_send_item.dart';
import '../object/region_item.dart';
import '../object/use_item.dart';
import 'package:reciapp/object/post_detail.dart';

class UpdateRecipePage extends StatefulWidget {
  PostDetail postDetail;

  UpdateRecipePage({required this.postDetail});

  @override
  State<UpdateRecipePage> createState() => _UpdateRecipePageState();
}

class _UpdateRecipePageState extends State<UpdateRecipePage> {
  File? image;
  String? imageURL;
  UploadTask? uploadTask;
  bool checkImage = true;
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController tools = TextEditingController();
  TextEditingController ingredients = TextEditingController();
  TextEditingController processing = TextEditingController();
  TextEditingController cooking = TextEditingController();
  TextEditingController linkVideo = TextEditingController();
  Future getAllData() async {
    var categories = await fetchCategories();
    var methods = await fetchMethods();
    var uses = await fetchUses();
    var regions = await fetchRegions();
    if (!mounted) return;
    setState(() {
      this.categories = categories;
      this.methods = methods;
      this.uses = uses;
      this.regions = regions;
      selectedServe = widget.postDetail.serving;
      selectedTimeCooking = widget.postDetail.cookingTime;
      selectedTimePreparing = widget.postDetail.preparingTime;
      selectedTimeProcessing = widget.postDetail.processingTime;
      methods.forEach((element) {
        if (element.method == widget.postDetail.method) {
          selectedMethod = element;
        }
      });
      regions.forEach((element) {
        if (element.continents == widget.postDetail.continents) {
          selectedRegion = element;
        }
      });
      uses.forEach((element) {
        if (element.id == widget.postDetail.usesId) {
          selectedUse = element;
        }
      });
      categories.forEach((element) {
        for (var item in widget.postDetail.listCategories) {
          if (item.id == element.id) {
            selectedCategorys.add(element);
            break;
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAllData();
    title = TextEditingController(text: widget.postDetail.name);
    description = TextEditingController(text: widget.postDetail.description);
    tools = TextEditingController(text: widget.postDetail.tool);
    ingredients = TextEditingController(text: widget.postDetail.ingredient);
    processing = TextEditingController(text: widget.postDetail.processing);
    cooking = TextEditingController(text: widget.postDetail.cooking);
    linkVideo = TextEditingController(text: widget.postDetail.videoUrl);
    imageURL = widget.postDetail.imageUrl;

    postd = widget.postDetail.id;
  }

  String? postd;
  List<CategoryItem> categories = [];
  List<CategoryItem> selectedCategorys = [];

  List<MethodItem> methods = [];
  MethodItem? selectedMethod;

  List<UseItem> uses = [];
  UseItem? selectedUse;
  List<RegionItem> regions = [];
  RegionItem? selectedRegion;

  final List<int> serving = [2, 4, 6, 8, 10];
  int? selectedServe;
  List<int> times = [10, 20, 30, 40, 60, 80, 100, 120, 140, 160, 180];
  int? selectedTimeCooking;
  int? selectedTimeProcessing;
  int? selectedTimePreparing;

  final _formKey = GlobalKey<FormState>();

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = await saveImagePermantly(image.path);
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {}
  }

  Future<File> saveImagePermantly(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(path);
    final image = File('${directory.path}/$name');
    return File(path).copy(image.path);
  }

  Future uploadFile() async {
    if (image != null) {
      final pathUpload = 'images${image!.path}';
      final ref = FirebaseStorage.instance.ref().child(pathUpload);
      uploadTask = ref.putFile(image!);
      final snapshot = await uploadTask!.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageURL = imageUrl;
      });
    }
  }

  Future updateRecipe(BuildContext context, String postId) async {
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });
    await uploadFile();
    PostSendItem post = PostSendItem(
        name: title.text,
        cookingMethodId: selectedMethod!.id,
        recipeRegionId: selectedRegion!.id,
        imageUrl: imageURL.toString(),
        videoUrl: linkVideo.text,
        usesId: selectedUse!.id,
        description: description.text,
        categoriesId: selectedCategorys.map((e) => e.id).toList(),
        ingredient: ingredients.text,
        processing: processing.text,
        cooking: cooking.text,
        tool: tools.text,
        processingTime: selectedTimeProcessing!.toInt(),
        cookingTime: selectedTimeCooking!.toInt(),
        preparingTime: selectedTimePreparing!.toInt(),
        serving: selectedServe!.toInt());
    int data = await updateData(post, postId).whenComplete(() {
      Navigator.of(context).pop();
    });
    if (data == 200) {
      showDialog(
          // The user CANNOT close this dialog  by pressing outsite it
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              // The background color
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // The loading indicator
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 40.0,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // Some text
                    Text('Updated')
                  ],
                ),
              ),
            );
          });
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RecipeDetailPage(id: postId),
        ));
      });
    } else {
      showDialog(
          // The user CANNOT close this dialog  by pressing outsite it
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              // The background color
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // The loading indicator
                    Icon(
                      Icons.error_outline_outlined,
                      color: Colors.red,
                      size: 40.0,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // Some text
                    Text('Fail to update')
                  ],
                ),
              ),
            );
          });
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Recipe',
          style: GoogleFonts.satisfy(
            color: const Color.fromARGB(255, 59, 59, 61),
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.orange,
        titleTextStyle: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      bottomNavigationBar: bottomMenuBar(context, 'update'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextBoxForm(text: 'Title', controller: title, maxLines: 1),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextBoxForm(text: 'Description', controller: description),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                image != null
                    ? Image.file(
                        image!,
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )
                    : (imageURL != null)
                        ? Image.network(
                            imageURL!,
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.2,
                            color: Colors.grey,
                            child: const Text(
                              'Poster',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
                            ),
                          ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                  ),
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 20,
                  ),
                  label: const Text('Upload Photo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () => pickImage(ImageSource.gallery),
                ),
                !checkImage
                    ? const Text(
                        'Please upload image!',
                        style: TextStyle(color: Colors.red),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                DropDowmMultipleChoice(
                    text: 'Category',
                    categories: categories,
                    selectedCategorys: selectedCategorys),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Method',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Method.';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select Method',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: methods
                            .map((item) => DropdownMenuItem<MethodItem>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedMethod = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Use',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Use.';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select Use',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: uses
                            .map((item) => DropdownMenuItem<UseItem>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedUse,
                        onChanged: (value) {
                          setState(() {
                            selectedUse = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Region',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Region.';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select Region',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: regions
                            .map((item) => DropdownMenuItem<RegionItem>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedRegion,
                        onChanged: (value) {
                          setState(() {
                            selectedRegion = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Serving',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Serving.';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select Serving',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: serving
                            .map((item) => DropdownMenuItem<int>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedServe,
                        onChanged: (value) {
                          setState(() {
                            selectedServe = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Direction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.height * 0.035,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.orange)),
                    child: const Center(
                      child: Text(
                        'Step 1: Preparation',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Time Preparing (minutes)',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: times
                            .map((item) => DropdownMenuItem<int>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedTimePreparing,
                        onChanged: (value) {
                          setState(() {
                            selectedTimePreparing = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextBoxForm(text: 'Tool Needed', controller: tools),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextBoxForm(
                    text: 'Ingredients Needed', controller: ingredients),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.006,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.height * 0.035,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.orange)),
                    child: const Center(
                      child: Text(
                        'Step 2: Processing',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Time Processing (minutes)',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: times
                            .map((item) => DropdownMenuItem<int>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedTimeProcessing,
                        onChanged: (value) {
                          setState(() {
                            selectedTimeProcessing = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextBoxForm(text: 'Details', controller: processing),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.006,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 5),
                    width: MediaQuery.of(context).size.width * 0.48,
                    height: MediaQuery.of(context).size.height * 0.035,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.orange)),
                    child: const Center(
                      child: Text(
                        'Step 3: Cooking     ',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Time Cooking (minutes)',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.006,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField2(
                        validator: (value) {
                          if (value == null) {
                            return 'Please select';
                          }
                          return null;
                        },
                        isExpanded: true,
                        hint: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            '  Select',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        items: times
                            .map((item) => DropdownMenuItem<int>(
                                  value: item,
                                  child: Text(
                                    '  $item',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedTimeCooking,
                        onChanged: (value) {
                          setState(() {
                            selectedTimeCooking = value;
                          });
                        },
                        buttonHeight: MediaQuery.of(context).size.height * 0.05,
                        buttonWidth: MediaQuery.of(context).size.width,
                        buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white),
                        itemHeight: 40,
                        buttonElevation: 2,
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownMaxHeight: 200,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        dropdownElevation: 8,
                        scrollbarRadius: const Radius.circular(40),
                        scrollbarThickness: 6,
                        scrollbarAlwaysShow: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextBoxForm(text: 'Details', controller: cooking),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                TextFormField(
                    validator: (String? value) {
                      final youtubeValidator = RegExp(
                          r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$');
                      return (value == null ||
                              value.isEmpty ||
                              !youtubeValidator.hasMatch(value))
                          ? 'Please enter valid link Video'
                          : null;
                    },
                    controller: linkVideo,
                    decoration: const InputDecoration(
                      hintText: 'Enter Link',
                      label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'Link Video',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            WidgetSpan(
                              child: Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('SUBMIT',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      updateRecipe(context, postd!);
                    }
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
