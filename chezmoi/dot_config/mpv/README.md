# MPV Configuration

## Windows Installation

1. Download the latest version from [SourceForge](https://sourceforge.net/projects/mpv-player-windows/files/).
2. Extract the zip file.
3. Place the extracted folder in `C:\Program Files\mpv`.
4. Add the mpv.exe path to system environment variables.
5. Run `mpv_install.bat` as Administrator to associate all video file extensions with mpv.

### Configuration paths (Windows)

- **Binaries:** `C:\Program Files\mpv`
- **Config:** `%APPDATA%/mpv` (`mpv.conf`, `input.conf`, `scripts/`, `script-opts/`)

---

## Linux Configuration

Config files are stored in `~/.config/mpv/` (managed by chezmoi).

---

## Included Scripts

| Script | Key | Description |
|---|---|---|
| [chapterskip.lua](https://github.com/po5/chapterskip) | Auto | Skips anime OP/ED chapters |
| [playlistmanager.lua](https://github.com/jonniek/mpv-playlistmanager) | `F2` | Interactive playlist |
| [webm.lua](https://github.com/ekisu/mpv-webm) | `F1` | Create WebM clips |
| [thumbfast.lua](https://github.com/po5/thumbfast) | Auto | Thumbnail generator |
| [skip-intro](https://github.com/rui-ddc/skip-intro) | `S` | Skip opening sequence |
| [mpv-persist-properties](https://github.com/d87/mpv-persist-properties) | Auto | Persist volume across sessions |
| [mpv-anilist-updater](https://github.com/AzuredBlue/mpv-anilist-updater) | Auto | Update AniList on watch |
| [SmartCopyPaste](https://github.com/Eisa01/mpv-scripts) | Auto | Smart copy/paste |
| [memo](https://github.com/po5/memo) | Auto | Watch history menu |

---

## Subtitle Font (SubsPlease)

**Font:** Roboto Medium (Version 2.138)

```ini
sub-ass-override=force
sub-font=Roboto Medium
sub-font-size=52
sub-border-size=2.6
sub-color="#FFFFFFFF"
sub-border-color="#FF000000"
sub-margin-y=46
sub-margin-x=40
sub-blur=0
sub-use-margins=no
```

Extract ASS subtitles:
```bash
ffmpeg -i inputfile.mkv -map 0:s:0 outputfile.ass
```

---

## Keybinds

| Key | Action |
|---|---|
| `,` | Seek 1 frame backward |
| `.` | Seek 1 frame forward |
| `S` | Skip forward 90s (opening skip) |
| `R` | Seek backward 90s |
| `→` | Seek forward 2s |
| `←` | Seek backward 2s |
| `↑` | Increase volume |
| `↓` | Decrease volume |
| `M` | Mute |
| `C` | Cycle subtitles |
| `N` | Next episode |
| `B` | Previous episode |
| `F` | Toggle fullscreen |
| `P` | Toggle PiP |
| `I` | Show video stats |
| `X` | Screenshot to clipboard |
| `[` | Increase speed |
| `]` | Decrease speed |
| `\` | Reset speed to 1x |
| `` ` `` | Open keybinds UI |

---

## Sources

- https://github.com/itsmeipg/mpv-config/
- https://github.com/Sharad104/mpv-config
- https://github.com/Zabooby/mpv-config/
- https://github.com/Donate684/mpv-anime
- https://github.com/tuilakhanh/mpv-config/
