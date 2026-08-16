#!/bin/bash

gnome-terminal -- bash -c "cd ~/pj/tomato-code/services/auth && npm run dev; exec bash"
gnome-terminal -- bash -c "cd ~/pj/tomato-code/services/restaurant && npm run dev; exec bash"
gnome-terminal -- bash -c "cd ~/pj/tomato-code/services/utils && npm run dev; exec bash"
gnome-terminal -- bash -c "cd ~/pj/tomato-code/services/realtime && npm run dev; exec bash"
gnome-terminal -- bash -c "cd ~/pj/tomato-code/services/rider && npm run dev; exec bash"
gnome-terminal -- bash -c "cd ~/pj/tomato-code/services/admin && npm run dev; exec bash"
gnome-terminal -- bash -c "cd ~/pj/tomato-code/frontend && npm run dev -- --host 0.0.0.0 --port 5177; exec bash"

echo "All services starting..."
