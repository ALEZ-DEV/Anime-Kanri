# Anime-Kanri

<p align="center">
    <img src="./docs/logo.svg" title="AnimeKanri" alt="AnimeKanri" width="450" height="390"/><br>
</p>

<div align="center">
    <h1>Anime Kanri</h1>
</div>

<p align="center">A anime library manager, tracker, downloader and viewer with intuitive UI design</p>

## !!! Warning : This project is still in development !!!

This project is still in development and a lot of features is missing or will be changed in the future
and not stable, any new version can break the app, use it at your own risk

But if you use it and something don't work as expected, don't hesitate to make an issue for it !

## Download

You can download the latest version in the [release](https://github.com/ALEZ-DEV/Anime-Kanri/releases) section

## Compile and Run the project

Start by cloning this project with

```bash
git clone https://github.com/ALEZ-DEV/Anime-Kanri.git
```

### Using Rust Inside Flutter

This project leverages Flutter for GUI and Rust for the backend logic,
utilizing the capabilities of the
[Rinf](https://pub.dev/packages/rinf) framework.

To run and build this app, you need to have
[Flutter SDK](https://docs.flutter.dev/get-started/install),
[Rust toolchain](https://www.rust-lang.org/tools/install),
and [Protobuf compiler](https://grpc.io/docs/protoc-installation)
installed on your system.
You can check that your system is ready with the commands below.
Note that all the Flutter subcomponents should be installed.

```bash
rustc --version
protoc --version
flutter doctor
```

You also need to have the CLI tool for Rinf ready.

```bash
cargo install rinf
```

Messages sent between Dart and Rust are implemented using Protobuf.
If you have newly cloned the project repository
or made changes to the `.proto` files in the `./messages` directory,
run the following command:

```bash
rinf message
```

Now you can run and build this app just like any other Flutter projects.

```bash
flutter run
```

For detailed instructions on writing Rust and Flutter together,
please refer to Rinf's [documentation](https://rinf-docs.cunarist.com).

### Project Based on these library

- UI Part
  - [Flutter 3.13.9](https://flutter.dev/)
- Backend
  - [Rinf](https://github.com/cunarist/rinf)
- Library used in app
  - [Nyaa-rsearch](https://github.com/ALEZ-DEV/Nyaa-rsearch)
  - [Librqbit](https://github.com/ikatson/rqbit)

### TODO

- [ ] Torrent Downloader
  - [ ] Search section
    - [X] can search Torrent from nyaa.si
    - [ ] Torrent name parser
    - [ ] some preview of the Torrent
    - [ ] add configurable setting
  - [ ] Download section
    - [X] can Download Torrent file
    - [ ] sort downloaded file
- [ ] Give 13 CHF to M3gaprod
- [ ] Video Player (mpv) 
  - [ ] ...
  
