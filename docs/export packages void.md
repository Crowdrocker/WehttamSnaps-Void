To export your installed packages on Void Linux, use xbps-query to generate a clean list of package names without version numbers so you can easily reinstall them later. [1] (https://docs.voidlinux.org/xbps/index.html), [2] (https://www.youtube.com/watch?v=q5dO-JutBhM&t=443)

Export Manually Installed Packages (Recommended)

To back up only the packages you explicitly installed (excluding automatic dependencies), run:
bash

xbps-query -m | xargs -n1 xbps-uhelper getpkgname > pkglist.txt

Use code with caution.
• xbps-query -m lists all manually installed packages with their version strings.
• xbps-uhelper getpkgname strips the version numbers so the list stays compatible with future updates. [1] (https://www.youtube.com/watch?v=q5dO-JutBhM&t=443), [2] (https://docs.voidlinux.org/xbps/index.html)

Export All Installed Packages

If you want a complete list of every single package on your system (including base system packages and dependencies), use the -l flag instead: [1] (https://docs.voidlinux.org/xbps/index.html), [2] (https://www.youtube.com/watch?v=q5dO-JutBhM&t=443)
bash

xbps-query -l | awk '{print $2}' | xargs -n1 xbps-uhelper getpkgname > all_pkglist.txt

Use code with caution.

Using xtools (Shorthand)

If you have the xtools package installed, you can use the xpkg utility to do the exact same thing with shorter commands: [1] (https://docs.voidlinux.org/xbps/index.html)
• Manually installed: xpkg -m > pkglist.txt
• All installed: xpkg > all_pkglist.txt [1] (https://docs.voidlinux.org/xbps/index.html)

How to Restore Your List Later

On a fresh Void Linux installation, you can reinstall everything from your saved file with:
bash

sudo xbps-install -S $(cat pkglist.txt)

Use code with caution.
(Note: Check the Void Linux Handbook on XBPS if you also enabled extra repositories like void-repo-nonfree or void-repo-multilib, as those repository packages should be installed first before restoring your full list.) [1] (https://docs.voidlinux.org/xbps/repositories/index.html)
Would you like to know how to export Flatpaks alongside your system packages, or how to exclude base system packages from the list?















