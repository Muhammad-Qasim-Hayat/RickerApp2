class Image {
  String key;
  String id;
  String checkedListId;
  String itemName;
  String mainId;
  String url;

  Image(this.key, this.id, this.checkedListId, this.itemName, this.mainId,
      this.url);

  Image.FromDatabase(Map map) {
    key = map['key'];
    id = map['id'];
    checkedListId = map['checkedChecklistId'];
    itemName = map['checkedChecklistId'];
    mainId = map['mainId'];
    url = map['url'];
  }
}
