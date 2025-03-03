#!/bin/bash

mv ~/PolyDWM ~/DWM


# Error handling function
handle_error() {
    echo "An error occurred on line $1"
    exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Function to run commands as root if not already
ensure_root() {
    if [ "$(id -u)" -ne "0" ]; then
        echo "You need to run this script with sudo. Re-running the script with sudo now..."
        exec sudo "$0" "$@"
    fi
}

# Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Init paru
echo "Cloning paru repository..."
if ! git clone https://aur.archlinux.org/paru.git; then
    echo "Failed to clone paru repository"
    exit 1
fi

cd paru || exit
echo "Building and installing paru..."
makepkg -si --noconfirm
cd .. || exit

# Clean up paru directory
echo "Cleaning up paru directory..."
rm -rf paru


# Create symbolic links
echo "Creating symbolic links..."
ln -sf ~/DWM/dots/.dwm ~/
ln -sf ~/DWM/dots/alacritty ~/.config/
ln -sf ~/DWM/dots/dunst ~/.config/
ln -sf ~/DWM/dots/fish ~/.config/
ln -sf ~/DWM/dots/picom ~/.config/
ln -sf ~/DWM/dots/polybar ~/.config/
ln -sf ~/DWM/dots/rofi ~/.config/
ln -sf ~/DWM/dots/sxhkd ~/.config/
ln -sf ~/DWM/dots/fastfetch ~/.config/
ln -sf ~/DWM/dots/mpv ~/.config/
ln -sf ~/DWM/dots/omp ~/.config/
ln -sf ~/DWM/dots/kitty ~/.config/
ln -sf ~/DWM/dots/yazi ~/.config/
ln -sf ~/DWM/dots/nano ~/.config/

# Install packages using pacman
echo "Installing packages..."
sudo pacman -S --noconfirm alacritty rofi dunst picom sxhkd fish lsd fzf zoxide nitrogen firefox xorg xorg-xsetroot nemo maim xclip vulkan-intel fastfetch ttf-jetbrains-mono-nerd lxappearance qt5ct qt6ct mpv xed qbittorrent playerctl pacman-contrib noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra rofi-emoji vlc pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber polkit-gnome xfce4-power-manager kitty yazi htop spotify-launcher

# Install AUR packages using paru
echo "Installing AUR packages..."
paru -S --noconfirm polybar-dwm-git pfetch-rs-bin betterlockscreen rofi-greenclip brave-bin vesktop-bin

# Build and install DWM
echo "Building and installing DWM..."
cd dwm || exit
sudo make clean install
rm -f drw.o dwm.o dwm-msg.o util.o config.h
cd .. || exit

# Create screenshots directory
echo "Creating screenshots directory..."
mkdir -p ~/Pictures/ss

# Enable audio services
echo "Enabling audio services..."
systemctl --user --now enable pipewire pipewire-pulse wireplumber

# Change default shell to fish
echo "Changing default shell to fish..."
chsh -s "$(which fish)"

# Remove unnecessary packages
echo "Removing VLC and i3-wm..."
sudo pacman -R --noconfirm vlc i3-wm

# Install and enable SDDM
echo "Installing and enabling SDDM..."
sudo pacman -S --noconfirm sddm
sudo systemctl enable sddm

# create the .desktop file

# Define the directory and file path
XSESSION_DIR="/usr/share/xsessions"
DESKTOP_FILE="$XSESSION_DIR/dwm.desktop"

# Create the directory if it does not exist
mkdir -p "$XSESSION_DIR"

# Create or overwrite the .desktop file with the specified contents
cat <<EOF | sudo tee "$DESKTOP_FILE" > /dev/null
[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF

# Fix touchpad configuration
echo "Configuring touchpad settings..."
CONFIG_FILE="/etc/X11/xorg.conf.d/40-libinput.conf"
CONFIG_CONTENT='Section "InputClass"
 Identifier "libinput touchpad"
 Driver "libinput"
 MatchIsTouchpad "on"
 Option "Tapping" "on"
 Option "NaturalScrolling" "on"
EndSection'

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating $CONFIG_FILE"
fi

echo "$CONFIG_CONTENT" | sudo tee -a "$CONFIG_FILE" > /dev/null
echo "Touchpad configuration added successfully."

# Fix polybar brightness
echo "Configuring backlight permissions..."
ensure_root
RULES_FILE="/etc/udev/rules.d/90-backlight.rules"
echo 'SUBSYSTEM=="backlight", RUN+="/usr/bin/chgrp video /sys/class/backlight/intel_backlight/brightness"' > "$RULES_FILE"
echo 'SUBSYSTEM=="backlight", RUN+="/usr/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"' >> "$RULES_FILE"
udevadm control --reload-rules
udevadm trigger

echo "The udev rules have been added and reloaded successfully."

# Fix QT environment variable
echo "Setting QT_QPA_PLATFORMTHEME..."
ensure_root
ENV_FILE="/etc/environment"
if grep -q "^QT_QPA_PLATFORMTHEME=" "$ENV_FILE"; then
    echo "The variable QT_QPA_PLATFORMTHEME is already set in $ENV_FILE."
else
    echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a "$ENV_FILE"
    echo "The variable QT_QPA_PLATFORMTHEME has been added to $ENV_FILE."
fi

# Fix Java environment variable
echo "Setting Java environment variable..."
ensure_root
PROFILE_FILE="/etc/profile"
if grep -q "^export _JAVA_AWT_WM_NONREPARENTING=" "$PROFILE_FILE"; then
    echo "The variable _JAVA_AWT_WM_NONREPARENTING is already set in $PROFILE_FILE."
else
    echo 'export _JAVA_AWT_WM_NONREPARENTING=1' | sudo tee -a "$PROFILE_FILE"
    echo "The variable _JAVA_AWT_WM_NONREPARENTING has been added to $PROFILE_FILE."
fi



# sddm theme
CONF_FILE="/etc/sddm.conf"

# Check if the file exists
if [ ! -f "$CONF_FILE" ]; then
  echo "Configuration file $CONF_FILE does not exist. Creating it."
  touch "$CONF_FILE"
fi

# Check if the [Theme] section already exists
if grep -q '^\[Theme\]' "$CONF_FILE"; then
  # [Theme] section exists, append or update the Current line
  if grep -q '^Current=' "$CONF_FILE"; then
    echo "Updating existing Current line in [Theme] section."
    sed -i 's/^Current=.*/Current=tk/' "$CONF_FILE"
  else
    echo "Appending Current=tk to existing [Theme] section."
    sed -i '/^\[Theme\]/a Current=tk' "$CONF_FILE"
  fi
else
  # [Theme] section does not exist, create it
  echo "Creating [Theme] section and adding Current=tk."
  echo -e "\n[Theme]\nCurrent=tk" >> "$CONF_FILE"
fi

echo "Configuration updated successfully."

# themes stuff

sudo cp -rp ~/DWM/themes/GTK/* /usr/share/themes/
sudo cp -rp ~/DWM/themes/icon/* /usr/share/icons/
sudo cp -rp ~/DWM/themes/sddm/* /usr/share/sddm/themes/

mkdir -p ~/.config/qt5ct/colors
mkdir -p ~/.config/qt6ct/colors

sudo cp -rp ~/DWM/themes/QT/* ~/.config/qt5ct/colors/
sudo cp -rp ~/DWM/themes/QT/* ~/.config/qt6ct/colors/

# Setup Python virtual environment
echo "Setting up Python virtual environment..."
sudo pacman -S --noconfirm python-pip
python -m venv ~/myenv
source ~/myenv/bin/activate
pip install anipy-cli



# done

echo "                                                                                                             
                                      .                                                                       
                                                                                                              
                                                                                                              
                                                                                                              
                                                                                                  .      .    
                                                                                                              
                            @@@@@                .                                    .                 .     
                         @@@      @                                                                           
                        @@@       @                    @@@                                                    
   ..      @            @@ . @@@@@                     @@     .                     .              @          
             @          @@                                        @@@      M@      >@           M             
          .             @@~                                    @@@@        @@@     @@                         
                       @@@@@@@         @@X@   @        @@    @@@@   @  @  M@@@     @@  .  C                   
                     @@@              @@@     @@      @@@    @@@     @@@Z@@@@@    @@@    @                    
                    @@@@             @@@@    @@@     @@@@   /@@@ .    Q  @@@@     @@@   @                     
        @@@@@       @@@              @@@     @@      @@@     @@@     @   @@@@    @@@@  @          @@@@@       
                   @@@@             @@@@    @@@     @@@@   }@@@@    @     @@@@  @@@@@@)            .          
  .                 @@@@          @@@@@     @@@   @@@a@  @@   @@@@@@         ].  @@@         .                
                    @@@@@      @@@  @@@      d@@@@  @@@@@                      @@@@@                  .       
                      @@@@@@@@@                    @@@@                     @@   @@@                 .        
           @                                   @@  @@@                    @     @@@               @-          
                                            @@     @$@                  @       @@@                           
     .                                    @       @@@@                 @        @@@                           
                                        @-     .  @@@                 j         @@@                           
                     .                 @         @@@~                @         @@@                            
                                       @        @@@^                 @         @@@                            
                                       @       @@@                   @        @@@                   .         
                                        @@@@@@@@                      @@     @@@                              
                                                                        @@@@@:                        .       
                                                                                                              
                                                                            .                                 
                         .                                                     .                              
                                                            .                                                 
                            .                                 .                                            .  
                                                                                                              
                                    .                                                                        " 

sleep 0.5

echo "  reboot and enjoy 
"

