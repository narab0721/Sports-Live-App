require('dotenv').config();
const { io } = require('socket.io-client');
const OBSWebSocket = require('obs-websocket-js').default;

const obs = new OBSWebSocket();
// Connect to your central Node.js server
const socket = io(process.env.SERVER_URL || 'http://localhost:3000/obs');

async function connectToOBS() {
  try {
    await obs.connect(process.env.OBS_WS_URL, process.env.OBS_WS_PASSWORD);
    console.log('✅ Connected to local OBS');
    
    // Once OBS is ready, tell the central server we are open for business!
    socket.emit('register_worker', {
      workerId: process.env.WORKER_ID,
      capabilities: ['cricket_overlay', 'auto_switch']
    });
  } catch (err) {
    console.error('❌ OBS Connection Error:', err.message);
    setTimeout(connectToOBS, 5000); // Retry loop
  }
}

// Listen for commands from the Server
socket.on('obs_command', async (data) => {
  console.log('📥 Received command:', data.command);
  try {
    await obs.call(data.command, data.params);
  } catch (err) {
    console.error('❌ Command execution failed:', err.message);
  }
});

connectToOBS();
