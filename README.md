# My NixOS Configuration

## Installation

1. Boot with minimal ISO
2. Change to root  
   `sudo -i`
3. Change keyboard layout  
   `loadkeys de_CH-latin1`
4. Install git  
   `nix-shell -p git`
5. Clone NixOS configuration repository  
   `git clone https://github.com/tepene/nix-config.git`
6. Run setup script  
   `./setup.sh`
