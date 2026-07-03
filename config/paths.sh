#!/bin/bash
# =============================================================================
# Flybase — single source of truth for paths and environment.
#
# Mirrors the convention of ROSMAP_Code/Transcriptomics/config/paths.sh:
#   * auto-detect REPO_ROOT from this file's location,
#   * source the (gitignored) machine-specific config/paths.local.sh,
#   * define FLY_* variables with sane defaults that local overrides win over.
#
# Usage:   source config/paths.sh   &&   check_paths
# =============================================================================

export _CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT="$(cd "${_CONFIG_DIR}/.." && pwd)"

# --- Machine/user-specific overrides (gitignored) ----------------------------
if [[ -f "${_CONFIG_DIR}/paths.local.sh" ]]; then
    source "${_CONFIG_DIR}/paths.local.sh"
fi

# --- Conda --------------------------------------------------------------------
# Defaults target the lab's Engaging setup; override in paths.local.sh.
export CONDA_INIT_SCRIPT="${CONDA_INIT_SCRIPT:-/orcd/data/lhtsai/001/om2/mabdel03/miniforge3/etc/profile.d/conda.sh}"
export CONDA_ENV_BASE="${CONDA_ENV_BASE:-/orcd/data/lhtsai/001/om2/mabdel03/conda_envs}"
# Stage-3 integration env (scanpy + harmonypy + anndata + decoupler + rpy2).
# Reuses the Transcriptomics BatchCorrection_SingleCell env verbatim.
export BATCHCORR_ENV="${BATCHCORR_ENV:-${CONDA_ENV_BASE}/BatchCorrection_SingleCell}"

# --- SLURM --------------------------------------------------------------------
# pi_lhtsai / pi_manoli only — never pi_tpoggio.
export SLURM_PARTITION="${SLURM_PARTITION:-mit_normal}"

# --- Data Prep paths ----------------------------------------------------------
export FLY_DATA_PREP_DIR="${FLY_DATA_PREP_DIR:-${REPO_ROOT}/0 - Data Prep}"
export FLY_WORKFLOW_DIR="${FLY_WORKFLOW_DIR:-${FLY_DATA_PREP_DIR}/workflow}"
export FLY_INGEST_WORKFLOW="${FLY_INGEST_WORKFLOW:-${FLY_WORKFLOW_DIR}/ingest}"
export FLY_INSPECT_WORKFLOW="${FLY_INSPECT_WORKFLOW:-${FLY_WORKFLOW_DIR}/inspect}"
export FLY_STAGE3_WORKFLOW="${FLY_STAGE3_WORKFLOW:-${FLY_WORKFLOW_DIR}/stage3_integration}"
export FLY_STAGE4_WORKFLOW="${FLY_STAGE4_WORKFLOW:-${FLY_WORKFLOW_DIR}/stage4_subclustering}"
export FLY_STAGE5_WORKFLOW="${FLY_STAGE5_WORKFLOW:-${FLY_WORKFLOW_DIR}/stage5_annotation}"
export FLY_FIGURE_WORKFLOW="${FLY_FIGURE_WORKFLOW:-${FLY_WORKFLOW_DIR}/figures_diagnostics}"

# The AFCA atlas .h5ad (~3 GB) lives under "0 - Data Prep/data" (gitignored). It is
# fetched by "0 - Data Prep/workflow/ingest/download_afca.sh".
export FLY_INPUT_H5AD="${FLY_INPUT_H5AD:-${FLY_DATA_PREP_DIR}/data/adata_headBody_S_v1.0.h5ad}"

# Processing outputs (gitignored). FLY_PROCESSING_OUTPUTS is a compatibility
# alias for the canonical output root, not an old-layout path.
export FLY_OUTPUTS="${FLY_OUTPUTS:-${FLY_PROCESSING_OUTPUTS:-${FLY_DATA_PREP_DIR}/outputs}}"
export FLY_PROCESSING_OUTPUTS="${FLY_PROCESSING_OUTPUTS:-${FLY_OUTPUTS}}"
export FLY_STAGE3_OUTPUTS="${FLY_STAGE3_OUTPUTS:-${FLY_OUTPUTS}/stage3_integrations}"
export FLY_STAGE4_OUTPUTS="${FLY_STAGE4_OUTPUTS:-${FLY_OUTPUTS}/stage4_subclusters}"
export FLY_STAGE5_OUTPUTS="${FLY_STAGE5_OUTPUTS:-${FLY_OUTPUTS}/stage5_annotations}"
export FLY_COMPARISON_OUTPUTS="${FLY_COMPARISON_OUTPUTS:-${FLY_OUTPUTS}/comparisons}"
export FLY_FIGURE_OUTPUTS="${FLY_FIGURE_OUTPUTS:-${FLY_OUTPUTS}/figures}"
export FLY_LOGS="${FLY_LOGS:-${FLY_OUTPUTS}/logs}"

# Optional fly marker references. ORA RDS is optional; curated CSV panels are used
# by the v2 annotation and neuron-annotation workflows.
export FLY_MARKER_DIR="${FLY_MARKER_DIR:-${FLY_DATA_PREP_DIR}/references/markers}"
export FLY_MARKERS_RDS="${FLY_MARKERS_RDS:-${FLY_MARKER_DIR}/Fly_Markers.rds}"
export FLY_FCA_MARKERS_CSV="${FLY_FCA_MARKERS_CSV:-${FLY_MARKER_DIR}/fca_markers_by_celltype.csv}"
export FLY_NEURON_MARKERS_CSV="${FLY_NEURON_MARKERS_CSV:-${FLY_MARKER_DIR}/Fly_Neuron_Markers_curated.csv}"

# Config files consumed by the pipeline.
export FLY_PIPELINE_YAML="${FLY_PIPELINE_YAML:-${_CONFIG_DIR}/pipeline.yaml}"
export FLY_VARIANTS_YAML="${FLY_VARIANTS_YAML:-${_CONFIG_DIR}/variants.yaml}"

# --- Cel Rep (2 - Cel Rep): cell-language co-embedding ------------------------
# Multimodal Cell2Sentence + CLIP ("CellCLIP") cell<->text alignment. The bucket
# is split into two parallel roots that share the same workflow structure:
#   Drosophila/   single-species FCA/AFCA reference implementation (all prior work)
#   Interspecies/ new CellWhisperer-style interspecies initiative (skeleton)
# Each root is organized by workflow stage, with data/model artifacts under
# data/, training under model_training/, inference under model_inference/, and
# evaluation outputs under evaluations/.
export FLY_CEL_REP_BUCKET="${FLY_CEL_REP_BUCKET:-${REPO_ROOT}/2 - Cel Rep}"

# Drosophila root. FLY_CEL_REP_DIR (and its unsuffixed FLY_CEL_REP_* siblings)
# point HERE so existing fly scripts and downstream consumers (e.g. 3 - Gene Rep)
# keep resolving to the single-species work without change.
export FLY_CEL_REP_DIR="${FLY_CEL_REP_DIR:-${FLY_CEL_REP_BUCKET}/Drosophila}"
export FLY_CEL_REP_DATA="${FLY_CEL_REP_DATA:-${FLY_CEL_REP_DIR}/data}"
export FLY_CEL_REP_TRAINING="${FLY_CEL_REP_TRAINING:-${FLY_CEL_REP_DIR}/model_training}"
export FLY_CEL_REP_INFERENCE="${FLY_CEL_REP_INFERENCE:-${FLY_CEL_REP_DIR}/model_inference}"
export FLY_CEL_REP_EVALUATIONS="${FLY_CEL_REP_EVALUATIONS:-${FLY_CEL_REP_DIR}/evaluations}"
export FLY_CEL_REP_MODEL_WEIGHTS="${FLY_CEL_REP_MODEL_WEIGHTS:-${FLY_CEL_REP_DATA}/model_weights}"
# Deprecated compatibility alias: old scripts used FLY_CEL_REP_OUTPUTS for the
# output root. New code should prefer FLY_CEL_REP_EVALUATIONS.
export FLY_CEL_REP_OUTPUTS="${FLY_CEL_REP_OUTPUTS:-${FLY_CEL_REP_EVALUATIONS}}"
export FLY_CEL_REP_LOGS="${FLY_CEL_REP_LOGS:-${FLY_CEL_REP_EVALUATIONS}/logs/slurm}"

# Explicit Drosophila-scoped aliases (mirror the unsuffixed vars above; use these
# when a script needs to be unambiguous about which root it targets).
export FLY_CEL_REP_DROSOPHILA_DIR="${FLY_CEL_REP_DROSOPHILA_DIR:-${FLY_CEL_REP_DIR}}"
export FLY_CEL_REP_DROSOPHILA_DATA="${FLY_CEL_REP_DROSOPHILA_DATA:-${FLY_CEL_REP_DATA}}"
export FLY_CEL_REP_DROSOPHILA_TRAINING="${FLY_CEL_REP_DROSOPHILA_TRAINING:-${FLY_CEL_REP_TRAINING}}"
export FLY_CEL_REP_DROSOPHILA_INFERENCE="${FLY_CEL_REP_DROSOPHILA_INFERENCE:-${FLY_CEL_REP_INFERENCE}}"
export FLY_CEL_REP_DROSOPHILA_EVALUATIONS="${FLY_CEL_REP_DROSOPHILA_EVALUATIONS:-${FLY_CEL_REP_EVALUATIONS}}"
export FLY_CEL_REP_DROSOPHILA_MODEL_WEIGHTS="${FLY_CEL_REP_DROSOPHILA_MODEL_WEIGHTS:-${FLY_CEL_REP_MODEL_WEIGHTS}}"
export FLY_CEL_REP_DROSOPHILA_LOGS="${FLY_CEL_REP_DROSOPHILA_LOGS:-${FLY_CEL_REP_LOGS}}"

# Interspecies root. New initiative; mirrors the Drosophila layout. Its
# celrep/paths.py reads these FLY_CEL_REP_INTERSPECIES_* overrides.
export FLY_CEL_REP_INTERSPECIES_DIR="${FLY_CEL_REP_INTERSPECIES_DIR:-${FLY_CEL_REP_BUCKET}/Interspecies}"
export FLY_CEL_REP_INTERSPECIES_DATA="${FLY_CEL_REP_INTERSPECIES_DATA:-${FLY_CEL_REP_INTERSPECIES_DIR}/data}"
export FLY_CEL_REP_INTERSPECIES_TRAINING="${FLY_CEL_REP_INTERSPECIES_TRAINING:-${FLY_CEL_REP_INTERSPECIES_DIR}/model_training}"
export FLY_CEL_REP_INTERSPECIES_INFERENCE="${FLY_CEL_REP_INTERSPECIES_INFERENCE:-${FLY_CEL_REP_INTERSPECIES_DIR}/model_inference}"
export FLY_CEL_REP_INTERSPECIES_EVALUATIONS="${FLY_CEL_REP_INTERSPECIES_EVALUATIONS:-${FLY_CEL_REP_INTERSPECIES_DIR}/evaluations}"
export FLY_CEL_REP_INTERSPECIES_MODEL_WEIGHTS="${FLY_CEL_REP_INTERSPECIES_MODEL_WEIGHTS:-${FLY_CEL_REP_INTERSPECIES_DATA}/model_weights}"
export FLY_CEL_REP_INTERSPECIES_LOGS="${FLY_CEL_REP_INTERSPECIES_LOGS:-${FLY_CEL_REP_INTERSPECIES_EVALUATIONS}/logs/slurm}"

# Dedicated conda env for the co-embedding model. NOT the heavy BatchCorrection
# env — this one needs torch + transformers + sentence-transformers + scanpy +
# umap-learn + scikit-learn. It must be created before running (see
# "2 - Cel Rep/Drosophila/README.md"); override the name/location in paths.local.sh.
export CEL_REP_ENV="${CEL_REP_ENV:-${CONDA_ENV_BASE}/cel_rep}"

# Isolated env for the TranscriptFormer foundation-model cell embedder. Kept
# SEPARATE from cel_rep because TranscriptFormer pins torch==2.5.1 (breaks on
# >=2.6) while cel_rep is on torch 2.3.1 — do not merge them. Created with
# `mamba create -p "${TF_ENV}" python=3.11` + `pip install transcriptformer`
# (cu124 torch wheel covers L40S sm_89 / H200 sm_90). Override in paths.local.sh.
export TF_ENV="${TF_ENV:-${CONDA_ENV_BASE}/transcriptformer}"
# Large TranscriptFormer weights + gene-embedding .h5 files + inference outputs
# live on scratch (not the data share). Holds tf-metazoa/ checkpoint and the
# drosophila_melanogaster_gene.h5 protein embeddings.
export TF_HOME="${TF_HOME:-/orcd/scratch/orcd/012/mabdel03/transcriptformer}"

# --- Gene Rep (3 - Gene Rep): protein-language co-embedding -------------------
# Joint ESM(protein) <-> BioBERT(FlyBase description) CLIP for every Drosophila
# protein-coding gene. Reuses the 2 - Cel Rep/Drosophila projection head + InfoNCE
# loss verbatim (imported, not copied). Workspace mirrors Cel Rep: data prep under
# data_prep/, embedding + CLIP training under model_training/, evals under
# evaluations/, shared helpers in generep/.
export FLY_GENE_REP_DIR="${FLY_GENE_REP_DIR:-${REPO_ROOT}/3 - Gene Rep}"
export FLY_GENE_REP_DATA="${FLY_GENE_REP_DATA:-${FLY_GENE_REP_DIR}/data}"
export FLY_GENE_REP_TRAINING="${FLY_GENE_REP_TRAINING:-${FLY_GENE_REP_DIR}/model_training}"
export FLY_GENE_REP_INFERENCE="${FLY_GENE_REP_INFERENCE:-${FLY_GENE_REP_DIR}/model_inference}"
export FLY_GENE_REP_EVALUATIONS="${FLY_GENE_REP_EVALUATIONS:-${FLY_GENE_REP_DIR}/evaluations}"
export FLY_GENE_REP_MODEL_WEIGHTS="${FLY_GENE_REP_MODEL_WEIGHTS:-${FLY_GENE_REP_DATA}/model_weights}"
export FLY_GENE_REP_LOGS="${FLY_GENE_REP_LOGS:-${FLY_GENE_REP_EVALUATIONS}/logs/slurm}"

# Dedicated env for Gene Rep. Owns its OWN env (does not borrow cel_rep, tf, or
# consortium). Needs torch (CUDA-matched: L40S sm_89 / H200 sm_90) + fair-esm +
# transformers + biopython + requests + scikit-learn + pandas. This single env
# covers the ESM embedding pass, all FlyBase data fetch/prep, and eval-label
# fetching. Create it before running (see 3 - Gene Rep/README.md); override in
# paths.local.sh. NOTE: the BioBERT text pass can alternatively run in cel_rep
# (transformers already present, no ESM needed there).
export GENE_REP_ENV="${GENE_REP_ENV:-${CONDA_ENV_BASE}/gene_rep}"

# Encoder model ids (overridable). ESM-2 3B -> 2560-d protein embeddings;
# BioBERT base -> 768-d text embeddings.
export GENE_REP_ESM_MODEL="${GENE_REP_ESM_MODEL:-facebook/esm2_t36_3B_UR50D}"
# BioBERT v1.1 (PubMed). monologg mirror ships safetensors + full config, so it
# loads under transformers 5.x + torch<2.6 (dmis-lab ships only .bin, now blocked
# by the torch.load security gate). Same weights, 768-d.
export GENE_REP_TEXT_MODEL="${GENE_REP_TEXT_MODEL:-monologg/biobert_v1.1_pubmed}"

# --- CELLxGENE serving (Serving/) --------------------------------------------
# A separate, lightweight conda env holds the cellxgene Annotate viewer
# (`cellxgene launch`) + cellxgene-gateway. It is intentionally NOT the heavy
# BatchCorrection env — the viewer only needs scanpy/anndata + cellxgene.
export CXG_ENV="${CXG_ENV:-${CONDA_ENV_BASE}/cxg}"

# Where prepped, serve-ready .h5ad copies live (gitignored). One subdir per
# variant: ${FLY_SERVE_DIR}/<variant>/fly_annotated.h5ad . cellxgene-gateway
# points at this parent dir to expose all variants behind one URL.
export FLY_SERVE_DIR="${FLY_SERVE_DIR:-${REPO_ROOT}/1 - Platform/serve}"

# Port the viewer / gateway binds on the compute node. Reached from a laptop via
# an SSH tunnel (see Serving/README.md), OR fronted by a Cloudflare Tunnel for a
# public URL (see Serving/SETUP_TUNNEL.md).
export CXG_PORT="${CXG_PORT:-5005}"

# Interface the viewer binds on the compute node. Default 127.0.0.1 (loopback):
# the SSH tunnel terminates on the node's loopback, so the unauthenticated viewer
# is NOT reachable by other jobs/users on the cluster's internal network — the
# tunnel is then genuine isolation. Set to 0.0.0.0 ONLY if you need to reach it
# from another node directly (e.g. a simple `ssh -L PORT:<node>:PORT` tunnel);
# that re-exposes the port cluster-internally, so prefer the loopback default +
# the ProxyJump tunnel command the launcher prints. The Cloudflare public path
# always binds loopback regardless (cloudflared connects to 127.0.0.1).
export CXG_BIND_HOST="${CXG_BIND_HOST:-127.0.0.1}"

# UI wrapper mode. "sleek" runs CELLxGENE on CXG_INTERNAL_PORT and exposes a
# repo-tracked dark UI proxy on CXG_PORT. "native" serves CELLxGENE directly.
export CXG_UI_MODE="${CXG_UI_MODE:-sleek}"
export CXG_INTERNAL_PORT="${CXG_INTERNAL_PORT:-5006}"
export CXG_DEFAULT_COLOR="${CXG_DEFAULT_COLOR:-cell_type_v2}"
export CXG_DEFAULT_LAYOUT="${CXG_DEFAULT_LAYOUT:-X_umap}"
export CXG_EMBEDDINGS="${CXG_EMBEDDINGS:-umap,tsne,umap_pca}"
export CXG_UI_PROFILE="${CXG_UI_PROFILE:-minimal}"
export CXG_METADATA_PROFILE="${CXG_METADATA_PROFILE:-sleek}"
export CXG_STAIN_FIELDS="${CXG_STAIN_FIELDS:-cell_type_v2,cell_type_v2_broad,cell_type_v2_fine,tissue,sex,age,sex_age,dataset,leiden_res0_2,leiden_res0_5,leiden_res1}"
export CXG_SUBSET_FIELDS="${CXG_SUBSET_FIELDS:-cell_type_v2,cell_type_v2_broad,cell_type_v2_fine,tissue,sex,age,sex_age,dataset,cell_type_v2_resolution,cell_type_v2_broad_confidence,cell_type_v2_fine_confidence,leiden_res0_5}"
export CXG_GENE_STAIN_ENABLED="${CXG_GENE_STAIN_ENABLED:-true}"
export CXG_ADVANCED_DRAWER_ENABLED="${CXG_ADVANCED_DRAWER_ENABLED:-true}"
export CXG_UI_ASSET_DIR="${CXG_UI_ASSET_DIR:-${REPO_ROOT}/1 - Platform/Serving/ui}"
export CXG_SLEEK_PROXY="${CXG_SLEEK_PROXY:-${REPO_ROOT}/1 - Platform/Serving/flybase_sleek_proxy.py}"
export CXG_LAUNCHER="${CXG_LAUNCHER:-${REPO_ROOT}/1 - Platform/Serving/flybase_cellxgene.py}"
export CXG_MINIMAL_RENDERER_ENABLED="${CXG_MINIMAL_RENDERER_ENABLED:-true}"
export CXG_MINIMAL_DEFAULT_EMBEDDING="${CXG_MINIMAL_DEFAULT_EMBEDDING:-umap}"
export CXG_MINIMAL_DATA_DIR="${CXG_MINIMAL_DATA_DIR:-${FLY_SERVE_DIR}/v2/minimal_umap}"
export CXG_MINIMAL_SIDECAR_BUILDER="${CXG_MINIMAL_SIDECAR_BUILDER:-${REPO_ROOT}/1 - Platform/Serving/build_minimal_umap_sidecar.py}"

# Canonical v2 serve paths. The full v2 copy is the default dataset; sleek UI
# mode hides non-core metadata in the browser. A physically smaller UI-profiled
# copy is optional and can be selected by overriding CXG_DATASET.
export FLY_V2_DATASET="${FLY_V2_DATASET:-${FLY_SERVE_DIR}/v2/fly_annotated_v2.h5ad}"
export FLY_V2_SLEEK_DATASET="${FLY_V2_SLEEK_DATASET:-${FLY_SERVE_DIR}/v2/fly_annotated_v2_sleek.h5ad}"

# --- Public hosting via Cloudflare Tunnel (Serving/run_persistent_tunnel.sh) ---
# The single dataset to expose publicly.
export CXG_DATASET="${CXG_DATASET:-${FLY_V2_DATASET}}"

# The no-root cloudflared binary (downloaded to ~/bin; see SETUP_TUNNEL.md).
export CLOUDFLARED_BIN="${CLOUDFLARED_BIN:-${HOME}/bin/cloudflared}"

# Named-tunnel identity. CXG_TUNNEL_NAME is what you pass to `cloudflared tunnel
# create/run`; CXG_PUBLIC_HOSTNAME is the stable public URL (a free subdomain you
# add to a free Cloudflare account). Both are set during the one-time interactive
# setup — override them in paths.local.sh once you have them.
export CXG_TUNNEL_NAME="${CXG_TUNNEL_NAME:-cellxgene}"
export CXG_PUBLIC_HOSTNAME="${CXG_PUBLIC_HOSTNAME:-CHANGEME.dpdns.org}"

# Partition for the long-lived service job. pi_lhtsai (lab, 2-day, steadier) is
# preferred over mit_preemptable for an always-on viewer.
export CXG_SERVICE_PARTITION="${CXG_SERVICE_PARTITION:-pi_lhtsai}"

# -----------------------------------------------------------------------------
check_paths() {
    local mode="${1:-default}"
    local ok=1
    echo "REPO_ROOT              = ${REPO_ROOT}"
    echo "FLY_DATA_PREP_DIR      = ${FLY_DATA_PREP_DIR}"
    echo "FLY_WORKFLOW_DIR       = ${FLY_WORKFLOW_DIR}"
    echo "FLY_INPUT_H5AD         = ${FLY_INPUT_H5AD}"
    echo "FLY_OUTPUTS            = ${FLY_OUTPUTS}"
    echo "FLY_PROCESSING_OUTPUTS = ${FLY_PROCESSING_OUTPUTS}"
    echo "FLY_STAGE3_OUTPUTS     = ${FLY_STAGE3_OUTPUTS}"
    echo "FLY_STAGE4_OUTPUTS     = ${FLY_STAGE4_OUTPUTS}"
    echo "FLY_STAGE5_OUTPUTS     = ${FLY_STAGE5_OUTPUTS}"
    echo "FLY_COMPARISON_OUTPUTS = ${FLY_COMPARISON_OUTPUTS}"
    echo "FLY_FIGURE_OUTPUTS     = ${FLY_FIGURE_OUTPUTS}"
    echo "FLY_LOGS               = ${FLY_LOGS}"
    echo "BATCHCORR_ENV          = ${BATCHCORR_ENV}"
    echo "FLY_CEL_REP_BUCKET     = ${FLY_CEL_REP_BUCKET}"
    echo "FLY_CEL_REP_DIR        = ${FLY_CEL_REP_DIR}   (Drosophila root)"
    echo "FLY_CEL_REP_DATA       = ${FLY_CEL_REP_DATA}"
    echo "FLY_CEL_REP_TRAINING   = ${FLY_CEL_REP_TRAINING}"
    echo "FLY_CEL_REP_INFERENCE  = ${FLY_CEL_REP_INFERENCE}"
    echo "FLY_CEL_REP_EVALUATIONS= ${FLY_CEL_REP_EVALUATIONS}"
    echo "FLY_CEL_REP_MODEL_WEIGHTS = ${FLY_CEL_REP_MODEL_WEIGHTS}"
    echo "FLY_CEL_REP_INTERSPECIES_DIR = ${FLY_CEL_REP_INTERSPECIES_DIR}"
    echo "CEL_REP_ENV            = ${CEL_REP_ENV}"
    echo "TF_ENV                 = ${TF_ENV}"
    echo "TF_HOME                = ${TF_HOME}"
    echo "FLY_GENE_REP_DIR       = ${FLY_GENE_REP_DIR}"
    echo "FLY_GENE_REP_DATA      = ${FLY_GENE_REP_DATA}"
    echo "FLY_GENE_REP_TRAINING  = ${FLY_GENE_REP_TRAINING}"
    echo "FLY_GENE_REP_EVALUATIONS = ${FLY_GENE_REP_EVALUATIONS}"
    echo "FLY_GENE_REP_MODEL_WEIGHTS = ${FLY_GENE_REP_MODEL_WEIGHTS}"
    echo "GENE_REP_ENV           = ${GENE_REP_ENV}"
    echo "GENE_REP_ESM_MODEL     = ${GENE_REP_ESM_MODEL}"
    echo "GENE_REP_TEXT_MODEL    = ${GENE_REP_TEXT_MODEL}"
    echo "SLURM_PARTITION        = ${SLURM_PARTITION}"
    echo "CXG_DATASET            = ${CXG_DATASET}"
    echo "CXG_PORT               = ${CXG_PORT}"
    echo "CXG_INTERNAL_PORT      = ${CXG_INTERNAL_PORT}"
    echo "CXG_BIND_HOST          = ${CXG_BIND_HOST}"
    echo "CXG_UI_MODE            = ${CXG_UI_MODE}"
    echo "CXG_UI_PROFILE         = ${CXG_UI_PROFILE}"
    echo "CXG_METADATA_PROFILE   = ${CXG_METADATA_PROFILE}"
    echo "CXG_DEFAULT_COLOR      = ${CXG_DEFAULT_COLOR}"
    echo "CXG_DEFAULT_LAYOUT     = ${CXG_DEFAULT_LAYOUT}"
    echo "CXG_EMBEDDINGS         = ${CXG_EMBEDDINGS}"
    echo "CXG_MINIMAL_DATA_DIR   = ${CXG_MINIMAL_DATA_DIR}"
    echo "CXG_TUNNEL_NAME        = ${CXG_TUNNEL_NAME}"
    echo "CXG_PUBLIC_HOSTNAME    = ${CXG_PUBLIC_HOSTNAME}"
    if [[ ! -f "${FLY_INPUT_H5AD}" ]]; then
        echo "WARNING: FLY_INPUT_H5AD does not exist yet — run '0 - Data Prep/workflow/ingest/download_afca.sh'"
        ok=0
    fi
    if [[ ! -f "${CXG_DATASET}" ]]; then
        echo "ERROR: CXG_DATASET not found: ${CXG_DATASET}"
        ok=0
    fi
    if [[ "${CXG_UI_MODE}" == "sleek" && "${CXG_MINIMAL_RENDERER_ENABLED}" == "true" \
          && ! -f "${CXG_MINIMAL_DATA_DIR}/minimal_schema.json" ]]; then
        echo "WARNING: minimal UMAP sidecar missing: ${CXG_MINIMAL_DATA_DIR}/minimal_schema.json"
        ok=0
    fi
    if [[ ! -d "${BATCHCORR_ENV}" ]]; then
        echo "ERROR: BATCHCORR_ENV not found: ${BATCHCORR_ENV}"
        ok=0
    fi
    if [[ ! -f "${FLY_MARKERS_RDS}" ]]; then
        echo "NOTE: FLY_MARKERS_RDS not present (optional) — ORA overlay will be skipped."
    fi
    if [[ ! -f "${FLY_FCA_MARKERS_CSV}" ]]; then
        echo "NOTE: FLY_FCA_MARKERS_CSV not present: ${FLY_FCA_MARKERS_CSV}"
    fi
    if [[ ! -f "${FLY_NEURON_MARKERS_CSV}" ]]; then
        echo "NOTE: FLY_NEURON_MARKERS_CSV not present: ${FLY_NEURON_MARKERS_CSV}"
    fi
    if [[ ! -d "${CEL_REP_ENV}" ]]; then
        echo "NOTE: CEL_REP_ENV not present yet: ${CEL_REP_ENV}"
        echo "      (only needed for '2 - Cel Rep' — create it per that README.)"
    fi
    if [[ ! -d "${GENE_REP_ENV}" ]]; then
        echo "NOTE: GENE_REP_ENV not present yet: ${GENE_REP_ENV}"
        echo "      (only needed for '3 - Gene Rep' — create it per that README.)"
    fi
    if [[ "${mode}" == "public" ]]; then
        local cf_config="${HOME}/.cloudflared/config.yml"
        if [[ -z "${CXG_PUBLIC_HOSTNAME}" || "${CXG_PUBLIC_HOSTNAME}" == "CHANGEME.dpdns.org" ]]; then
            echo "ERROR: CXG_PUBLIC_HOSTNAME is unset or still CHANGEME.dpdns.org"
            ok=0
        fi
        if [[ ! -x "${CLOUDFLARED_BIN}" ]]; then
            echo "ERROR: CLOUDFLARED_BIN not executable: ${CLOUDFLARED_BIN}"
            ok=0
        fi
        if [[ ! -f "${cf_config}" ]]; then
            echo "ERROR: ${cf_config} missing (see 1 - Platform/Serving/SETUP_TUNNEL.md)"
            ok=0
        else
            if ! grep -Fq "hostname: ${CXG_PUBLIC_HOSTNAME}" "${cf_config}"; then
                echo "ERROR: ${cf_config} does not contain hostname: ${CXG_PUBLIC_HOSTNAME}"
                ok=0
            fi
            if ! grep -Fq "service: http://127.0.0.1:${CXG_PORT}" "${cf_config}"; then
                echo "ERROR: ${cf_config} does not forward to http://127.0.0.1:${CXG_PORT}"
                ok=0
            fi
        fi
    elif [[ "${mode}" != "default" ]]; then
        echo "ERROR: unknown check_paths mode '${mode}' (expected: public)"
        ok=0
    fi
    [[ "${ok}" == "1" ]] && echo "All required paths verified." || echo "Some paths need attention (see above)."
}
