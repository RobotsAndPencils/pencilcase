// These two functions are deprecated and remain for backwards compatibility
// Creation.currentCard().objectWithUUID and Creation.currentCard().objectNamed should be used in their place
exports.nodeWithUUID = __app_nodeWithUUID;
exports.nodeNamed = __app_nodeNamed;
exports.currentCard = __app_currentCard;
exports.openExternalLink = __app_openExternalLink;

exports.goToNextCard = function(transitionType, transitionDuration) {
    return new Promise(function(resolve, reject) {
        __app_goToNextCard(transitionType, transitionDuration, resolve);
    });
};

exports.goToPreviousCard = function(transitionType, transitionDuration) {
    return new Promise(function(resolve, reject) {
        __app_goToPreviousCard(transitionType, transitionDuration, resolve);
    });
};

exports.goToFirstCard = function(transitionType, transitionDuration) {
    return new Promise(function(resolve, reject) {
        __app_goToFirstCard(transitionType, transitionDuration, resolve);
    });
};

exports.goToLastCard = function(transitionType, transitionDuration) {
    return new Promise(function(resolve, reject) {
        __app_goToLastCard(transitionType, transitionDuration, resolve);
    });
};

exports.goToCard = function(cardUUID, transitionType, transitionDuration) {
    return new Promise(function(resolve, reject) {
        __app_goToCard(cardUUID, transitionType, transitionDuration, resolve);
    });
};

exports.goToCardAtIndex = function(cardIndex, transitionType, transitionDuration) {
    return new Promise(function(resolve, reject) {
        __app_goToCardAtIndex(cardIndex, transitionType, transitionDuration, resolve);
    });
};

// Deprecated in favour of the timeline methods on Card
exports.playTimelineWithName = function(timelineName) {
    return new Promise(function(resolve) {
        __app_playTimelineWithName(timelineName, resolve);
    });
};

// Deprecated in favour of the timeline methods on Card
exports.stopTimelineWithName = __app_stopTimelineWithName;

/*
 * @param {string} objectType The name of the object type to be created.
 * @returns {Object} The object that was created, or null if the objectType isn't valid.
 */
exports.createObject = function(objectType) {
    var isString = typeof objectType === 'string';
    if (!isString || objectType.length === 0) return null;

    var newObject = new Global[objectType];
    newObject.uuid = UUID.uuid();
    __app_addObjectToCard(newObject);

    return newObject;
};

/*
 * @param {String} template The template name used when creating the particles
 */
exports.createParticlesFromTemplate = function(templateName) {
    var newParticles = BaseObject.createFromTemplateNamed(templateName, 'PCParticleSystem');
    __app_addObjectToCard(newParticles);

    return newParticles;
}

/*
 * @param {Texture} texture  The image the user selected
 */
exports.createImageView = function(texture) {
    var newImage = exports.createObject("ImageView");
    newImage.spriteFrame = texture;
    return newImage;
}

/*
 * @param {String} customEventName  The name of the custom event to be stored in the NSNotification's userInfo
 */
exports.postNativeNotification = function(customEventName) {
    __app_postNativeNotification(customEventName)
}

//
// REPL control
//

exports.showREPL = __app_showREPL;
exports.hideREPL = __app_hideREPL;

Object.defineProperty(exports, "enableDefaultREPLGesture", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getEnableDefaultREPLGesture();
    },
    set: function (enabled) {
        __app_setEnableDefaultREPLGesture(enabled);
    }
});

//
// SKView debugging properties
//

Object.defineProperty(exports, "showFPS", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getShowFPS();
    },
    set: function (enabled) {
        __app_setShowFPS(enabled);
    }
});

Object.defineProperty(exports, "showNodeCount", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getShowNodeCount();
    },
    set: function (enabled) {
        __app_setShowNodeCount(enabled);
    }
});

Object.defineProperty(exports, "showQuadCount", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getShowQuadCount();
    },
    set: function (enabled) {
        __app_setShowQuadCount(enabled);
    }
});

Object.defineProperty(exports, "showDrawCount", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getShowDrawCount();
    },
    set: function (enabled) {
        __app_setShowDrawCount(enabled);
    }
});

Object.defineProperty(exports, "showPhysicsBorders", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getShowPhysicsBorders();
    },
    set: function (enabled) {
        __app_setShowPhysicsBorders(enabled);
    }
});

Object.defineProperty(exports, "showPhysicsFields", {
    enumerable: true,
    configurable: false,
    get: function () {
        return __app_getShowPhysicsFields();
    },
    set: function (enabled) {
        __app_setShowPhysicsFields(enabled);
    }
});
