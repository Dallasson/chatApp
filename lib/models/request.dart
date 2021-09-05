class RequestModel {
  String userName;
  String status;
  String senderId;
  String time;
  String imageUrl;
  String receiverId;

  RequestModel(
      {required this.userName,
      required this.status,
      required this.senderId,
      required this.time,
      required this.imageUrl,
      required this.receiverId});
}
