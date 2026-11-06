# Build notes

**Purpose:** how to build Litematica Enhanced, what the build depends on, what it produces, and the quirks that trip people up. Facts come from the files and logs cited; nothing here is an estimate.

## Toolchain
| Item | Value | Source |
|---|---|---|
| Java | 25 required (`options.release = 25`, `sourceCompatibility/targetCompatibility = VERSION_25`) | `build.gradle:91,100-101` |
| JDK used in P00 | Temurin 25.0.5+8 (local) · CI: Temurin 25 on `ubuntu-latest` | `phases/P00/logs/build-baseline-env.txt`, `.github/workflows/build.yml:14-17` |
| Gradle | 9.7.1 (wrapper) | `gradle/wrapper/gradle-wrapper.properties`, `phases/P00/logs/build-baseline.log` |
| Fabric Loom | plugin `net.fabricmc.fabric-loom` `1.18.+`, resolved to **1.18.4** in P00 | `build.gradle:2`, `build-baseline.log` |
| Minecraft / Loader | 26.3 (unobfuscated, Mojang names) / Fabric Loader 0.19.5 | `gradle.properties` |
| MaLiLib | `fi.dy.masa.malilib:malilib-fabric-26.3:0.30.2` (implementation) | `build.gradle`, `gradle.properties` |
| Bundled (JiJ) | `me.fallenbreath:conditional-mixin-fabric:0.6.4` (`include(implementation(...))`) | `build.gradle` |
| compileOnly | ModMenu 21.0.0, Iris 1.11.6+26.3 | `build.gradle` |
| Fabric API | **not a direct dependency** (all `fabricApi.module` lines are commented out). At runtime MaLiLib 0.30.2 bundles (JiJ) and requires `fabric-api-base` 2.0.6, `fabric-networking-api-v1` 6.3.8 and `fabric-resource-loader-v1` 3.0.4 | `build.gradle`; MaLiLib jar `fabric.mod.json` and `META-INF/jars/` |
| Gradle JVM | `-Xmx3G`, daemon off, cache cleanup off | `gradle.properties` |

## Commands
- Build: `./gradlew build` (Windows: `gradlew.bat build`). Produces the remapped jar and the sources jar; `check` runs but there are **no tests** at baseline (`:test NO-SOURCE`).
- Clean build for audits: a fresh detached worktree (`git worktree add --detach <dir> <ref>`), or `git clean -xfd` on a checkout with nothing to lose.
- Dev client: `./gradlew runClient`.
- Baseline rebuild (exact): `git worktree add --detach <dir> baseline/sakura-26.3-0.29.2-sakura.1 && cd <dir> && ./gradlew build --console=plain --warning-mode all`.

## Repositories (resolution order in `build.gradle`)
1. `mavenLocal()` (**first**: a stale local artefact shadows the remote ones; see quirks)
2. `https://masa.dy.fi/maven/sakura-ryoko` (group `fi.dy.masa`) → MaLiLib
3. `https://maven.fallenbreath.me/releases` (group `me.fallenbreath`) → conditional-mixin
4. `https://maven.terraformersmc.com/releases/` (group `com.terraformersmc`) → ModMenu
5. `https://jitpack.io` (group `com.github`)
6. `https://api.modrinth.com/maven` → Iris
Plugins: `https://maven.fabricmc.net/` and the Gradle Plugin Portal (`settings.gradle`).

Reachability on 2026-11-06: all of them answer HTTP 200 to Java's HTTP client (`phases/P00/logs/repo-reachability.txt`). The baseline build itself resolved MaLiLib from the local Gradle cache, which already held 0.30.2.

### If the MaLiLib maven is unreachable (do not edit `build.gradle` without an ADR)
1. Check the Gradle cache first (`~/.gradle/caches/modules-2/files-2.1/fi.dy.masa.malilib/`), and try `./gradlew build --offline`.
2. **mavenLocal**: clone `sakura-ryoko/malilib`, check out the commit that sets `mod_version = 0.30.2` on branch `26.3` (there is **no** `26.3-0.30.2` tag; the newest 26.3 tag is `26.3-0.30.1`, see `phases/P00/logs/upstream-state.txt`), then run `./gradlew publishToMavenLocal`. `mavenLocal()` is already first in the repository list, so no build-script change is needed.
3. **JitPack**: `build.gradle` carries a commented alternative, `com.github.sakura-ryoko:malilib:${malilib_version}`. Switching to it **is** a build-script change and needs an ADR.
Stop and ask the human before any of these become the normal path.

## Artifacts (baseline, commit `64e74592`)
| File | Size (bytes) | SHA-256 |
|---|---|---|
| `build/libs/litematica-fabric-26.3-0.29.2-sakura.1.jar` | 1,976,015 | `d2a9a66d5df8d34aeb23065f0ea2764a166b16d2d76b64acf9bc19d48eeaa474` |
| `build/libs/litematica-fabric-26.3-0.29.2-sakura.1-sources.jar` | 1,198,089 | `145c7ba699e17492df7b755ade4251d57e9500b5e6fdae2acd9a7c47bf7d27ef` |
The main jar is under 5 MB, so a copy is kept at `docs/enhanced/baseline/litematica-fabric-26.3-0.29.2-sakura.1.jar`. Hashes: `phases/P00/logs/baseline-jars.sha256`. Build: exit 0, 43 s wall clock with warm caches, 0 compiler `warning:` lines, 2 javac notes, 1 Gradle deprecation warning (`phases/P00/logs/build-baseline.log`).

## Known quirks
- **Jar bytes are not reproducible.** `preserveFileTimestamps = true` and `reproducibleFileOrder` is commented out (`build.gradle`), so two builds of the same commit give different SHA-256 values. Compare jar *contents* (sorted entry list plus per-entry hashes), not jar bytes. Changing this is a build change (ADR).
- **Line endings.** `.gitattributes` forces `*.java` to CRLF in the working tree (316/316 files: `i/lf w/crlf`). Never run `git add --renormalize`. `fabric.mod.json` and `*.md` are LF in the repository.
- **Mixed indentation.** Of 316 Java files, 144 have tab-indented lines, 240 have 4-space-indented lines and 72 have both (`git grep -l -P '^\t'` / `'^    '`). Match the surrounding lines; never reformat.
- **Fabric API comes only through MaLiLib.** Litematica declares no Fabric API dependency, but MaLiLib bundles and requires `fabric-api-base`, `fabric-networking-api-v1` and `fabric-resource-loader-v1`. Upstream code already uses them (`network/ServuxLitematicaHandler.java:17` imports `ClientPlayNetworking`; `git grep -l 'net.fabricmc.fabric' src/main` → 1 file). Any other Fabric API module, or a direct dependency, needs an ADR (CLAUDE.md: "Fabric API is not a runtime dependency"). Corrected after pre-audit AUD-P00-03.
- **javac notes.** "Some input files use or override a deprecated API" and "`util/PlacementHandler.java` uses unchecked or unsafe operations". Lint flags are not enabled.
- **Gradle 10 deprecation.** "Invocation of Task.project at execution time has been deprecated" (source: `build.gradle:79`, `expand "mod_version": project.mod_version` inside `processResources { filesMatching("fabric.mod.json") { … } }`, which calls `Task.project` at execution time; `phases/P00/logs/build-head.log`, pre-audit AUD-P00-04). It will fail under Gradle 10, so check it before any wrapper upgrade.
- **`-dev` versions** get a timestamp suffix (`build.gradle` `base { … }`), so dev jar names change on every build.
- **`publishing`** targets `$projectDir/../../CommonMaven` (upstream author's layout). Never run `publish` in this fork.
- **`jitpack.yml`** pins `java 25.0.2-tem`.
- **Windows curl** (Git for Windows, schannel) fails TLS to `masa.dy.fi` with `SEC_E_UNSUPPORTED_FUNCTION`, although Java reaches it fine. Do not conclude an outage from curl alone.

Last verified at commit 64e74592f631cfa5b084bedb0eda5dac8a3b3cb8 (2026-11-06)
