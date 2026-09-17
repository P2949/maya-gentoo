# Portage work artifact map

The completed installation work is in /home/p2949/src/native-maya-gentoo/.
This repository contains the method and documentation, not Autodesk payloads.

| Purpose | Authoritative location |
| --- | --- |
| Resumable state | STATE.md |
| Compatibility decisions | DECISIONS.md |
| Payload importer | scripts/import-autodesk-payload.sh |
| Payload hashes/maps | payload/ |
| Baseline host evidence | logs/baseline.txt |
| Portage install logs | logs/install-*.txt |
| Licensing registration | logs/licensing-list-final.txt |
| GUI crash diagnosis | logs/maya-gui-gdb*.txt and logs/maya-gui-lddebug.txt |
| Batch/mayapy checks | logs/test-maya-batch*.txt and logs/test-mayapy*.txt |
| GUI/graphics checks | logs/test-maya-gui*.txt and logs/test-render*.txt |
| Automated scene | test-output/native_smoke.ma |
| Render evidence | test-output/render.log |
| Overlay source | overlay-worktree/ |
| Overlay documentation | overlay-worktree/README.md |

Final overlay commits:

    0e70c91  Package MayaUSD and Bifrost payload components
    c2b6444  Package LookdevX and Substance payloads
    8b845e1  Document tested Maya 2027.2 payload
    e8cb35a  Fix Maya GUI libmd startup collision
    1285726  fix Maya X11 authentication runtime

Inspect the original overlay with:

    git -C /home/p2949/src/native-maya-gentoo/overlay-worktree log --oneline
    git -C /home/p2949/src/native-maya-gentoo/overlay-worktree show 1285726

Only non-proprietary ebuilds, init scripts, manifests, and importer logic may
be copied into a future portage-overlay directory. Never copy RPMs, ZIPs,
TGZs, extracted Autodesk trees, license databases, or browser/account data.
