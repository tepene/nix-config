# My NixOS Configuration

This is NixOS/home-manager configuration. Requires [Nix flakes](https://nixos.wiki/wiki/Flakes).

TODO: Add highlights...

## Usage

### Installation on new system

NixOS can be installed on a new system with these instructions:

1. Boot with minimal ISO
2. Change to root  
   `sudo -i`
3. Change keyboard layout to your liking  
   `loadkeys de_CH-latin1`
4. Install git  
   `nix-shell -p git`
5. Clone NixOS configuration repository  
   `git clone https://github.com/tepene/nix-config.git`
6. Run setup script  
   `cd ./nix-config && ./setup.sh`
7. Reboot system  
   `reboot`

### After installation

Once NixOS is running the final configurations can be applied with these instructions:

1. Clone NixOS configuration repository  
   `git clone https://github.com/tepene/nix-config.git`
2. Apply system configuration  
   `sudo nixos-rebuild switch --flake .#hostname`
3. Apply home configuration  
   `home-manager switch --flake .#username@hostname`
4. Reboot system  
   `reboot`

## Credits

My NixOS configuration is based on and greatly inspired by:

- [Nix Starter Config](https://github.com/Misterio77/nix-starter-configs)
- [misterio77/nix-config](https://github.com/misterio77/nix-config)
- [Encypted Btrfs Root with Opt-in State on NixOS](https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html)
