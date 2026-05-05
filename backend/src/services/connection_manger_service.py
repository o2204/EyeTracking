from fastapi import HTTPException, WebSocket, status 


class ConnectionManagerService:
    def __init__(self):
        self.active_connections: dict[str, list[WebSocket]] = {}
    
    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()

        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        
        self.active_connections[user_id].append(websocket)
        print(f"User {user_id} connected. Total connections: {len(self.active_connections[user_id])}")
    
    def disconnect(self, user_id: str, websocket):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)

            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        print(f"User {user_id} disconnected. Remaining connections: {len(self.active_connections.get(user_id, []))}")
    
    async def send_notification_to_user(self, user_id: str, message: dict):
        connections = self.active_connections.get(user_id)

        if not connections:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"No active connections for user {user_id}"
            )
        
        disconnected = []

        for ws in self.active_connections[user_id]:
            try: 
                await ws.send_json(message)

            except Exception as e:
                print(f"[Error] sending message to user {user_id}: {e}")
                disconnected.append(ws)

        for ws in disconnected:
            self.active_connections[user_id].remove(ws)
        
        if not self.active_connections[user_id]:
            del self.active_connections[user_id]
    
    async def broadcast(self, message: dict):
        for connections in self.active_connections.values():
            for ws in connections:
                await ws.send_json(message)
    
    def get_online_users(self) -> list[str]:
        return list(self.active_connections.keys())
    
    def get_connection_count(self) -> int:
        return sum(len(connections) for connections in self.active_connections.values())