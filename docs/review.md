# The review pack

Everything a review board, an architecture board or an internal audit asks
for before abap2UI5 goes into a system, in one list. Each line is a document
in this repository or an asset of the release under review, so what a
reviewer reads is the version they install.

| Question | Where it is answered |
|---|---|
| What exactly goes into our system? | The bill of materials of the release, `abap2ui5-<version>.cdx.json` (CycloneDX 1.5) on its [release page](https://github.com/abap2UI5/abap2UI5/releases): the ABAP objects and the embedded frontend with a SHA-256 each, and UI5 as the one runtime dependency, never bundled. `npm run check:sbom` holds every merge to "nothing third-party is shipped" |
| What does the framework guarantee, and what is ours to do? | [security.md](security.md) — trust boundaries, the guarantees with the gate or test behind each, what the app and the operator have to do |
| How are vulnerabilities reported and answered? | [SECURITY.md](../SECURITY.md) — the disclosure process, the response timeline, the deliberate design decisions |
| Is it accessible? | [accessibility.md](accessibility.md) — what UI5 does, what the framework adds with a test for each, what the app has to do, and what is not claimed |
| What is it tested against? | [verified-on.md](verified-on.md) — what CI proves on every merge, and what people report from real systems |
| What will change under us? | [changelog.txt](../changelog.txt) for every release, [removal-plan.md](removal-plan.md) for every deprecation and what replaces it, the [public-API snapshot](../.github/api-snapshot.json) a change to the API fails against |
| How is a release made? | [RELEASING.md](../RELEASING.md) and [release.yaml](../.github/workflows/release.yaml) — one tag, the full verification on the tagged commit, the 7.02 build tagged beside it |
| What does it cost, and under which licence? | [LICENSE](../LICENSE) (MIT), and the cost section of [Evaluate abap2UI5](https://abap2ui5.github.io/docs/evaluate.html#what-it-costs) |
| Who supports it? | [SUPPORT.md](../SUPPORT.md) — the community channels and the commercial offers |
| How do we evaluate it ourselves? | [Evaluate abap2UI5](https://abap2ui5.github.io/docs/evaluate.html#how-to-evaluate-it-in-a-week) — one real screen in a week |
