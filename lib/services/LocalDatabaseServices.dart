import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ricker_app/schemas/checked_checklist_schema.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_schema.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';
import 'package:ricker_app/schemas/image_schema.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/schemas/user_schema.dart';
import 'package:ricker_app/schemas/vehicle_model_schema.dart';
import 'package:ricker_app/schemas/vehicle_schema.dart';
import 'package:ricker_app/services/auth_service.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseHandler {
  FlutterSecureStorage flutterSecureStorage = new FlutterSecureStorage();

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'RickerApp.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("""
          CREATE TABLE HomePageData(
          id Text PRIMARY KEY,
          vehicleName Text,
          hasProblem Text,
          createdAt Text,
          finishedAt Text,
          type Text
          )""");

      await db.execute("""
          CREATE TABLE VehicleModelData(
          id Text PRIMARY KEY,
          brand Text,
          name Text
          )""");

      await db.execute("""
          CREATE TABLE VehicleData(
          id Text PRIMARY KEY,
          vehicleModelId Text,
          plate Text,
          vehicleModel Text
          )""");

      await db.execute("""
          CREATE TABLE CheckListItem(
          listID Text ,
          mainId Text,
          key Text,
          itemID Text,
          name Text,
          description Text,
          requiredPhoto Text,
          optional Text
          )""");

      await db.execute("""
          CREATE TABLE CheckListItemForm(
          id Text,
          mainId Text,
          key Text,
          optional Text,
          hasProblem Text,
          Comments Text
          )""");

      await db.execute("""
          CREATE TABLE CheckListFormTable(
          key Text PRIMARY KEY,
          id Text,
          checkListId Text,
          VehicleId Text,
          type Text,
          SignatureUrl Text

          )""");

      await db.execute("""
          CREATE TABLE TypeScreen(
          vehicleID Text ,
          checkListID Text,
          key Text
          )""");

      await db.execute("""
          CREATE TABLE CheckListItemTypeScreen(
          id Text ,
          Key Text,
          itemID Text,
          name Text,
          description Text,
          requiredPhoto Text,
          optional Text
          )""");

      await db.execute("""
          CREATE TABLE Images(
          key Text,
          id Text,
          checkedChecklistId Text,
          name Text,
          mainId Text,
          url Text
          )""");

      await db.execute("""
      CREATE TABLE CheckedVehicles(
      checkedId Text,
      brand Text,
      name Text,
      plate Text
      )""");

      await db.execute("""CREATE TABLE CheckedChecklistItem(
      checkedChecklistId Text,
      comments Text,
      hasProblem Integer,
      name Text,
      optional Integer
     )""");

      await db.execute("""CREATE TABLE replacementUser(
      id Text,
      name Text,
      email Text,
      imageUrl Text,
      role Text,
      registration Text)
      """);

      await db.execute("""CREATE TABLE CheckedChecklist(
      id Text,
      userId Text,
      vehicleId Text,
      type Text,
      signatureUrl Text,
      createdAt Text,
      finishedAt Text,
      lat Text,
      lng Text,
      sequentialNumber Integer)
       """);
    });
  }

  addToCheckedChecklist(CheckedChecklist checkedChecklist) async {
    final db = await init();
    Map<String, dynamic> checkedlistMap = {
      "id": checkedChecklist.id,
      "vehicleId": checkedChecklist.vehicle.plate,
      "type": checkedChecklist.type.toString(),
      "signatureUrl": checkedChecklist.signatureUrl,
      "createdAt": checkedChecklist.createdAt,
      "finishedAt": checkedChecklist.finishedAt,
      "lat": checkedChecklist.lat.toString(),
      "lng": checkedChecklist.lng.toString(),
      "sequentialNumber": checkedChecklist.sequentialNumber
    };

    Map<String, dynamic> vehicleMap = {
      "checkedId": checkedChecklist.id,
      "brand": checkedChecklist.vehicle.brand,
      "plate": checkedChecklist.vehicle.plate,
      "name": checkedChecklist.vehicle.name
    };

    await db.rawDelete("DELETE FROM CheckedVehicles WHERE checkedId= ?",
        [checkedChecklist.vehicle.plate]);
    await db.rawDelete(
        "DELETE FROM CheckedChecklist WHERE id= ?", [checkedChecklist.id]);

    await db.rawDelete(
        "DELETE FROM CheckedChecklistItem WHERE checkedChecklistId = ?",
        [checkedChecklist.id]);
    await db.rawDelete("DELETE FROM Images WHERE checkedChecklistId = ?",
        [checkedChecklist.id]);

    checkedChecklist.checkedItems.forEach((uperelement) async {
      uperelement.images.forEach((element) async {
        Map<String, dynamic> imageMap = {
          "url": element,
          "checkedChecklistId": checkedChecklist.id,
          "name": uperelement.name
        };
        await db.insert("Images", imageMap);
      });
      var map = uperelement.toMap();
      map["checkedChecklistId"] = checkedChecklist.id;
      await db.insert("CheckedChecklistItem", map);
    });
    await db.insert("CheckedVehicles", vehicleMap);
    await db.insert("CheckedChecklist", checkedlistMap);
  }

  deleteWholeData() async {
    final db = await init();
    db.delete("CheckListItemTypeScreen");
    db.delete("TypeScreen");
    db.delete("CheckListFormTable");
    db.delete("Images");
    db.delete("CheckListItemForm");
    db.delete("CheckListItem");
    db.delete("HomePageData");
  }

  addToTypeScreenTable(Checklist checklist, String vehilceID) async {
    String key = checklist.id + vehilceID;
    final db = await init();

    Map<String, dynamic> map = {
      "vehicleID": vehilceID,
      "checkListID": checklist.id,
      "key": key,
    };

    try {
      db.rawDelete('DELETE FROM CheckListItemTypeScreen WHERE key = ? ', [key]);
      db.rawDelete('DELETE FROM TypeScreen WHERE key = ? ', [key]);
    } catch (e) {}

    for (int i = 0; i < checklist.items.length; i++) {
      await _addToCheckListItemTypeScreen(checklist.items[i], key);
    }

    await db.insert('TypeScreen', map);

    showAllDataFromTable("CheckListFormTable");
  }

  Future<CheckedChecklist> getCheckedChecklist(
      String checkedChecklistId) async {
    final db = await init();
    var checkedChecklistMap = await db.rawQuery(
        "Select * from CheckedChecklist where id = ?", [checkedChecklistId]);

    var imagesListMap = await db.rawQuery(
        "Select * from Images where checkedChecklistId = ?",
        [checkedChecklistId]);

    var checkedlistItemMap = await db.rawQuery(
        "Select * from CheckedChecklistItem where checkedChecklistId=?",
        [checkedChecklistId]);

    var vehicleMap = await db.rawQuery(
        "Select * from CheckedVehicles where checkedId =?",
        [checkedChecklistId]);

    List<Image> imagesList = List<Image>();
    if (imagesListMap != null) {
      imagesListMap.forEach((element) {
        imagesList.add(Image.FromDatabase(element));
      });
    }
    //Got Item
    List<CheckedChecklistItem> checkedItemList = List<CheckedChecklistItem>();
    if (checkedlistItemMap != null) {
      checkedlistItemMap.forEach((element) {
        checkedItemList.add(CheckedChecklistItem.fromDatabase(
            element, imagesListFunction(imagesList, element['name'])));
      });
    }
    var vehicleEntity;
    vehicleMap.forEach((element) {
      vehicleEntity = CheckedChecklistVehicle.fromDatabase(element);
    });
    CheckedChecklist checklist;
    checkedChecklistMap.forEach((element) {
      checklist = CheckedChecklist.fromDatabase(
          element, vehicleEntity, checkedItemList);
    });
    return checklist;
  }

  //for getting images for the comment of CheckedChecklistItem
  List<String> imagesListFunction(List<Image> imageList, String item) {
    List<String> imagesList = List<String>();
    if (imagesList != null) {
      imageList.forEach((element) {
        if (element.itemName == item) {
          imagesList.add(element.url);
        }
      });
    }
    return imagesList;
  }

  Future<Checklist> getTypeScreen(String vehicleID) async {
    final db = await init();
    var rawCheckListId = await db
        .rawQuery("Select * from TypeScreen where vehicleID = ?", [vehicleID]);
    String checkListId;
    checkListId = rawCheckListId.isNotEmpty
        ? checkListId = rawCheckListId[0]['checkListID']
        : checkListId = null;
    var rawItems = await db.rawQuery(
        "Select * from CheckListItemTypeScreen where key = ?",
        [checkListId.toString() + vehicleID]);

    List<ChecklistItem> items = [];

    for (int i = 0; i < rawItems.length; i++) {
      items.add(ChecklistItem(
        id: rawItems[i]['id'],
        optional: rawItems[i]['optional'].toString() == 'null'
            ? null
            : (rawItems[i]['optional'].toString() == 'true' ? true : false),
        description: rawItems[i]['description'],
        requiredPhoto: rawItems[i]['requiredPhoto'].toString() == 'null'
            ? null
            : (rawItems[i]['requiredPhoto'].toString() == 'true'
                ? true
                : false),
        name: rawItems[i]['name'],
      ));
    }

    return Checklist(id: checkListId, items: items);
  }

  _addToCheckListItemTypeScreen(ChecklistItem checklistItem, String key) async {
    final db = await init();

    Map<String, dynamic> map = {
      "id": checklistItem.id,
      "key": key,
      "name": checklistItem.name,
      "description": checklistItem.description,
      "requiredPhoto": checklistItem.requiredPhoto.toString(),
      "optional": checklistItem.optional.toString(),
    };

    await db.insert('CheckListItemTypeScreen', map);
  }

  addCheckListFunction(ChecklistForm checklistForm) async {
    showAllDataFromTable("CheckListFormTable");

    Checklist checklist = checklistForm.checklist;
    List<ChecklistItemForm> checkListItemForm = checklistForm.items;

    Map<String, dynamic> map = {
      "key": checklistForm.checklist.id +
          checklistForm.vehicle.id +
          checklistForm.type.toString(),
      "id": checklistForm.id,
      "checkListId": checklistForm.checklist.id,
      "VehicleId": checklistForm.vehicle.id,
      "type": checklistForm.type.toString(),
      "SignatureUrl": checklistForm.signatureUrl,
    };

    final db = await init();

    try {
      db.rawDelete('DELETE FROM CheckListFormTable WHERE key = ? ', [
        checklistForm.checklist.id +
            checklistForm.vehicle.id +
            checklistForm.type.toString()
      ]);
    } catch (e) {}

    await db.insert('CheckListFormTable', map);

    try {
      db.rawDelete(
          'DELETE FROM CheckListItem WHERE mainId = ?', [checklistForm.id]);
    } catch (e) {}

    for (int i = 0; i < checklistForm.checklist.items.length; i++) {
      await _addToCheckListItemTable(
          checklistForm.checklist.items[i],
          checklistForm.checklist.id,
          checklistForm.id,
          checklistForm.checklist.id +
              checklistForm.vehicle.id +
              checklistForm.type.toString());
    }

    try {
      db.rawDelete('DELETE FROM CheckListItemForm WHERE key = ?', [
        checklistForm.checklist.id +
            checklistForm.vehicle.id +
            checklistForm.type.toString()
      ]);
    } catch (e) {}

    checkListItemForm.forEach((element) {
      _addToCheckListItemFormTable(
          element,
          checklist.id,
          checklistForm.id,
          checklistForm.checklist.id +
              checklistForm.vehicle.id +
              checklistForm.type.toString());
    });

    ChecklistForm testCheckListForm = await getCheckListFunction(
        checklistForm.checklist.id,
        checklistForm.vehicle.id,
        checklistForm.type);
    print('Here\n\n\n');
    print(checklistForm.items.length);
    print(testCheckListForm.items.length);
    for (int i = 0; i < testCheckListForm.items.length; i++) {
      print(testCheckListForm.items[i]);
      print(checklistForm.items[i]);
      print('$i \n\n\n');
    }
  }

  Future<ChecklistForm> getCheckListFunction(
      String checkListId, String vehicleID, ChecklistTypes type) async {
    final db = await init();
    List<Map<String, dynamic>> x = await db.rawQuery(
        "Select * from CheckListFormTable where key = ?",
        [checkListId + vehicleID + type.toString()]);
    List<Map<String, dynamic>> y = await db
        .rawQuery("Select * from CheckListFormTable where id = ?", [vehicleID]);
    String id = x.isEmpty ? null : x[0]['id'];

    Checklist checklist = await _getCheckListItem(
        id.toString(), checkListId + vehicleID + type.toString());

    ChecklistForm item = new ChecklistForm(
      id: id,
      checklist: checklist,
      items: await _getCheckListItemFormTable(
          id, checkListId + vehicleID + type.toString()),
      signatureUrl: x.isEmpty ? null : x[0]["SignatureUrl"],
      type: type,
      vehicle: y.isEmpty ? null : Vehicle.fromJson(y[0]),
    );

    return item;
  }

  _addToCheckListItemFormTable(ChecklistItemForm checklistItemform,
      String listId, String mainID, String key) async {
    final db = await init();

    Map<String, dynamic> map = {
      "id": checklistItemform.itemId,
      "key": key,
      "mainId": mainID,
      "optional": checklistItemform.optional.toString(),
      "hasProblem": checklistItemform.hasProblem.toString(),
      "Comments": checklistItemform.comments,
    };
    await db.insert('CheckListItemForm', map);

    _addImageUrls(
        checklistItemform.images, checklistItemform.itemId, mainID, key);
  }

  List<ChecklistItemForm> checklistItemForm = [];

  Future<List<ChecklistItemForm>> _getCheckListItemFormTable(
      String mainId, String key) async {
    final db = await init();

    List<Map<String, dynamic>> x = await db
        .rawQuery("Select * from CheckListItemForm where key = ?", [key]);

    for (int i = 0; i < x.length; i++) {
      List<String> images =
          await _getImageUrls(x[i]['id'], x[i]['mainId'], key);

      ChecklistItemForm checklistItemF = new ChecklistItemForm(
          itemId: x[i]['id'],
          optional: x[i]['optional'].toString() == "null"
              ? null
              : (x[i]['optional'].toString() == "true" ? true : false),
          hasProblem: x[i]['hasProblem'].toString() == "null"
              ? null
              : (x[i]['hasProblem'].toString() == "true" ? true : false),
          images: images);

      checklistItemForm.add(checklistItemF);
    }

    return checklistItemForm;
  }

  _addImageUrls(List<String> urls, String id, String mainID, String key) async {
    final db = await init();

    try {
      db.rawDelete('DELETE FROM Images WHERE mainId = ?', [mainID]);
    } catch (e) {}

    urls.forEach((element) async {
      Map<String, dynamic> map = {
        "id": id,
        "key": key,
        "mainId": mainID,
        "url": element.toString(),
      };
      await db.insert('Images', map);
    });
  }

  Future<List<String>> _getImageUrls(
      String id, String mainId, String key) async {
    final db = await init();
    var x = await db
        .rawQuery("Select * from Images where id = ? and key = ?", [id, key]);

    List<String> imageUrls = [];

    x.forEach((element) {
      imageUrls.add(element['url']);
    });

    return imageUrls;
  }

  _addToCheckListItemTable(ChecklistItem checklistItem, String listId,
      String mainID, String key) async {
    final db = await init();
    Map<String, dynamic> map = {
      "listID": listId,
      "key": key,
      "itemID": checklistItem.id,
      "mainId": mainID,
      "name": checklistItem.name,
      "description": checklistItem.description,
      "requiredPhoto": checklistItem.requiredPhoto.toString(),
      "optional": checklistItem.optional.toString(),
    };
    await db.insert('CheckListItem', map);
  }

  Future<Checklist> _getCheckListItem(String mainId, String key) async {
    final db = await init();
    var x =
        await db.rawQuery("Select * from CheckListItem where key = ?", [key]);
    List<ChecklistItem> checkListItems = [];
    x.forEach((element) {
      checkListItems.add(new ChecklistItem(
          id: element['itemID'],
          name: element['name'],
          requiredPhoto: element['requiredPhoto'] == "null"
              ? null
              : (element['requiredPhoto'] == "true" ? true : false),
          optional: element['optional'] == "null"
              ? null
              : (element['optional'] == "true" ? true : false),
          description: element['description']));
    });
    Checklist checklist = checkListItems.isEmpty
        ? null
        : Checklist(id: x[0]['listID'], items: checkListItems);
    return checklist;
  }

  addHomepageData(List<LatestChecklist> checklist) async {
    final db = await init();
    await db.delete("HomePageData");
    checklist.forEach((element) async {
      await db.insert('HomePageData', element.toMap());
    });
  }

  Future<List<LatestChecklist>> getCheckList() async {
    final db = await init();
    final maps = await db.query('HomePageData');
    List<LatestChecklist> checkList = [];
    maps.forEach((element) {
      checkList.add(LatestChecklist.fromJson(element));
    });
    return checkList;
  }

  addVehicle(List<Vehicle> vehicle) async {
    final db = await init();
    await db.delete("VehicleData");

    vehicle.forEach((element) async {
      await db.insert('VehicleData', element.toMap());
    });
  }

  addVehicleModel(List<VehicleModel> vehicleModel) async {
    final db = await init();
    await db.delete("VehicleModelData");

    vehicleModel.forEach((element) async {
      await db.insert('VehicleModelData', element.toMap());
    });
  }

  Future<List<VehicleModel>> getVehicleModels() async {
    final db = await init();
    final maps = await db.query('VehicleModelData');
    List<VehicleModel> models = [];

    maps.forEach((element) {
      models.add(
        VehicleModel(
            id: element['id'], brand: element['brand'], name: element['name']),
      );
    });
    return models;
  }

  Future<List<Vehicle>> getVehicles() async {
    final db = await init();
    final maps = await db.query('VehicleData');
    int x;
    List<VehicleModel> vehicleModels = await getVehicleModels();
    List<Vehicle> models = [];
    maps.forEach((element) {
      x = vehicleModels
          .indexWhere((model) => model.id == element['vehicleModelId']);
      models.add(
        Vehicle(
          id: element['id'],
          plate: element['plate'],
          vehicleModelId: element['vehicleModelId'],
          vehicleModel: vehicleModels[x],
        ),
      );
    });
    return models;
  }

  showAllDataFromTable(String tableName) async {
    final db = await init();
    print('Database');
    var map = await db.query(tableName);
    print(map);
  }

  saveRole() async {
    if (AuthService.currentUser.role == UserRoles.driver) {
      await flutterSecureStorage.write(key: 'Role', value: "true");
    } else {
      await flutterSecureStorage.write(key: 'Role', value: "false");
    }
  }

  Future<bool> role() async {
    String driver = await flutterSecureStorage.read(key: 'Role');
    if (driver == "true")
      return true;
    else
      return false;
  }
}
