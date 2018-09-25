// Card 1

Creation.nodeWithUUID('ABA38299-2F36-4587-9F1D-0D2CCF6C0898').addTapRecognizer(1, 1);
Creation.nodeWithUUID('ABA38299-2F36-4587-9F1D-0D2CCF6C0898').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedButton) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.nodeWithUUID('3DF78E01-4829-4C72-B4B7-7B47CAF6CF29').goToView(2, 0, 0);
});
})

Creation.nodeWithUUID('18CB19E1-DFCB-476D-AE86-C664F38FDD7D').addTapRecognizer(1, 1);
Creation.nodeWithUUID('18CB19E1-DFCB-476D-AE86-C664F38FDD7D').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedButton) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.nodeWithUUID('3DF78E01-4829-4C72-B4B7-7B47CAF6CF29').goToView(Creation.nodeWithUUID('3DF78E01-4829-4C72-B4B7-7B47CAF6CF29').previousIndex(), 1, 0);
});
})

Creation.nodeWithUUID('961CEA18-626C-4C69-B9F7-4C3BA22B02D1').addTapRecognizer(1, 1);
Creation.nodeWithUUID('961CEA18-626C-4C69-B9F7-4C3BA22B02D1').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedButton) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.nodeWithUUID('647CC6C4-56A2-482E-ADDC-664EAD23CA77').clear();
});
})

Creation.nodeWithUUID('961CEA18-626C-4C69-B9F7-4C3BA22B02D1').on('toggled', function() {
if ('on' !== 'any' && arguments[0] !== 'on') return;
co(function *() {
var yieldResult;
yield Sound.playSoundWithUUID('043B6430-96B9-46AA-B6B3-74920FF0C050');
});
})

Creation.nodeWithUUID('961CEA18-626C-4C69-B9F7-4C3BA22B02D1').on('toggled', function() {
if ('off' !== 'any' && arguments[0] !== 'off') return;
co(function *() {
var yieldResult;
yield Sound.playSoundWithUUID('E9BF1D40-6C18-4CF2-BFCF-9CC929966ECF');
});
})

Creation.nodeWithUUID('078D8DCC-094E-4E4E-8D3B-244691D475DD').addTapRecognizer(1, 1);
Creation.nodeWithUUID('078D8DCC-094E-4E4E-8D3B-244691D475DD').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedButton) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.nodeWithUUID('3DF78E01-4829-4C72-B4B7-7B47CAF6CF29').goToView(Creation.nodeWithUUID('3DF78E01-4829-4C72-B4B7-7B47CAF6CF29').nextIndex(), 0, 0);
});
})

Creation.nodeWithUUID('C7E4AA17-4A54-4506-8567-F09856063BD9').addTapRecognizer(1, 1);
Creation.nodeWithUUID('C7E4AA17-4A54-4506-8567-F09856063BD9').on('tap', function(tapLocation, numberOfTaps, numberOfTouches, tappedColorLayer) {
if (numberOfTaps !== 1 || numberOfTouches !== 1) return;
co(function *() {
var yieldResult;
Creation.nodeWithUUID('961CEA18-626C-4C69-B9F7-4C3BA22B02D1').visible = !Creation.nodeWithUUID('961CEA18-626C-4C69-B9F7-4C3BA22B02D1').visible;
});
})