// Card 1

Creation.nodeWithUUID('B37792B1-25B2-49B5-BC4C-05C7F65D3D5D').addTapRecognizer(1, 1);
Creation.nodeWithUUID('B37792B1-25B2-49B5-BC4C-05C7F65D3D5D').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
yield Creation.playTimelineWithName('Untitled Timeline');
});
})

Creation.nodeWithUUID('04C160F8-1D76-4FC6-B200-27D5773828F8').addTapRecognizer(1, 1);
Creation.nodeWithUUID('04C160F8-1D76-4FC6-B200-27D5773828F8').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.stopTimelineWithName('Untitled Timeline');
});
})