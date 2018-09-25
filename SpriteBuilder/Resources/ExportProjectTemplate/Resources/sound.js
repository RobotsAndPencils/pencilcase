// Currently resolves immediately
exports.playSoundAtPath = function(soundPath) {
    // Resolve immediately if sound is invalid
    if (typeof soundPath !== 'string' || soundPath.length == 0) return Promise.resolve();

    return new Promise(function(resolve) {
        __sound_playSoundAtPath(soundPath, resolve);
    });
};

exports.playSoundWithUUID = function(uuidString) {
     // Resolve immediately if uuid is invalid
    if (typeof uuidString !== 'string' || uuidString.length == 0) return Promise.resolve();

    var soundPath = ResourceManager.sharedInstance().resources[uuidString];
    if (!soundPath) return Promise.resolve();
    return exports.playSoundAtPath(soundPath);
};