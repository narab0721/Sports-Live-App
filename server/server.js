const express = require('express');
const { createServer } = require('http');
const { Server } = require('socket.io');

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: "*" } // Allows connections from mobile and OBS
});

const port = process.env.PORT || 3000;

// Log when someone connects
io.on('connection', (socket) => {
  console.log('🔗 A user connected:', socket.id);

  // Handle scoring events from the mobile app
  socket.on('ball_event', (data, ack) => {
    console.log('🏏 Ball Event:', data);
    
    // Broadcast the update to everyone (Admin, OBS, other Scorers)
    io.emit('ball_update', data);

    // Send a "Success" receipt back to the phone
    if (ack) ack({ success: true });
  });

  socket.on('disconnect', () => {
    console.log('❌ User disconnected');
  });
});

httpServer.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});
