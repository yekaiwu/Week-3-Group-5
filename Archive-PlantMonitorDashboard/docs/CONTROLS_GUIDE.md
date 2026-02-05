# Controls Guide - Plant Monitoring Dashboard

## Quick Reference

### System Overview Dashboard
- **Location**: Top-right corner button labeled "📊 System Overview"
- **How to Use**: Simply hover your mouse over the button to open the dashboard
- **What it Shows**:
  - All 4 rooms (Living Room, Attic, Balcony, Toilet)
  - Real-time sensor values for each room
  - Color-coded status indicators
  - Status text (Healthy/Warning/Critical)
  - Currently hovered room is highlighted
  - Color legend at the bottom

### Camera Controls

**Arrow Keys** (Smooth Rotation):
- ⬆️ UP Arrow: Tilt camera upward
- ⬇️ DOWN Arrow: Tilt camera downward
- ⬅️ LEFT Arrow: Rotate camera left
- ➡️ RIGHT Arrow: Rotate camera right

**Preset Views** (Number Keys):
- **1**: Top-down view (bird's eye)
- **2**: Front view (straight ahead)
- **3**: Side view from left
- **4**: Side view from right
- **5**: Perspective view (angled)

**Mouse Controls**:
- **Click & Drag**: Free rotation in any direction
- **Scroll Wheel / 2-Finger Trackpad Gesture**: Zoom in/out (smooth zooming)
- **Hover over Room**: See colored bars and detailed info

**Note**: Room names and sensor readings always face you (billboard effect) regardless of camera angle!

### Other Controls

- **R**: Reset camera to default position
- **H**: Toggle help panel on/off
- **U**: Force immediate sensor update (for testing)

## Tips

1. **Best Viewing Experience**:
   - Start with preset view **1** (top-down) to see all rooms
   - Use arrow keys for fine-tuned camera adjustments
   - Hover over "System Overview" button to see all data at once
   - All text automatically faces you - rotate freely without worrying about readability!

2. **Interactive Features**:
   - Hover over any room to see its sensor bars change color
   - The System Overview dashboard stays open while hovering over it
   - Move mouse away from dashboard to close it automatically

3. **Color Meanings**:
   - 🟢 Green: All systems healthy
   - 🟡 Yellow: Warning - attention needed
   - 🔴 Red: Critical - immediate action required
   - ⚫ Grey: Not currently selected/hovered

## Understanding the Interface

### Main Window Layout

```
┌─────────────────────────────────────────────────────┐
│ Title              [📊 System Overview Button]      │
│ Instructions                                        │
│ ┌──────────┐              ┌──────────────────────┐ │
│ │          │              │                      │ │
│ │  Help    │    3D View   │  System Overview    │ │
│ │  Panel   │    (Center)  │  (Hover to show)    │ │
│ │ (Press H)│              │                      │ │
│ │          │              │                      │ │
│ └──────────┘              └──────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Room Identification

When viewing from top-down (Press **1**):
```
┌──────────────┬──────────────┐
│ Living Room  │    Attic     │
│   (Plants)   │  (Storage)   │
├──────────────┼──────────────┤
│   Balcony    │   Toilet     │
│  (Outdoor)   │  (Bathroom)  │
└──────────────┴──────────────┘
```

### Sensor Bars in Each Room

Each room shows 3 vertical bars (from left to right):
1. **Left Bar**: Humidity (💧)
2. **Middle Bar**: Temperature (🌡️)
3. **Right Bar**: Light Level (💡)

**Bar Height** = Sensor Value
- Taller bar = Higher reading
- Shorter bar = Lower reading

## Troubleshooting

**Dashboard won't appear?**
- Make sure you're hovering directly over the "System Overview" button in the top-right
- The dashboard will appear when your mouse is over the button or the dashboard panel itself

**Can't see sensor colors?**
- Colors only show when hovering over a specific room
- All non-hovered rooms appear grey
- Use the System Overview dashboard to see all colors simultaneously

**Camera controls not working?**
- Make sure the main window has focus (click on it)
- Arrow keys only work when not typing in another window
- Press 'R' to reset if camera gets stuck

**Help panel in the way?**
- Press 'H' to hide/show the help panel
- By default, it's hidden on startup

## Keyboard Shortcuts Summary

| Key | Action |
|-----|--------|
| ⬆️⬇️⬅️➡️ | Rotate camera |
| 1-5 | Preset views |
| R | Reset view |
| H | Toggle help |
| U | Update sensors |
| Mouse Drag | Free rotation |
| Mouse Scroll | Zoom |
| Mouse Hover | Activate room/dashboard |
