
exports.loadLastImageFromImageLibrary = function() {
    return new Promise(function(resolve) {
        __photoLibrary_loadLastImage(function(photo) {
            resolve(photo);
        });
    });
};

exports.selectImageFromLibrary = function(originNode) {
    return new Promise(function(resolve) {
        __photoLibrary_showPhotoSelector(originNode, function(photo) {
            resolve(photo);
        });
    });
};