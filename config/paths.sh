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

# --- Data & outputs -----------------------------------------------------------
# The AFCA atlas .h5ad (~3 GB) lives under "0 - Data Prep/data" (gitignored). It is
# fetched by "0 - Data Prep/scripts/download_afca.sh".
export FLY_INPUT_H5AD="${FLY_INPUT_H5AD:-${REPO_ROOT}/0 - Data Prep/data/adata_headBody_S_v1.0.h5ad}"

# Processing outputs (gitignored). Stage-3 writes the integrated/annotated
# object + figures here, namespaced per variant.
export FLY_PROCESSING_OUTPUTS="${FLY_PROCESSING_OUTPUTS:-${REPO_ROOT}/0 - Data Prep/outputs}"
export FLY_LOGS="${FLY_LOGS:-${FLY_PROCESSING_OUTPUTS}/Logs}"

# Optional fly marker set for the ORA cross-check overlay (not on the critical
# path — if unset/missing, ORA is skipped and afca_annotation is used directly).
export FLY_MARKERS_RDS="${FLY_MARKERS_RDS:-${REPO_ROOT}/0 - Data Prep/Resources/Fly_Markers.rds}"

# Config files consumed by the pipeline.
export FLY_PIPELINE_YAML="${FLY_PIPELINE_YAML:-${_CONFIG_DIR}/pipeline.yaml}"
export FLY_VARIANTS_YAML="${FLY_VARIANTS_YAML:-${_CONFIG_DIR}/variants.yaml}"

# --- Cel Rep (2 - Cel Rep): cell-language co-embedding ------------------------
# Multimodal Cell2Sentence + CLIP ("CellCLIP") model for the FCA/AFCA fly atlas,
# adapted from a collaborator's FlyBaseAdrita work. Code lives in
# "2 - Cel Rep/Processing"; large inputs/intermediates (h5ad, .npy, .pt, .csv)
# live in "2 - Cel Rep/data" (gitignored) and are surfaced to the CWD-based Python
# via relative symlinks in Processing/. Figures land in "2 - Cel Rep/outputs".
export FLY_CEL_REP_DIR="${FLY_CEL_REP_DIR:-${REPO_ROOT}/2 - Cel Rep}"
export FLY_CEL_REP_DATA="${FLY_CEL_REP_DATA:-${FLY_CEL_REP_DIR}/data}"
export FLY_CEL_REP_OUTPUTS="${FLY_CEL_REP_OUTPUTS:-${FLY_CEL_REP_DIR}/outputs}"
export FLY_CEL_REP_LOGS="${FLY_CEL_REP_LOGS:-${FLY_CEL_REP_OUTPUTS}/Logs}"

# Dedicated conda env for the co-embedding model. NOT the heavy BatchCorrection
# env — this one needs torch + transformers + sentence-transformers + scanpy +
# umap-learn + scikit-learn. It must be created before running (see
# "2 - Cel Rep/README.md"); override the name/location in paths.local.sh.
export CEL_REP_ENV="${CEL_REP_ENV:-${CONDA_ENV_BASE}/cel_rep}"

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
    echo "FLY_INPUT_H5AD         = ${FLY_INPUT_H5AD}"
    echo "FLY_PROCESSING_OUTPUTS = ${FLY_PROCESSING_OUTPUTS}"
    echo "BATCHCORR_ENV          = ${BATCHCORR_ENV}"
    echo "FLY_CEL_REP_DIR        = ${FLY_CEL_REP_DIR}"
    echo "FLY_CEL_REP_DATA       = ${FLY_CEL_REP_DATA}"
    echo "CEL_REP_ENV            = ${CEL_REP_ENV}"
    echo "SLURM_PARTITION        = ${SLURM_PARTITION}"
    echo "CXG_DATASET            = ${CXG_DATASET}"
    echo "CXG_PORT               = ${CXG_PORT}"
    echo "CXG_INTERNAL_PORT      = ${CXG_INTERNAL_PORT}"
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
        echo "WARNING: FLY_INPUT_H5AD does not exist yet — run '0 - Data Prep/scripts/download_afca.sh'"
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
    if [[ ! -d "${CEL_REP_ENV}" ]]; then
        echo "NOTE: CEL_REP_ENV not present yet: ${CEL_REP_ENV}"
        echo "      (only needed for '2 - Cel Rep' — create it per that README.)"
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
