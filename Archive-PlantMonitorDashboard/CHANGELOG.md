# Changelog - Plant Monitoring Dashboard

## Latest Updates

### Billboard Text Feature ✨
**All text now always faces the camera!**

- **Room Names**: Always readable regardless of camera rotation
- **Sensor Labels**: Hover over any room to see sensor names facing you
- **Sensor Values**: Temperature, humidity, and light readings always upright
- **Status Indicators**: Health status (Healthy/Warning/Critical) always visible

**How it works**: The text uses "billboarding" - a 3D technique that automatically rotates text to face the camera viewpoint. Rotate the view freely with arrow keys or mouse dragging, and all text remains perfectly readable!

### Enhanced Zoom Controls 🔍
**Smooth zooming with trackpad support!**

- **2-Finger Trackpad Gestures**: Now fully supported for smooth zooming
- **Mouse Wheel**: Also works for zooming in/out
- **Zoom Range**:
  - Very close: 100 units (see details up close)
  - Very far: 1500 units (bird's eye view of entire system)
- **Smooth Transitions**: Zoom speed optimized for both mouse and trackpad

**How to use**:
- On trackpad: Use 2-finger scroll gesture (up = zoom in, down = zoom out)
- With mouse: Use scroll wheel (up = zoom in, down = zoom out)
- Press 'R' to reset to default zoom level

### Camera Rotation Improvements 🎥

**Arrow Keys**: Precise camera control
- ⬆️ UP: Tilt camera upward
- ⬇️ DOWN: Tilt camera downward
- ⬅️ LEFT: Rotate left
- ➡️ RIGHT: Rotate right

**Preset Views** (Number Keys 1-5):
- **1**: Top-down view (perfect for overview)
- **2**: Front view (straight-ahead look)
- **3**: Side view from left
- **4**: Side view from right
- **5**: Perspective view (angled)

### UI Improvements 🎨

**Hidden Help Panel**:
- Help panel now hidden by default for cleaner interface
- Press 'H' to toggle on/off anytime

**Hover-Activated Dashboard**:
- System Overview dashboard only appears when needed
- Hover over "📊 System Overview" button in top-right corner
- Dashboard stays open while you're viewing it
- Automatically closes when you move away

## Technical Details

### Billboard Implementation
The billboard effect is achieved by:
1. Capturing current camera rotation values (rotationX, rotationY, rotationZ)
2. Passing these to each quadrant's display function
3. Applying inverse rotations to text elements
4. Text appears at correct 3D position but faces the camera

### Zoom Implementation
Camera zoom is controlled by:
1. Adjusting the Z-translation in `setupCamera()`
2. Using `cameraDistance` variable (100-1500 range)
3. Processing 2-finger trackpad gestures via `mouseWheel(MouseEvent)`
4. Smooth interpolation for natural feel

## Benefits

✅ **Better Readability**: No more sideways or upside-down text!
✅ **Natural Interaction**: Trackpad gestures work as expected
✅ **Flexible Viewing**: Examine from any angle without losing information
✅ **Cleaner Interface**: Dashboard appears only when needed
✅ **Easier Navigation**: Arrow keys + presets make it simple to find the best view

## Compatibility

- **Processing 3.x**: ✅ Full support
- **Processing 4.x**: ✅ Full support
- **Mouse**: ✅ Scroll wheel zoom
- **Trackpad**: ✅ 2-finger gestures (Mac, Windows, Linux)
- **All Platforms**: ✅ Arrow keys, drag-to-rotate, preset views

## How to Test

1. **Billboard Text**:
   - Run the sketch
   - Press arrow keys or drag to rotate view in any direction
   - Hover over a room
   - Notice: All text (room names, sensor values) stays upright!

2. **Trackpad Zoom**:
   - Place 2 fingers on trackpad
   - Scroll up to zoom in (get closer)
   - Scroll down to zoom out (get farther)
   - Notice: Smooth, responsive zooming

3. **Preset Views**:
   - Press keys 1, 2, 3, 4, 5 in sequence
   - Notice: Camera jumps to different preset angles
   - Text remains readable in all views

4. **Dashboard Toggle**:
   - Move mouse to top-right corner
   - Hover over "System Overview" button
   - Dashboard appears showing all sensor data
   - Move mouse away - dashboard disappears

## Future Enhancements (Potential)

- [ ] Animated transitions between preset views
- [ ] Custom view bookmarks (save your favorite angles)
- [ ] Pinch-to-zoom gesture support (touch screens)
- [ ] VR/AR viewing mode
- [ ] Export current view as image

---

**Version**: 2.0
**Last Updated**: February 4, 2026
**Features**: Billboard text, Enhanced zoom, Hover dashboard, Arrow key rotation
