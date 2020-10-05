import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ricker_app/schemas/checked_checklist_schema.dart';
import 'package:ricker_app/schemas/checklist_form_schema.dart';
import 'package:ricker_app/schemas/checklist_item_form_schema.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/schemas/user_schema.dart';
import 'package:ricker_app/services/http_service.dart';
import 'package:ricker_app/schemas/checklist_schema.dart';

abstract class ChecklistService {
  static Checklist currentChecklist;
  static ChecklistForm currentChecklistForm;

  static void setCurrentChecklist(Checklist checklist) {
    currentChecklist = checklist;
  }

  static void setCurrentChecklistForm(ChecklistForm checklistForm) {
    currentChecklistForm = checklistForm;
  }

  static void unsetCurrentChecklist() {
    currentChecklist = null;
  }

  static void unsetCurrentChecklistForm() {
    currentChecklistForm = null;
  }

  static void unsetCurrentChecklistAndChecklistForm() {
    currentChecklist = null;
    currentChecklistForm = null;
  }

  static bool allDone() {
    if (currentChecklist == null || currentChecklistForm == null) {
      return false;
    }

    // Check if all items are present
    var itemIds = currentChecklist.items.where((i) => !i.optional).map((i) => i.id);
    var checkedItemIds = currentChecklistForm.items.where((i) => !i.optional).map((i) => i.itemId);

    if (!itemIds.every((i) => checkedItemIds.contains(i))) {
      return false;
    }

    // Check if all items has been marked with hasProblem or not
    if (!currentChecklistForm.items.where((i) => !i.optional).every((i) => i.hasProblem != null)) {
      return false;
    }

    // Check if all required photos are present
    var requiredPhotoItemIds = currentChecklist.items.where((i) => !i.optional && i.requiredPhoto).map((i) => i.id);

    if (!currentChecklistForm.items.where((i) => requiredPhotoItemIds.contains(i.itemId)).every((i) => i.images.length > 0)) {
      return false;
    }

    return true;
  }

  static ChecklistItemForm getByChecklistItemId(String id) {
    return currentChecklistForm.items.firstWhere((i) => i.itemId == id, orElse: () => null);
  }

  static bool isChecked(ChecklistItemForm item) {
    return item != null && item.hasProblem != null;
  }

  static bool hasProblem(ChecklistItemForm item) {
    if (item != null) {
      return item.hasProblem;
    }

    return false;
  }

  static bool photoStillRequired(bool requiredPhoto, ChecklistItemForm item) {
    if (item != null && item.optional) return false;
    return item == null ? requiredPhoto : requiredPhoto && item.images.length == 0;
  }

  static Future<ChecklistForm> startCheckedChecklist(String checklistId, String vehicleId, ChecklistTypes type) async {
    var data = {
      'vehicleId': vehicleId,
      'type': describeEnum(type),
    };

    var response = await HttpService.post('/checklists/$checklistId/start', data: data);
    var checkedChecklist = ChecklistForm.fromJson(response.data['checkedChecklist']);
    var checklist = Checklist.fromJson(response.data['checklist']);

    setCurrentChecklistForm(checkedChecklist);
    setCurrentChecklist(checklist);

    return checkedChecklist;
  }

  static Future<ChecklistItemForm> checkItem(String itemId, {String comments, bool hasProblem}) async {
    print('checkItem');
    var data = <String, dynamic>{
      'itemId': itemId,
    };

    if (comments != null) {
      data['comments'] = comments;
    }

    if (hasProblem != null) {
      data['hasProblem'] = hasProblem;
    }

    var response = await HttpService.patch('/checklists/check', data: data);

    return ChecklistItemForm.fromJson(response.data['item']);
  }

  static Future<void> deleteItemImage(String itemId, String filename) async {
    var data = {
      'itemId': itemId,
      'filename': filename,
    };

    await HttpService.delete('/checklists/photo', data: data);
  }

  static Future<void> finishCheckedChecklist(double lat, double lng, [String replacementUserId]) async {
    print('finishedchecked');

    var data = <String, dynamic>{
      'lat': lat,
      'lng': lng,
    };

    if (replacementUserId != null) {
      data['replacementUserId'] = replacementUserId;
    }

    await HttpService.patch('/checklists/finish', data: data);
  }

  static Future<List<LatestChecklist>> getLatestCheckedChecklists() async {
    print('getLatest');

    var response = await HttpService.get('/checklists/checked/latest');
    return response.data['latestCheckedChecklists'].map<LatestChecklist>((c) => LatestChecklist.fromJson(c)).toList();
  }

  static Future<Response> getAllCheckedChecklists({int page = 1}) async {
    print('getAllChecked');

    return HttpService.get('/checklists/checked?page=$page');
  }

  static Future<User> requestVehicleReplacement(String checklistId, String registration, String password) async {
    print('requestReplacement');

    var data = {
      'registration': registration,
      'password': password,
    };

    var response = await HttpService.post('/checklists/$checklistId/replacement/request', data: data);

    return User.fromJson(response.data);
  }

  // static Future<void> submitVehicleReplacement(String checklistId, String userId, String vehicleId) async {
  //   var data = {
  //     'userId': userId,
  //     'vehicleId': vehicleId,
  //   };

  //   return HttpService.post('/checklists/$checklistId/replacement/submit', data: data);
  // }

  static Future<ChecklistForm> getUnfinishedChecklist() async {
    print('getUnfinished');

    var response = await HttpService.get('/checklists/unfinished');
    return ChecklistForm.fromJson(response.data['currentCheckedChecklist']);
  }

  static Future<CheckedChecklist> getCheckedChecklist(String id) async {
    print('getCheckedCheckList');

    var response = await HttpService.get('/checklists/checked/$id');
    return CheckedChecklist.fromJson(response.data);
  }

  static Future<void> deleteUnfinishedChecklist() async {
    await HttpService.delete('/checklists/unfinished');
    unsetCurrentChecklistForm();
  }

  static Future<void> verifyIntegrity() async {

    await HttpService.get('/checklists/verify');
  }
}
