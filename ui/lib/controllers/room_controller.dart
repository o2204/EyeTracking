import '../models/room_data.dart';

class RoomController {
  final List<RoomData> rooms = [
    RoomData(
      'Master Bedroom',
      4,
      true,
      'assets/images/master_room.jpg',
    ),
    RoomData(
      'Dining Room',
      8,
      true,
      'assets/images/dining_room.jpg',
    ),
    RoomData(
      'Washing Room',
      4,
      false,
      'assets/images/washing_room.jpg',
    ),
  ];

  void toggleRoom(RoomData room) {
    room.isOn = !room.isOn;
  }
}