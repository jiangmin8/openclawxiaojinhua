# 知识库种子 — 源码技术清单

> 日期：2026-05-20 | 路径：`/mnt/e/知识库种子/`

## 1. CrewAI
**URL:** https://github.com/crewAIInc/crewAI
**目录:** `lib/` (crewai/flow/agent/task), `docs/`
**配置:** `pyproject.toml`, `.pre-commit-config.yaml`
**依赖:** `pyproject.toml` (Python, uv)
**README:** `README.md`
**入口脚本:** `conftest.py`
**核心框架:** Python, Flow装饰器(@start/@listen/@router)

## 2. agent-skills
**URL:** https://github.com/addyosmani/agent-skills
**目录:** `skills/` (23个), `agents/` (3个persona), `references/`, `hooks/`
**配置:** `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`, `hooks/hooks.json`
**依赖:** 无(纯Markdown技能)
**README:** `README.md`
**入口脚本:** `hooks/` (session-start.sh, sdd-cache-*.sh)
**核心框架:** Claude Code Plugin, SKILL.md格式

## 3. CloakBrowser
**URL:** https://github.com/CloakHQ/CloakBrowser
**目录:** `cloakbrowser/` (browser.py/config.py/download.py/human/), `bin/`, `examples/`, `js/`
**配置:** `pyproject.toml`, `js/package.json`, `js/tsconfig.json`
**依赖:** `pyproject.toml` (Python), `js/package.json` (Node/Playwright)
**README:** `README.md`
**入口脚本:** `cloakbrowser/browser.py` (launch/launch_async), `bin/docker-entrypoint.sh`
**核心框架:** Python + Node.js, Chromium C++补丁(49处)

## 4. Ruflo
**URL:** https://github.com/ruvnet/ruflo
**目录:** `ruflo/src/`, `v3/`, `bin/`, `plugins/`, `docs/`
**配置:** `.agents/config.toml`, `.claude/mcp.json`, `.claude/settings.json`
**依赖:** `package.json` (Node/TypeScript)
**README:** `README.md`
**入口脚本:** `scripts/install.sh`, `.claude/statusline.sh`
**核心框架:** TypeScript, Queen-led Swarm, MCP-first, AgentDB, Event Sourcing

## 5. JiuwenSwarm
**URL:** https://github.com/openJiuwen-ai/jiuwenswarm
**目录:** `jiuwenswarm/` (agents/app/gateway/server), `jiuwenbox/`, `packages/`, `docker/`
**配置:** `pyproject.toml`, `jiuwenswarm/package-lock.json`
**依赖:** `pyproject.toml` (Python, pip)
**README:** `README.md`
**入口脚本:** `jiuwenswarm/app.py`, `start_services.py`, `init_workspace.py`
**核心框架:** Python, 华为云MaaS, 小艺集成

## 6. Elephant Agent
**URL:** https://github.com/agentic-in/elephant-agent
**目录:** `packages/` (30+模块: context/curiosity/understanding/growth/experience), `apps/`, `deploy/`
**配置:** `pyproject.toml`, `netlify.toml`
**依赖:** `pyproject.toml` (Python, uv)
**README:** `README.md`
**入口脚本:** `apps/daemon.py`, `apps/daemon_http.py`, `apps/daemon_command.py`
**核心框架:** Python, 4镜Personal Model, Curiosity引擎, Growth rollout

## 7. Memori
**URL:** https://github.com/MemoriLabs/Memori
**目录:** `core/` (Rust), `memori/` (Python SDK), `memori-ts/` (TS SDK), `integrations/` (OpenClaw/Hermes)
**配置:** `pyproject.toml`, `core/Cargo.toml`, `.pre-commit-config.yaml`
**依赖:** `pyproject.toml` (Python), `core/Cargo.toml` (Rust)
**README:** `README.md`
**入口脚本:** `memori/agent.py`, `memori/_cli.py`, `memori/_config.py`
**核心框架:** Rust core + Python/TS SDK, OpenClaw原生插件

## 8. PraisonAI
**URL:** https://github.com/MervinPraison/PraisonAI
**目录:** `src/`, `docker/`, `examples/`
**配置:** `docker/services.yaml`, `.github/praisonai-*.yaml`
**依赖:** (Python, pip)
**README:** `README.md`
**入口脚本:** `docker/quick-start.sh`, `examples/agent_centric_api.py`
**核心框架:** Python, AI Workforce, MCP注册, AgentFlow可视化

## 9. iii
**URL:** https://github.com/iii-hq/iii
**目录:** `engine/` (Rust), `sdk/` (Node/Python/Rust), `console/` (React+Rust), `skills/`, `crates/` (8个子crate)
**配置:** `Cargo.toml`, `pnpm-workspace.yaml`, `Makefile`
**依赖:** `Cargo.toml` (Rust), `package.json` (Node/TypeScript)
**README:** `README.md`
**入口脚本:** `iii --use-default-config`, `curl ...install.sh`
**核心框架:** Rust引擎 + 多语言SDK, Worker-Function-Trigger三原语, agentmemory的地基

## 10. agentmemory
**URL:** https://github.com/rohitg00/agentmemory
**目录:** `src/` (TypeScript core), `packages/`, `integrations/` (OpenClaw/Hermes/Filesystem), `plugin/`, `viewer/`
**配置:** `iii-config.yaml`, `package.json`, `tsconfig.json`
**依赖:** `package.json` (Node/TypeScript, iii engine)
**README:** `README.md`
**入口脚本:** `agentmemory` (全局CLI), `npx @agentmemory/agentmemory`
**核心框架:** TypeScript + iii引擎, 53 MCP工具, 4层记忆固化, 雅典娜当前Memory技能的后端
