// importing
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import Mpris from "resource:///com/github/Aylur/ags/service/mpris.js";
import Audio from "resource:///com/github/Aylur/ags/service/audio.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";
import SystemTray from "resource:///com/github/Aylur/ags/service/systemtray.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import { execAsync } from "resource:///com/github/Aylur/ags/utils.js";

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, just make it a function
// then you can use it by calling simply calling it

const Workspaces = () =>
  Widget.Box({
    className: "workspaces",
    connections: [
      [
        Hyprland.active.workspace,
        (self) => {
          // generate an array [1..10] then make buttons from the index
          const arr = Array.from({ length: 10 }, (_, i) => i + 1);
          self.children = arr.map((i) =>
            Widget.Button({
              onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`),
              child: Widget.Label(`${i}`),
              className: Hyprland.active.workspace.id == i ? "focused" : "",
            }),
          );
        },
      ],
    ],
  });

const ClientTitle = () =>
  Widget.Label({
    className: "client-title",
    binds: [["label", Hyprland.active.client, "title"]],
  });

const Clock = () =>
  Widget.Label({
    className: "clock",
    connections: [
      // this is bad practice, since exec() will block the main event loop
      // in the case of a simple date its not really a problem
      // [1000, (self) => (self.label = exec('date "+%H:%M:%S %b %e."'))],

      // this is what you should do
      [
        1000,
        (self) =>
          execAsync(["date", "+%H:%M:%S %b %e."])
            .then((/** @type {string} */ date) => (self.label = date))
            .catch(console.error),
      ],
    ],
  });

const Media = () =>
  Widget.Button({
    className: "media",
    onPrimaryClick: () => Mpris.getPlayer("")?.playPause(),
    onScrollUp: () => Mpris.getPlayer("")?.next(),
    onScrollDown: () => Mpris.getPlayer("")?.previous(),
    child: Widget.Label({
      connections: [
        [
          Mpris,
          (self) => {
            const mpris = Mpris.getPlayer("");
            // mpris player can be undefined
            if (mpris)
              self.label = `${mpris.trackArtists.join(", ")} - ${
                mpris.trackTitle
              }`;
            else self.label = "Nothing is playing";
          },
        ],
      ],
    }),
  });

const Volume = () =>
  Widget.Box({
    className: "volume",
    css: "min-width: 180px",
    children: [
      Widget.Stack({
        items: [
          // tuples of [string, Widget]
          ["101", Widget.Icon("audio-volume-overamplified-symbolic")],
          ["67", Widget.Icon("audio-volume-high-symbolic")],
          ["34", Widget.Icon("audio-volume-medium-symbolic")],
          ["1", Widget.Icon("audio-volume-low-symbolic")],
          ["0", Widget.Icon("audio-volume-muted-symbolic")],
        ],
        connections: [
          [
            Audio,
            (self) => {
              if (!Audio.speaker) return;

              if (Audio.speaker.isMuted) {
                self.shown = "0";
                return;
              }

              const show = [101, 67, 34, 1, 0].find(
                (threshold) => threshold <= Audio.speaker.volume * 100,
              );

              self.shown = `${show}`;
            },
            "speaker-changed",
          ],
        ],
      }),
      Widget.Slider({
        hexpand: true,
        drawValue: false,
        onChange: ({ value }) => (Audio.speaker.volume = value),
        connections: [
          [
            Audio,
            (self) => {
              self.value = Audio.speaker?.volume || 0;
            },
            "speaker-changed",
          ],
        ],
      }),
    ],
  });

const BatteryLabel = () =>
  Widget.Box({
    className: "battery",
    children: [
      Widget.Icon({
        connections: [
          [
            Battery,
            (self) => {
              self.icon = `battery-level-${
                Math.floor(Battery.percent / 10) * 10
              }-symbolic`;
            },
          ],
        ],
      }),
      Widget.ProgressBar({
        vpack: "center",
        connections: [
          [
            Battery,
            (self) => {
              if (Battery.percent < 0) return;

              self.fraction = Battery.percent / 100;
            },
          ],
        ],
      }),
    ],
  });

const SysTray = () =>
  Widget.Box({
    connections: [
      [
        SystemTray,
        (self) => {
          self.children = SystemTray.items.map((item) =>
            Widget.Button({
              child: Widget.Icon({ binds: [["icon", item, "icon"]] }),
              onPrimaryClick: (_, event) => item.activate(event),
              onSecondaryClick: (_, event) => item.openMenu(event),
              binds: [["tooltip-markup", item, "tooltip-markup"]],
            }),
          );
        },
      ],
    ],
  });

// layout of the bar
const Left = () =>
  Widget.Box({
    children: [Workspaces(), Media()],
  });

const Center = () =>
  Widget.Box({
    children: [ClientTitle()],
  });

const Right = () =>
  Widget.Box({
    hpack: "end",
    children: [Volume(), BatteryLabel(), Clock(), SysTray()],
  });

const Bar = ({ monitor = 0 } = {}) =>
  Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    className: "bar",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      startWidget: Left(),
      centerWidget: Center(),
      endWidget: Right(),
    }),
  });

Bar.remove = (monitor) => {
  const removeName = `bar-${monitor}`;
  for (const [name, _] of ags.App.windows) {
    if (name == removeName) ags.App.removeWindow(name);
  }
};

// Automatically create and destroy bars as monitors connect and disconnect.
const display = imports.gi.Gdk.Display.get_default();
display.connect("monitor-added", (_, monitor) => {
  console.log("monitor added", monitor);
  ags.App.addWindow(Bar({ monitor }));
});
display.connect("monitor-removed", (_, monitor) => {
  Bar.remove(monitor);
});

const monitorCount = display.get_n_monitors();

// exporting the config so ags can manage the windows
export default {
  style: App.configDir + "/style.css",
  windows: [
    ...Array.from({ length: monitorCount }, (_, i) => Bar({ monitor: i })),
  ],
};