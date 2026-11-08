# Third-party content

## Intel Performance Skills

- **Source:** https://github.com/intel/intel-performance-skills
- **Vendored from:** commit `3e33aecabb956ec48526b3f842f4f70ae96d98ff` (branch `main`)
- **Skills:** `linux-perf`, `performance-patterns`, `phoronix-test-suite`
- **Installed at:** `skills/` (the `user-dsh` skill root, rank 400)
- **License:** MIT, Copyright (c) 2026 Intel Corporation (full text below)

### Local modifications

Upstream content is copied verbatim except for the changes below. They are kept as
patches in `local-patches/` so they can be re-applied after an update rather than
being rediscovered from memory.

| File | Change | Why |
|---|---|---|
| `skills/phoronix-test-suite/SKILL.md` | adds `disable-model-invocation: true` | Keeps PTS off the model-facing catalog; explicit invocation only |
| `skills/linux-perf/references/building-blocks.md`, `flow-d.md` | drops `-a` from the three dual-profile `perf record` commands; adds notes on `perf_event_paranoid` and hybrid P/E pinning | `-a` needs CPU-wide events (`paranoid=0`) and makes the pinned measurement include unrelated system noise; the vendor's `HALF=nproc/2` core set mixes P- and E-cores |

Any other local edits will be overwritten on update, so keep other customizations in
a separate, differently named skill instead.

### Updating

```bash
tmp=$(mktemp -d)
git clone --depth 1 https://github.com/intel/intel-performance-skills "$tmp"
cp -r "$tmp"/skills/{linux-perf,performance-patterns,phoronix-test-suite} skills/
rm -rf "$tmp"
git apply local-patches/*.patch   # re-apply the local modifications
# then update the commit hash above and commit
```

If a patch fails to apply, upstream changed those lines: resolve by hand and
regenerate the patch with
`git diff <vendor-commit> -- skills/<name> > local-patches/<name>.patch`.

### License

MIT License

Copyright (c) 2026 Intel Corporation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
