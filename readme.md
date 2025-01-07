### gmanka flatpaks builds

this repo has github workflow, that builds and deploys flatpaks

### add repo

```shell
sudo flatpak remote-add gmanka https://gmanka-flatpaks.github.io/gmanka.flatpakrepo
```

### list available apps

```shell
flatpak remote-ls gmanka
```

### install adobe photoshop 2021

```shell
flatpak install gmanka com.adobe.photoshop2021
```

### install neovide

```shell
flatpak install gmanka dev.neovide.neovide
```

### manifests

- https://github.com/gmanka-flatpaks/com.adobe.photoshop2021
- https://github.com/gmanka-flatpaks/dev.neovide.neovide

