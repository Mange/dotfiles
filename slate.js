// Configs
S.cfga({
  "defaultToCurrentScreen": true,
  "secondsBetweenRepeat": 0.1,
  "checkDefaultsOnLoad": true,
  "focusCheckWidthMax": 3000,
  "orderScreensLeftToRight": true,

  "windowHintsDuration": 5,
  "windowHintsShowIcons": true,

  "windowHintsIgnoreHiddenWindows": false,
  "windowHintsSpread": true
});

// Monitors
var monitorPrimary = "0";
var monitorSecondary = "1";

// Actions
var left = S.op("push", {direction: "left", style: "bar-resize:screenSizeX/2"});
var leftPrimary = left.dup({screen: monitorPrimary});
var leftSecondary = left.dup({screen: monitorSecondary});

var right = S.op("push", {direction: "right", style: "bar-resize:screenSizeX/2"});
var rightPrimary = right.dup({screen: monitorPrimary});
var rightSecondary = right.dup({screen: monitorSecondary});

var up = S.op("push", {direction: "up", style: "bar-resize:screenSizeY/2"});
var down = S.op("push", {direction: "down", style: "bar-resize:screenSizeY/2"});

var fullscreen = S.op("corner", {direction: "top-left", height: "screenSizeY", width: "screenSizeX"});
var fullscreenSecondary = fullscreen.dup({screen: monitorSecondary});

var hide = S.op("hide");
var show = S.op("show");

var fullscreenFlowdock = fullscreen.dup({app: "Flowdock"});
var hideFlowdock = hide.dup({app: "Flowdock"});
var showFlowdock = show.dup({app: "Flowdock"});

var bothScreens = function(op) {
  var ops = [];
  S.eachScreen(function(screen) {
    ops.push(op.dup({screen: screen}));
  });
  return S.op("chain", {operations: ops});
};

// Layouts //

// Single screen layout
var singleScreenLayout = S.layout("single screen", {
  "_before_": {operations: [fullscreenFlowdock, hideFlowdock]},
  "MacVim": {operations: [left, right], repeat: true},
  "iTerm": {operations: [right], repeat: true}
});

// Two screen layout (1 big, 1 smaller)
var twoScreenLayout = S.layout("two screens", {
  "_before_": {operations: [showFlowdock]},
  "MacVim": {operations: [leftPrimary, rightPrimary], repeat: true},
  "iTerm": {operations: [rightPrimary, leftPrimary, rightSecondary], repeat: true},
  "Flowdock": {operations: [fullscreenSecondary]}
});

// Two big-screen layout
var twoBigLayout = S.layout("two big screens", {
  "_before_": {operations: [showFlowdock]},
  "MacVim": {operations: [leftPrimary, rightPrimary], repeat: true},
  "Google Chrome": {operations: [rightPrimary, leftSecondary, rightSecondary], repeat: true},
  "iTerm": {operations: [leftSecondary, rightPrimary, rightSecondary], repeat: true},
  "Flowdock": {operations: [rightSecondary]}
});

bigScreenResolutions = ["2560x1440", "2560x1440"];
S.default(1, singleScreenLayout);
S.default(bigScreenResolutions, twoBigLayout);
S.default(2, twoScreenLayout);

// Binds //

var hyperKey = function(keyName) {
  return keyName + ":ctrl;shift;alt;cmd";
};

// Focus
S.bind(hyperKey("h"), S.op("focus", {direction: "left"}), true);
S.bind(hyperKey("j"), S.op("focus", {direction: "down"}), true);
S.bind(hyperKey("k"), S.op("focus", {direction: "up"}), true);
S.bind(hyperKey("l"), S.op("focus", {direction: "right"}), true);

S.bind(hyperKey(";"), S.op("focus", {app: "iTerm"}), false);
S.bind(hyperKey("c"), S.op("focus", {app: "iTerm"}), false);

S.bind(hyperKey("i"), S.op("focus", {app: "MacVim"}), false);
S.bind(hyperKey("n"), S.op("focus", {app: "Google Chrome"}), false);
S.bind(hyperKey("'"), S.op("focus", {app: "Flowdock"}), false);
S.bind(hyperKey("u"), S.op("focus", {app: "Dash"}), false);

// Move + Resize

S.bind(hyperKey("left"), bothScreens(left));
S.bind(hyperKey("right"), bothScreens(right));
S.bind(hyperKey("up"), bothScreens(up));
S.bind(hyperKey("down"), bothScreens(down));

S.bind(hyperKey("return"), bothScreens(fullscreen));

// Misc
S.bind(hyperKey("r"), S.op("relaunch"));

S.bind(hyperKey("f"), S.op("hint", {characters: "JKLN1234567890"}));

// Reapply layout
var currentResolutions = function() {
  var resolutions = [];
  S.eachScreen(function(s) {
    var rect = s.rect();
    resolutions.push(rect.width + "x" + rect.height);
  });
  return resolutions;
};
var arraysEqual = function(a, b) {
  if (a.length !== b.length) { return false; }
  for (var i = 0; i < a.length; ++i) {
    if (a[i] !== b[i]) { return false; }
  }
  return true;
}
var determineOptimalLayout = function(resolutions) {
  if (resolutions.length == 1) {
    return singleScreenLayout;
  } else if (resolutions.length == 2) {
    if (arraysEqual(resolutions, bigScreenResolutions)) {
      return twoBigLayout;
    } else {
      return twoScreenLayout;
    }
  }

  return null;
};
S.bind(hyperKey("space"), function() {
  var layoutName = determineOptimalLayout(currentResolutions());
  if (layoutName !== null) {
    S.op("layout", {name: layoutName}).run();
  }
});
