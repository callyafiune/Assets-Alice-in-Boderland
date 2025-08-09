#!/usr/bin/env python3
import argparse, sys, pathlib

def main():
    p = argparse.ArgumentParser(description="Merge a prompt file and an assets file into a single output, replacing a placeholder token.")
    p.add_argument("--prompt", required=True, help="Path to the base prompt file (without assets).")
    p.add_argument("--assets", required=True, help="Path to the assets file (CHAVE = URL).")
    p.add_argument("--out", required=True, help="Path to write the merged prompt.")
    p.add_argument("--token", default="[ASSETS]", help="Placeholder token in the prompt to be replaced with assets block. Default: [ASSETS]")
    args = p.parse_args()

    prompt_path = pathlib.Path(args.prompt)
    assets_path = pathlib.Path(args.assets)
    out_path = pathlib.Path(args.out)

    if not prompt_path.exists():
        sys.exit(f"Erro: prompt não encontrado: {prompt_path}")
    if not assets_path.exists():
        sys.exit(f"Erro: assets não encontrado: {assets_path}")

    prompt = prompt_path.read_text(encoding="utf-8")
    assets = assets_path.read_text(encoding="utf-8").strip()

    if args.token not in prompt:
        sys.exit(f"Erro: token '{args.token}' não encontrado no prompt.")

    merged = prompt.replace(args.token, assets)

    out_path.write_text(merged, encoding="utf-8")
    print(f"OK! Arquivo mesclado em: {out_path}")

if __name__ == "__main__":
    main()
