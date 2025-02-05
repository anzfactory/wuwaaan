abstract class WordModel {
  final String name;
  final String yomi;
  final String dictionaryType;

  WordModel(this.name, this.yomi, this.dictionaryType);

  String toTextForGoogleDic() => '$yomi\t$name\t$dictionaryType';
}
