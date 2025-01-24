class Node {
  int iD;
  String leftButtonText;
  int leftNextNodeId;
  String rightButtonText;
  int rightNextNodeId;
  String description;
  String imageUrl;

  Node(
    this.iD,
    this.leftButtonText,
    this.leftNextNodeId,
    this.rightButtonText,
    this.rightNextNodeId,
    this.description,
    this.imageUrl,
  );
}
