#Wiimote Overlay


## Building
This is an xcode project, so fire up xcode, hit build :D

### Build vendor dependencies (this is just for my own sanity, libwiiuse.dylib should already be built)
To build the `wiiuse` dependency you'll need to install CMake.

Once installed, enter `vendor/wiiuse-master`, run `cmake .`, run `make wiiuse`
