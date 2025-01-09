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

this command will list apps:

```shell
com.adobe.photoshop2021
com.adobe.photoshop2022
com.adobe.photoshop2023
dev.neovide.neovide
```

### install app

```shell
flatpak install gmanka APP
```

### manifests

- https://github.com/gmanka-flatpaks/com.adobe.photoshop2021
- https://github.com/gmanka-flatpaks/com.adobe.photoshop2022
- https://github.com/gmanka-flatpaks/com.adobe.photoshop2023
- https://github.com/flathub/dev.neovide.neovide

