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

// Push window in a direction and style, cycling between the monitors
var pushWindow = function(direction, style) {
  return S.op("chain", {operations: [
    S.op("push", {direction: direction, style: style, screen: monitorPrimary}),
    S.op("push", {direction: direction, style: style, screen: monitorSecondary})
  ]});
};

S.bind(hyperKey("left"), pushWindow("left", "bar-resize:screenSizeX/2"));
S.bind(hyperKey("right"), pushWindow("right", "bar-resize:screenSizeX/2"));

S.bind(hyperKey("up"), pushWindow("up", "bar-resize:screenSizeY/2"));
S.bind(hyperKey("down"), pushWindow("down", "bar-resize:screenSizeY/2"));

S.bind(hyperKey("return"), S.op("chain", {operations: [
  S.op("corner", {direction: "top-left", height: "screenSizeY", width: "screenSizeX", screen: monitorPrimary}),
  S.op("corner", {direction: "top-left", height: "screenSizeY", width: "screenSizeX", screen: monitorSecondary})
]}));

// Misc
S.bind(hyperKey("r"), S.op("relaunch"));

S.bind(hyperKey("space"), S.op("hint", {characters: "JKLN1234567890"}));
