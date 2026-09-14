#!/bin/sh

config_path="$(dirname "$0")/../copilot/project.json"

if [ ! -f "$config_path" ]; then
  printf '%s\n' '{"systemMessage":"Copilot project configuration is absent. Do not interrupt unrelated work. Before using a configurable capability, run setup-copilot-project in the main agent before delegation."}'
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  if ! python3 -c 'import json,os,sys; data=json.load(open(sys.argv[1], encoding="utf-8")); caps=data.get("capabilities"); required=("issueTracker","gitServer","grilling","conciseStyle"); allowed=("unconfigured","enabled","disabled"); valid=type(data.get("schemaVersion")) is int and data["schemaVersion"]==1 and isinstance(caps,dict) and set(caps)==set(required); valid=valid and all(name in caps and isinstance(caps[name],dict) and type(caps[name].get("status")) is str and caps[name]["status"] in allowed for name in required); valid=valid and all(caps[name]["status"]!="enabled" or type(caps[name].get("instructions")) is str and os.path.isfile(caps[name]["instructions"]) for name in ("issueTracker","gitServer")); valid=valid and all(caps[name]["status"]!="enabled" or type(caps[name].get("customization")) is str and bool(caps[name]["customization"].strip()) for name in ("grilling","conciseStyle")); sys.exit(0 if valid else 1)' "$config_path" >/dev/null 2>&1; then
    printf '%s\n' '{"systemMessage":"Copilot project configuration is invalid or does not use schema version 1. Do not interrupt unrelated work. Run setup-copilot-project before using a configurable capability."}'
    exit 0
  fi
elif command -v node >/dev/null 2>&1; then
  if ! node -e 'const fs=require("fs"); const data=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); const caps=data.capabilities; const required=["issueTracker","gitServer","grilling","conciseStyle"]; const allowed=["unconfigured","enabled","disabled"]; let valid=Number.isInteger(data.schemaVersion)&&data.schemaVersion===1&&caps&&typeof caps==="object"&&!Array.isArray(caps)&&Object.keys(caps).length===required.length&&required.every(n=>caps[n]&&typeof caps[n]==="object"&&!Array.isArray(caps[n])&&typeof caps[n].status==="string"&&allowed.includes(caps[n].status)); valid=valid&&["issueTracker","gitServer"].every(n=>caps[n].status!=="enabled"||(typeof caps[n].instructions==="string"&&fs.statSync(caps[n].instructions,{throwIfNoEntry:false})?.isFile())); valid=valid&&["grilling","conciseStyle"].every(n=>caps[n].status!=="enabled"||(typeof caps[n].customization==="string"&&caps[n].customization.trim())); if(!valid) process.exit(1)' "$config_path" >/dev/null 2>&1; then
    printf '%s\n' '{"systemMessage":"Copilot project configuration is invalid or does not use schema version 1. Do not interrupt unrelated work. Run setup-copilot-project before using a configurable capability."}'
    exit 0
  fi
else
  printf '%s\n' '{"systemMessage":"Copilot project configuration could not be validated because neither Python 3 nor Node.js is available. Do not interrupt unrelated work. Run setup-copilot-project before using a configurable capability."}'
  exit 0
fi

if grep -Eq '"status"[[:space:]]*:[[:space:]]*"unconfigured"' "$config_path"; then
  printf '%s\n' '{"systemMessage":"One or more Copilot capabilities remain unconfigured. Do not interrupt unrelated work. At first relevant use, run setup-copilot-project in the main agent before delegation."}'
else
  printf '%s\n' '{}'
fi