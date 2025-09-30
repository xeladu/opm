class CustomFolder {
  final String name;
  final int entryCount;
  final bool isDefaultFolder;

  CustomFolder({required this.name, required this.entryCount, this.isDefaultFolder = false});

  @override
  String toString() {
    return "Folder $name";
  }
}
