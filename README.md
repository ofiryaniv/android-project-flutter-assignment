
Dry Part

1. The class that implement the controller for SnappingSheet is SnappingSheetController.
It allows modifiying and reading the currentSnapPosition (modify is done using snapToPosition) also
It allows reading and changing the snapPositions list which is the list of locations where the sheets could connect.

2. The parameters used to choose how the animate would look like when snapping the sheets to other location
is snappingCurve and snappingDuration.
snappingCurve- controls the animation type.
snappingDuration- controls the time would take for the animation.
both parameters are part of SnapPosition that control the position and animation of the snapping sheet.

3. Both GestureDetector and InkWell are used for gesture detection.
InkWell is used when the developer wants a Material Design ripple effect (that is not an option in GestureDetector).
GestureDetector let the developer more control over the widget.