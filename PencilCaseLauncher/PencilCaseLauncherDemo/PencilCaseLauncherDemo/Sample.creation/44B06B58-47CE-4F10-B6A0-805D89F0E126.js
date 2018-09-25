Event.on('timelineFinished', function() {
if (arguments[0] !== 'Default Timeline') return;
co(function *() {
var yieldResult;
yield App.playTimelineWithName('Default Timeline');
});
})

Event.on('cardLoad', function() {
co(function *() {
var yieldResult;
yield App.playTimelineWithName('Default Timeline');
});
})