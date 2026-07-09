#!/usr/bin/env node
// Connects to the buses_updated_channel Phoenix Channel and prints a line
// every time the RequestBrtBusesWorker broadcasts a refresh.
//
// Usage: node scripts/listen_buses.js [ws://host:port]

const TOPIC = "buses_updated_channel";

const base = "ws://localhost:4000";
const url = `${base.replace(/\/$/, "")}/socket/websocket?vsn=2.0.0`;

let ref = 0;
const nextRef = () => String(++ref);

const socket = new WebSocket(url);

function send(joinRef, topic, event, payload) {
  socket.send(JSON.stringify([joinRef, nextRef(), topic, event, payload]));
}

socket.addEventListener("open", () => {
  console.log(`Connected to ${url}`);
  send(nextRef(), TOPIC, "phx_join", {});
});

socket.addEventListener("message", ({ data }) => {
  const [, , topic, event, payload] = JSON.parse(data);

  if (topic !== TOPIC) return;

  if (event === "phx_reply") {
    if (payload.status === "ok") {
      console.log(`Joined "${TOPIC}", waiting for broadcasts...`);
    } else {
      console.error(`Failed to join "${TOPIC}":`, payload.response);
      process.exit(1);
    }
    return;
  }

  console.log(`[${new Date().toISOString()}] ${event} received`);
  console.log("Payload buses:", payload.buses);
});

socket.addEventListener("error", (err) => {
  console.error("WebSocket error:", err.message ?? err);
});

socket.addEventListener("close", () => {
  console.log("Disconnected.");
});
