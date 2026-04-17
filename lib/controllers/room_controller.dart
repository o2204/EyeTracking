import '../models/room_data.dart';

class RoomController {
  final List<RoomData> rooms = [
    RoomData('Master Bedroom', 4, true, 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?q=80&w=800&auto=format&fit=crop'),
    RoomData('Dining Room', 8, true, 'https://images.unsplash.com/photo-1617806118233-18e1c0945594?q=80&w=800&auto=format&fit=crop'),
    RoomData('Washing Room', 4, false, 'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?q=80&w=800&auto=format&fit=crop'),
  ];

  void toggleRoom(RoomData room) {
    room.isOn = !room.isOn;
  }
}
