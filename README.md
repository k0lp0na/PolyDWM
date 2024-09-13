
# SHOWCASE

![Alt text](/dwm/p1.webp)
![Alt text](/dwm/p2.webp)
![Alt text](/dwm/lock.webp)

# Used Software

+ **Window Manager** = Dynamic window manager
   - patched woth 23 patches. Has 9 Layouts and scratchpads

+ **Status Bar** = Polybar
  -  polybar-dwm-git from aur

+ **Compositor** = Picom

+ **Hotkey Daemon** = SXHKD

+ **Teminal** = Alacritty

+ **Shell** = Fish
   - with zoxide , fzf , lsd and oh-my-posh

+ **Launcher** = Rofi
  - with greenclip and rofi-emoji

+ **Notification** = Dunst

+ **File Browser**
  -  **TUI** = Kitty + yazi
  -  **GUI** = Nemo

+ **Fonts** = Jetbrains Mono Nerd Font and Noto Sans CJK

+ **Colors** = Mix of Tokyo night / Cappuccin

+ **Screenshot utility** = Maim with xclip

+ **CLI Tools** = fastfetch , htop

+ **Lock Screen** = Betterlockscreen

+ **Login Mananger** = SDDM
  -  with the tokyo night theme from aur


# Instalation

> Install Arch. also rememmber to install base-devel during installation

connect to the internet

```
nmcli device wifi connect !name! password !psswd!
```

install git and reflector

```
sudo pacman -S git reflector
```

fic mirrors

```
sudo reflector --country 'Bangladesh' --latest 10 --sort rate --save /etc/pacman.d/mirrorlist 
```

clone the repo and cd

```
git clone --depth 1 https://github.com/k0lp0na/DWM.git

cd DWM
```

fix pacman. uncomment colors and add

```
ILoveCandy
```

Now run the install script

```
sudo ./install.sh
```


 ***Done***


-----------------------------------------------------------------

### Post Things

Rebooted into DWM. Set a gtk/qt theme , wallpaper etc. setup power management and browsers. :) 

After all that the setup is now ready to go. Now maybe actually get some work done instead of configing .dotfiles. anyways enjoy!
