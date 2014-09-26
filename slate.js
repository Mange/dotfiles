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

var right = S.op("push", {direction: "right", style: "bar-resize:screenSizeX/2"});
var rightPrimary = right.dup({screen: monitorPrimary});

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

// Two screen layout
var twoScreenLayout = S.layout("two screens", {
  "_before_": {operations: [showFlowdock]},
  "MacVim": {operations: [leftPrimary, rightPrimary], repeat: true},
  "iTerm": {operations: [rightPrimary], repeat: true},
  "Flowdock": {operations: [fullscreenSecondary]}
});

S.default(1, singleScreenLayout);
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
S.bind(hyperKey("space"), function() {
  var layoutName;
  if (S.screenCount() == 1) {
    layoutName = singleScreenLayout;
  } else {
    layoutName = twoScreenLayout;
  }
  S.op("layout", {name: layoutName}).run();
});
