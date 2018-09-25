// Card 2

Creation.nodeWithUUID('F974784F-73D7-4066-91E8-7E86F3DF537C').addTapRecognizer(1, 1);
Creation.nodeWithUUID('F974784F-73D7-4066-91E8-7E86F3DF537C').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tapped3DSupply) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
yieldResult = yield [(new Promise(function (resolve) {
tapped3DSupply.animateProperty('xRotation3D', 0, 1, resolve);
})), (new Promise(function (resolve) {
tapped3DSupply.animateProperty('yRotation3D', 0, 1, resolve);
})), (new Promise(function (resolve) {
tapped3DSupply.animateProperty('zRotation3D', 0, 1, resolve);
}))];
yield Creation.playTimelineWithName('Default Timeline');
});
})