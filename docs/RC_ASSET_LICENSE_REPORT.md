# Selected asset-license verification — 15 October 2026

**Public packaging remains locked: three groups need creator terms.** The owner confirms free acquisition with commercial game-use permission and has now supplied all four original download URLs. [Owner statement and URLs](licenses/OWNER_COMMERCIAL_USE_STATEMENT_2026-10-15.md). **Forest commercial compiled-game use is documented with mandatory Eder Muniz credit; raw source redistribution is prohibited.** Character/enemy/UI license conditions still need evidence.

All approved visuals stay selected. No artwork, gameplay or Windows Private QA build logic is changed. The inventory remains **47 files**: 26 third-party PNGs (11 character, one enemy, two UI, 12 forest) plus 21 original SVG/WAV files. `tools/release_assets.json` records source, compiled-game permission, source sharing and attribution separately. [Evidence snapshot](licenses/SELECTED_THIRD_PARTY_EVIDENCE_2026-10-15.json) binds this review to file/evidence SHA-256 hashes.

## Sources and creator identities

| Group | Creator / original source supplied by owner | Verification |
|---|---|---|
| Character — 11 PNGs | **Joe Idaho (`joe-idaho`)**, [Side Scrolling Hack N Slash Character](https://joe-idaho.itch.io/side-scrolling-hack-n-slash-character) | Owner identifies this source account; original webpage not read. Selected files match historical `resources/Characters/Dante` hashes. Actual creator terms and any character/IP restrictions remain pending. |
| Demon Sword — one PNG | **Immortal Burrito (`immortal-burrito`)**, [Blood Demons](https://immortal-burrito.itch.io/blood-demons) | Owner identifies this source account/pack. Original webpage not read; no license text found in supplied PNG/Aseprite/examples. |
| Pixel1 health fill/border — two PNGs | **Adwit Rahman (`adwitr`)**, [Pixel Health Bar Asset Pack](https://adwitr.itch.io/pixel-health-bar-asset-pack) | Source supplied by owner; name also supported by uploaded pack/credit filename. Actual page terms not read. |
| Forest — 12 PNGs | **Eder Muniz (`edermunizz`)**, [Free Pixel Art Forest](https://edermunizz.itch.io/free-pixel-art-forest) | Source confirmed by owner; creator explicitly named in original README. All 12 hashes match the historical pack containing applicable license/FAQ. Live page not read. |

Source URLs are recorded as owner-supplied, not independently retrieved. In JSON, `source_url_verified=false` means **live URL content was not verified**, not that recovered applicable forest terms were ignored. The other three creator-account identities remain owner-attributed until their page/license evidence is available.

## Actual permission findings

| Group | Commercial compiled-game use | Attribution | Modifications / source-file redistribution | Status |
|---|---|---|---|---|
| Joe Idaho character | Owner reports permission; actual creator grant not yet supplied. | Provisional credit: “Character artwork: Joe Idaho — Side Scrolling Hack N Slash Character.” Whether mandatory and exact wording **pending**. | Both **not established**. Include actual pack restrictions concerning the depicted character/IP in review. | **Pending creator terms; unverified.** |
| Immortal Burrito enemy | Owner reports permission; actual creator grant not yet supplied. | Provisional credit: “Enemy artwork: Immortal Burrito — Blood Demons.” Mandatory wording **pending**. | Both **not established**. Editable Aseprite availability is not source-sharing permission. | **Pending creator terms; unverified.** |
| Adwit Rahman UI | Owner reports permission; actual creator grant not yet supplied. | Preserve “Pixel Health Bar Asset Pack by Adwit Rahman (@adwitr_itch.io)” provisionally. Whether mandatory **pending**. | Both **not established**. Artist credit alone is not a license. | **Pending creator terms; unverified.** |
| Eder Muniz forest | **Allowed by matching original bundled terms**, including free/commercial game use. Owner-confirmed source, matching files, creator README and explicit grant provide sufficient compiled-game documentation. | **Required:** “Forest art by Eder Muniz — Free Pixel Art Forest.” | Modification **allowed**. Redistributing/reselling asset files as an asset pack **prohibited**, even modified. | **Verified for compiled-game use only.** No live-page verification claimed. |

No group is assigned CC0 simply because it is free. For pending groups, no source-sharing permission, credit waiver or modification permission is inferred. Existing CC0 applies only to original project media.

## Forest evidence and scope

Primary evidence recovered from historical commit `f3d6d48`:

- [Original README](licenses/FOREST_HISTORICAL_README.txt): “Artwork created by Eder Muniz” and “Free Pixel Art Forest.”
- [Bundled license/FAQ](licenses/FOREST_HISTORICAL_TERMS.txt): “You can use any asset personally and commercially”; “You can modify/ adapt the asset”; “You must give appropriate credit.” It prohibits asset-file sharing/resale even after modification. The FAQ explicitly permits free/commercial game use.
- All 12 selected PNG hashes match the historical pack. Stable historical evidence URLs, the owner-confirmed original creator URL and this verification basis are recorded in `tools/release_assets.json`.

These **custom terms are not plain CC BY or CC0**. They authorize game use; they do not authorize publishing the forest PNG/PSD assets or a source-project/asset bundle. Use as runtime artwork inside the compiled game, include credit and preserve the applicable terms. No additional encryption requirement or new custom permission is invented: the applicable bundled grant is the permission evidence. This clearance does not clear any other pack or permit raw source redistribution.

## What is still needed from the owner

The original URLs are now supplied; there is no need to send them again.

| Group | Remaining evidence |
|---|---|
| Joe Idaho character | Saved creator-page license/usage text, screenshot/PDF, original bundled license/README or creator permission explicitly covering commercial compiled-game distribution, credit, modifications and source-file restrictions. Include any character/IP restriction in that pack's terms, given the historical Dante file group. |
| Immortal Burrito Blood Demons | The creator's applicable license/usage text or bundled license/README covering the same commercial-game, attribution, modification and raw-file conditions. |
| Adwit Rahman UI | The creator's applicable license/usage text or bundled license/README covering the same conditions. A free download or credit image alone does not establish them. |
| Forest | **No additional permission document required for this compiled-game clearance.** Preserve the confirmed URL, matching pack identity, bundled terms and mandatory credit. Any contrary/additional terms in the owner's original archive should be included if they exist. |

Archive name/version/date or a file list, if available, helps connect the pending packs' terms to these selected PNGs. No purchase receipt is required for a free pack unless the actual license makes an entitlement necessary. No messages are sent to creators by this task.

## Live verification and network limitation

All four supplied URLs were requested via the configured proxy. **Each failed at CONNECT with HTTP 403, curl exit 56 / origin status 000.** These were environment policy denials, not responses from the creator pages. No HTML/license terms were retrieved. Repository/upload text files, historical README/license, hash inventory and image/authoring metadata were also inspected; character/enemy/UI terms were not found. Adobe/W3C/XML namespace links are metadata schemas, not licenses.

A minimal allow-list draft was attempted using the supported configuration tool for only `joe-idaho.itch.io`, `immortal-burrito.itch.io`, `adwitr.itch.io` and `edermunizz.itch.io`. The tool returned **`draft_not_editable`**; a reread showed no saved rule changes. No network update was confirmed or applied. [Transferable proposal](ASSET_LICENSE_NETWORK_PROPOSAL.json) preserves the exact intended change. If environment access is enabled through the supported settings workflow, live verification can continue; supplying saved license text avoids that dependency. No proxy bypass or alternate-domain workaround is used.

## Gate, existing artifacts and checks

Forest is promoted to `verified` for compiled-game use with primary evidence. Character/enemy/UI stay `unverified`. The owner statement is stored separately and is not substituted for creator terms in gate evidence. Public packaging remains blocked until **all** selected groups have documented applicable permission.

- Inventory audit: **47 selected paths unchanged; 14 third-party PNGs pending; three blocking groups; 33 source assets cleared for compiled-game packaging** (12 forest + 21 original). All 26 third-party files/evidence are hash-bound to this review.
- `python3 tools/release.py` returned expected **exit 1 / PUBLIC PACKAGING BLOCKED**, before export. Private QA build code and committed public quarantine are unchanged.
- Existing Windows executable, private QA ZIP and Linux artifact SHA-256 hashes still match `RC_ARTIFACTS.json`. This review does not rewrite that archive or its historical embedded license report/manifest. A future QA build uses the updated credits/report.
- `git diff --check` and metadata/evidence checks passed; gameplay, art, scenes, project settings, export presets and `tools/release.py` remain unchanged. No Godot import/regression/export or native Windows test is rerun/claimed for these documentation/metadata-only changes.
- `origin/main` was fetched at `d6b9e82` (owner-merged RC PR #6); no newer asset/license changes were present. Follow-up branch: `review/asset-license-verification`.

## Other media and notices

Original project media (14 SVGs, seven synthesized WAVs) remain CC0 under `resources/original/LICENSE.txt`; that grant does not license uploaded art or change pre-existing code rights. Godot MIT, bundled Noto Sans OFL and third-party notices remain in `GODOT_LICENSE.txt` / `GODOT_COPYRIGHT.txt`. Keep all applicable notices/credits in future packages. Unused sprites/UI options and all PSD/Aseprite/GIF source/reference files remain excluded from game export; source redistribution is separate from commercial game use.

Updated credits: [RC_CREDITS.txt](RC_CREDITS.txt). Previous build/test record: [RC_VALIDATION.md](RC_VALIDATION.md). No new build, merge or itch.io publication is performed by this review. Native Windows sign-off is still required independently of licensing.
