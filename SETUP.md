# Here is my experience installing Arch Linux on my daily driver

## Arch install...

I just followed this video and installed Hyprland

[How to Install Arch Linux (YouTube)](https://www.youtube.com/watch?v=LiG2wMkcrFE)

I have an RTX 4070 Ti as my graphics card and I installed the NVIDIA proprietary drivers.

For audio, I selected PipeWire.

## Initial setup

### Secondary drive formatting

I formatted the secondary drive to ext4 for better Steam compatibility.

Here is step by step how to format and mount drive:

#### Step 1: Identify the new drive

```bash
  lsblk
```

Look for the drive that is approximately the right size. Or select a drive that doesn't have /boot inside.

#### Step 2: Create a partition using `cfdisk`

Follow these steps to create a new partition on your drive:

1. **Open cfdisk**  
   Replace `/dev/sdX` with your actual drive (e.g., `/dev/sdb`):

```bash
sudo cfdisk /dev/sdX
```

2. **Select Label Type**  
   If prompted, choose `gpt` for modern systems or `dos` for older systems.

3. **Delete Existing Partitions (Optional)**  
   Use the arrow keys to select any existing partitions you want to remove, then choose `Delete`.

4. **Create New Partition**

   - Select the `Free space` entry.
   - Choose `New` and press ENTER.
   - Enter the desired partition size or press ENTER to use the default (entire space).
   - Choose the partition type (usually `primary`).

5. **Write Changes**

   - Select `Write` and press ENTER.
   - Type `yes` to confirm.

6. **Quit cfdisk**
   - Select `Quit` to exit the tool.

Your new partition is now created and ready for formatting.

#### Step 3: Format the partition to ext4

```bash
sudo mkfs.ext4 /dev/sdX
```

#### Step 4: Mount the drive

Create a directory where you want this drive to live (e.g., /mnt/data or /home/youruser/storage).

```bash
sudo mkdir -p /mnt/data
sudo mount /dev/sdX /mnt/data
```

#### Step 5: Configure auto-mount on boot

To make sure the drive mounts automatically after a restart, you need to add it to your /etc/fstab file.

1. **Get the UUID** of the new partition (it's safer than using device names like /dev/sdX which can change):

```bash
sudo blkid /dev/sdX
```

2. **Edit fstab**:

```bash
sudo nano /etc/fstab
```

3. **Add a new line** at the bottom:

```bash
UUID=your-uuid-here  /mnt/data  ext4  defaults  0  2
```

- Replace your-uuid-here with the UUID you copied.
- Replace /mnt/data with your mount point.

4. **Save and Exit:** Press Ctrl+O, Enter, then Ctrl+X.

#### Step 6: Verify

Unmount and remount all filesystems to verify your configuration is correct without rebooting:

```bash
sudo mount -a
```

If you don't get any errors, you are good to go!

#### Step 7: Fix Permissions (Optional)

By default, the new drive will be owned by root. If you want your standard user to write to it:

```bash
sudo chown -R $USER:$USER /mnt/data
```

- Replace /mnt/data with your mount point.

#### Step 8: Removing Reserved Blocks from drive

By default, ext4 reserves 5% of the total disk space for the root user. Because it's a secondary drive, it's not needed.

Also, be cautious: it needs to be run on the partition and not the drive.

**How to reclaim it:**

```bash
sudo tune2fs -m 0 /dev/sdX
```

-m 0 tells the filesystem to reserve 0% of the blocks.

### Yay

This is from the GitHub README for yay:

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

I also deleted the cloned folder after installation with:

```bash
rm -rf ./yay
```

## Third-party apps

### Openrazer

My setup includes Razer peripherals, so it's a must-have.

#### Install openrazer-meta:

```bash
yay -S openrazer-meta
```

#### Add your user to the openrazer group:

```bash
sudo gpasswd -a $USER openrazer
```

#### Install a graphical frontend (optional but recommended):

```bash
yay -S polychromatic
```

### playerctl

For music shortcuts, Hyprland requires `playerctl`.

#### Install playerctl:

```bash
sudo pacman -S playerctl
```

### Set up playerctld daemon

This enables automatic selection of the last active media source for control.

#### Create a playerctld service

1. **Create a systemd user service file:**

```bash
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/playerctld.service
```

2. **Paste the following into the file:**

```ini
[Unit]
Description=playerctld daemon

[Service]
ExecStart=/usr/bin/playerctld

[Install]
WantedBy=default.target
```

3. **Enable and start the service:**

```bash
systemctl --user enable --now playerctld.service
```

Now, `playerctld` will run in the background and manage media player focus automatically.

## Hyprland ricing

To run my config, your system should include the following:

**Required**

- (pacman) hyprpaper
- (pacman) cliphist
- (pacman) playerctl

**Good to have**

- (yay) zen-browser-bin
- (pacman) steam
- (pacman) spotify-installer
- (yay) openrazer-meta & polychromatic

---

### Setting up dotfiles

1. **Clone this repository:**

```bash
git clone https://github.com/OctupusPrime/desktop-arch-ricing.git dotfiles
```

2. **Enter the dotfiles directory:**

```bash
cd dotfiles
```

3. **Symlink the configs using GNU Stow:**

```bash
stow */
```

Feel free to modify files in /dotfiles to change keybindings, etc...
