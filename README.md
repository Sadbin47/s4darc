
# s4darc

s4darc is a minimal, interactive installer for Arch Linux. No compiling, no dependencies, no bloat—just pure shell scripts that guide you through a clean, safe, and fast installation, right from the official Live ISO.

<div align="center">
  <img src="https://github.com/user-attachments/assets/e93131d5-7b56-4b17-b37d-e2fcf037319b" width="700" />
</div>

---

## Why s4darc?

- **Zero Dependencies:** Runs on the vanilla Arch ISO—no extra tools needed.
- **Interactive:** Step-by-step TUI menus for every stage.
- **Safe:** Confirmation prompts before any destructive action.
- **UEFI & BIOS:** Full support for modern and legacy systems.
- **Minimal:** Installs only what you need for a clean base system.

---

## ⚡ Quick Start

**From the Arch Live ISO:**

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/Sadbin47/s4darc/main/s4darc.sh)
```

**Or clone and run locally:**

```sh
git clone https://github.com/Sadbin47/s4darc.git
cd s4darc
./s4darc.sh
```

---

## What Does It Do?

s4darc walks you through:


1. **Environment Check:** Detects if you’re on the Arch Live ISO, checks internet connectivity, and determines UEFI or BIOS mode.
2. **Disk Selection:** Lists all available disks and helps you select the correct one.
3. **Partitioning:** Interactive, guided partitioning for both UEFI and BIOS systems, with clear warnings before destructive actions.
4. **Filesystem Formatting:** Lets you choose and format filesystems (ext4, btrfs, xfs, etc.) for each partition.
5. **Mounting Partitions:** Automatically mounts root, boot/EFI, and home partitions as needed.
6. **Base System Installation:** Installs the minimal Arch base system using pacstrap.
7. **Fstab Generation:** Automatically generates and verifies your /etc/fstab.
8. **System Configuration:** Sets locale, timezone, hostname, and networking.
9. **User Setup:** Sets root password and creates a regular user with sudo privileges.
10. **Kernel Selection:** Lets you choose and install your preferred Linux kernel.
11. **Bootloader Installation:** Installs and configures GRUB or systemd-boot for your system type.
12. **Summary & Final Checks:** Shows a summary of your setup and allows you to review before finalizing.
13. **Finalize & Reboot:** Cleans up, unmounts, and reboots into your new Arch system.

---

## Example Walkthrough

1. **Run the script** from the Live ISO.
2. **Check environment** (Live ISO, internet, UEFI/BIOS).
3. **Select your target disk** from a list.
4. **Partition the disk** interactively (with confirmation and warnings).
5. **Format partitions** (choose filesystem types).
6. **Mount partitions** (root, boot/EFI, home, etc.).
7. **Install the base system** (pacstrap).
8. **Generate fstab** automatically.
9. **Configure system settings** (locale, timezone, hostname, networking).
10. **Set root password** and **create a user** (with sudo).
11. **Choose and install a kernel** (linux, linux-lts, etc.).
12. **Install and configure bootloader** (GRUB/systemd-boot).
13. **Review summary** of all settings and changes.
14. **Finalize and reboot** into your fresh Arch install.

---

## FAQ

**Q: Will this erase my data?**  
A: Yes, if you choose a disk and confirm partitioning/formatting. Always back up important data first.

**Q: Can I use this on a VM?**  
A: Yes, it works on both real hardware and virtual machines.

**Q: Does it support encrypted installs?**  
A: Not yet, but you can manually set up encryption before running the script.

**Q: What if something fails?**  
A: The script stops on errors and prints helpful messages. You can rerun from any step.

---

## Contributing

Pull requests and suggestions are welcome! If you have an idea or find a bug, open an issue or PR.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
