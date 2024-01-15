# Neovim plugins

Ordered into three sets, loaded in this order:

1. `core` - The most important things that other layers build on top of, or
   things that belong to no other layer.
2. `ui` - Rich UI extensions that isn't "core", or requires things in `core` to
   be set up first.
3. `langs` - Language-specific plugins and configs.

Yes, this distinction is very arbitrary, but anything more specific than this
will just make it harder than it already is.
