# RISC-V Pipeline Diagram (from `ALL/ALL.ipynb`)

This file translates the end-to-end notebook workflow into an advisor-friendly diagram.

## 1) High-level pipeline (recommended for slides)

```mermaid
flowchart LR
    %% Inputs
    A1[RISC-V Unified DB\nall_instructions.golden.adoc]
    A2[RISC-V Opcodes\nextensions/*]
    A3[RISC-V Specifications\n3_SPECIFICATION/2_SPLIT\n(929 chunks)]

    %% Instruction branch
    subgraph I[Instruction Rule Synthesis]
      I1[1_INSTRUCTION_ALL.txt\nBuild full instruction metadata]
      I2[2_INSTRUCTION_SOME.txt\nFilter target instructions]
      I3[3_INSTRUCTION_BOOLEAN.txt\nLLM chunk matching]
      I4[4_INSTRUCTION_RULE.txt\nLLM rule extraction]
      I5[5_INSTRUCTION_FINAL.txt]
      I6[6_INSTRUCTION_TOTAL.txt\nAppend/update cumulative rules]
      I7[7_INSTRUCTION_SUMMARY.txt]
    end

    %% Register branch
    subgraph R[Register Rule Synthesis]
      R1[1_REGISTER_ALL.txt\nBuild full register metadata]
      R2[2_REGISTER_SOME.txt\nFilter target registers]
      R3[3_REGISTER_BOOLEAN.txt\nLLM chunk matching]
      R4[4_REGISTER_RULE.txt\nLLM rule extraction]
      R5[5_REGISTER_EXTENSION.txt]
      R6[6_REGISTER_FIELD.txt]
      R7[7_REGISTER_FINAL.txt]
      R8[8_REGISTER_TOTAL.txt\nAppend/update cumulative rules]
      R9[9_REGISTER_SUMMARY.txt]
    end

    %% Test generation & repair
    subgraph T[Test-case Generation + Repair]
      T1[1_TEST_CASE_INPUT.txt\nPrompt-ready constraints]
      T2[2_TEST_CASE_RAW.txt]
      T3[3_TEST_CASE_REVISED_*.txt\nStructured/numbered blocks]
      T4[4_REPAIR_TEST_CASE_OUTPUT.txt\nLLM+execution repair loop]
      T5[4_REPAIR_TEST_CASE_OUTPUT_2.txt\nRegister/semantic patching]
      T6[REPAIR_TEST_CASE_OUTPUT_EXTENSION.txt\nFiltered by extension headers]
    end

    %% Emulator validation
    subgraph Q[QEMU/xv6 Validation]
      Q1[1_QEMU_XV6_INPUT.txt]
      Q2[2_QEMU_XV6_RUN.txt\nAssemble/run + register deltas]
      Q3[3_QEMU_XV6_CHECK.txt\nPass/fail checks]
    end

    A1 --> I1
    A2 --> I1
    A3 --> I3
    I1 --> I2 --> I3 --> I4 --> I5 --> I6 --> I7

    A2 --> R1
    A3 --> R3
    R1 --> R2 --> R3 --> R4 --> R5 --> R6 --> R7 --> R8 --> R9

    I6 --> T1
    R8 --> T1
    T1 --> T2 --> T3 --> T4 --> T5 --> T6

    T5 --> Q1
    Q1 --> Q2 --> Q3
```

## 2) Mapping-focused view (close to your current sketch)

```mermaid
flowchart LR
    S[RISC-V Specifications] --> SC[Split into specification chunks (Python)] --> CH[Specification chunks (929)]

    O[RISC-V Opcodes] --> MX[Metadata extraction (Python)]
    U[RISC-V Unified DB] --> MX

    MX --> IM[Instruction metadata]
    MX --> RM[Register metadata]

    CH --> ML1[Matching (LLM)]
    IM --> ML1
    ML1 --> M1[Instruction-to-spec chunk mapping]

    CH --> ML2[Matching (LLM)]
    RM --> ML2
    ML2 --> M2[Register-to-spec chunk mapping]

    M1 --> IR[Instruction rules]
    M2 --> RR[Register rules]

    IR --> TG[Test-case generation]
    RR --> TG
    TG --> RP[Repair loop]
    RP --> QV[QEMU/xv6 validation]
```

## 3) Suggested figure caption (for thesis/advisor)

**Figure X.** End-to-end pipeline for deriving instruction/register rules from RISC-V sources, grounding them to specification chunks with LLM-based matching, generating and repairing test cases, and validating behavior in QEMU/xv6.

## 4) How to update this diagram when the pipeline changes

If your **new system** changed file names/stages, update the diagram with this quick workflow:

1. Open and run `ALL/ALL.ipynb` from top to bottom so the latest pipeline artifacts are regenerated.
2. Compare current outputs under:
   - `ALL/4_INSTRUCTION/1_OUTPUT/`
   - `ALL/5_REGISTER/1_OUTPUT/`
   - `ALL/6_TEST_CASE/`
   - `ALL/TEXT/`
3. In this file, update Mermaid node labels to match the new artifact names/stages.
4. Keep the same 4 logical groups (Inputs, Rule Synthesis, Test/Repair, QEMU Validation) unless your architecture changed.
5. Re-render Mermaid (GitHub preview or Mermaid Live Editor) and verify no parse errors.

### Minimal command checklist

```bash
# from repo root
python - <<'PY'
import json
from pathlib import Path
nb=json.loads(Path('ALL/ALL.ipynb').read_text())
print('code cells:', sum(1 for c in nb['cells'] if c['cell_type']=='code'))
for i,c in enumerate(nb['cells']):
    if c['cell_type']=='code' and c['source']:
        first=''.join(c['source']).splitlines()[0]
        if first.strip().startswith('#'):
            print(f'{i:02d}: {first.strip()}')
PY
```

Use that list as the source-of-truth stage order, then rename the Mermaid nodes accordingly.
