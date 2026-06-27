# Flybase

Umbrella repository for the Flybase / AFCA *Drosophila* snRNA-seq project. The
work is split into four stages, each tracked as its own **git submodule** with a
dedicated GitHub repo:

| Stage | Directory | Repository |
|-------|-----------|------------|
| 0 | `0 - Data Prep` | [Flybase-DataPrep](https://github.com/Mabdel-03/Flybase-DataPrep) — AFCA integration, annotation, clustering evaluation |
| 1 | `1 - Platform` | [Flybase-MantisViewer](https://github.com/Mabdel-03/Flybase-MantisViewer) — cellxgene serving / viewer platform |
| 2 | `2 - Cel Rep` | [Flybase-CellRep](https://github.com/Mabdel-03/Flybase-CellRep) — cell2sentence VAE/CLIP co-embedding |
| 3 | `3 - Gene Rep` | [Flybase-GeneRep](https://github.com/Mabdel-03/Flybase-GeneRep) — gene representation |

Shared, machine-independent configuration lives in [`config/`](config/).

---

## Cloning

Clone the umbrella repo **with its submodules**:

```bash
git clone --recurse-submodules git@github.com:Mabdel-03/Flybase.git
```

If you already cloned without `--recurse-submodules`, fetch the submodule
contents afterward:

```bash
git submodule update --init --recursive
```

> **Note on data.** The large single-cell artifacts (`*.h5ad`, `*.npy`, `*.pt`,
> figures, `data/`, `outputs/`, …) are git-ignored in every submodule and are
> **not** stored on GitHub. A fresh clone gives you the code and configs; the
> data is regenerated or staged locally.

---

## Working with submodules

### Daily workflow — committing changes to a stage

Each stage is an independent repo. Work *inside* the stage directory and commit
as normal — those commits go to that stage's GitHub repo:

```bash
cd "2 - Cel Rep"
git add <files>
git commit -m "..."
git push                      # -> Flybase-CellRep
```

Then, from the **umbrella root**, record the new pointer so the umbrella tracks
the updated commit:

```bash
cd ..
git add "2 - Cel Rep"
git commit -m "Bump Cel Rep to <short description>"
git push                      # -> Flybase (umbrella)
```

The umbrella repo stores a *gitlink* — a reference to one specific commit of
each submodule — not the submodule's files. Updating a stage is therefore a
two-step push: first the stage repo, then the umbrella pointer.

### Pulling the latest

```bash
git pull                                  # update the umbrella
git submodule update --init --recursive   # check out the pointed-to commits
```

To instead fast-forward every submodule to the tip of its own `main`:

```bash
git submodule update --remote --merge
```

### Common commands

```bash
# Status of all submodules (commit + branch)
git submodule status

# Run a command in every submodule
git submodule foreach 'git status -s'

# See which submodule pointers changed
git diff --submodule
```

### Branches

All submodules track `main`. If `git submodule status` shows a leading `+`
(submodule is ahead of the recorded commit) or `-` (not checked out), run
`git submodule update` to reconcile, or commit the new pointer from the umbrella
root if the change is intentional.
