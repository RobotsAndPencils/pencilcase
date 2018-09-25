// Card 1

Creation.nodeWithUUID('75CEA703-E6EB-4362-B7EF-EFD042268AA4').addTapRecognizer(1, 1);
Creation.nodeWithUUID('75CEA703-E6EB-4362-B7EF-EFD042268AA4').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
yield Creation.playTimelineWithName('Scale');
});
})

Creation.nodeWithUUID('B8F3C7CB-652E-4C61-B3C2-D5126957CF86').addTapRecognizer(1, 1);
Creation.nodeWithUUID('B8F3C7CB-652E-4C61-B3C2-D5126957CF86').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
yield (new Promise(function (resolve) {
Creation.nodeWithUUID('83F3ABE5-D9C5-4A62-B0C0-9DDC947D8161').animateProperty('position', { x: 400, y: 600 }, 2, resolve);
}));
});
})

Creation.nodeWithUUID('E52B8CD3-EC02-4ABA-AE64-2F6390D8FCA5').addTapRecognizer(1, 1);
Creation.nodeWithUUID('E52B8CD3-EC02-4ABA-AE64-2F6390D8FCA5').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
yield Creation.playTimelineWithName('Position');
});
})

Creation.nodeWithUUID('ED715992-AC0A-40AA-8DC0-83F973D7AA2C').addTapRecognizer(1, 1);
Creation.nodeWithUUID('ED715992-AC0A-40AA-8DC0-83F973D7AA2C').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
yield Creation.playTimelineWithName('Untitled Timeline');
});
})

Creation.nodeWithUUID('BA2F345D-BD7C-4EFE-AC2B-F6B458433C2F').addTapRecognizer(1, 1);
Creation.nodeWithUUID('BA2F345D-BD7C-4EFE-AC2B-F6B458433C2F').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.stopTimelineWithName('Untitled Timeline');
});
})

Creation.nodeWithUUID('5FFCCCB4-34E2-4A6B-B324-CDC23627F128').addTapRecognizer(1, 1);
Creation.nodeWithUUID('5FFCCCB4-34E2-4A6B-B324-CDC23627F128').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedImage) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.stopTimelineWithName('Scale');
});
})