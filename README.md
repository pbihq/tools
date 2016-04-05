MailDBOptimiser
===============
Simple bash script that optimises the Apple Mail database. Inspired by [Brett Terpstra's post][1]. Run it remotely:  

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/MailDBOptimiser.sh)

[1]: http://brettterpstra.com/2015/10/27/vacuuming-mail-dot-app-on-el-capitan/

PDF-Services
===========
Deploys two OS X services to combine and split PDFs. Based on [Brooks Duncan's Automator workflows][2].

[2]: http://www.documentsnap.com/how-to-combine-pdf-files-in-mac-osx-using-automator-to-make-a-service/

RemoveFlash
===========
[Uninstall Adobe Flash Player][3] from the command line.

[3]: https://helpx.adobe.com/flash-player/kb/uninstall-flash-player-mac-os.html

Status
======
Script to get a quick system status overview on OS X. Run it remotely or install it on your system.

Install Status-Script on local machine. After that you can run it by simply typing "status" in the command line:

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/Status/InstallStatus.sh)

Or run it remotely:

    bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/Status/Status.sh)