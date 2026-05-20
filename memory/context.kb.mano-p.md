# Mano-P GUI-VLA 研究

> 源：`github.com/Mininglamp-AI/Mano-P` + `clawhub.ai/hanningwang/mano-cua`
> 日期：2026-05-20

## 核心

GUI-VLA 端侧视觉语言动作模型。三阶段自增强训练（SFT→离线RL→在线RL）+ 闭环数据循环。「思考-行动-验证」循环纠错。

## 对我们

- 云端版：ClawHub 可直接装，任何桌面系统可用
- 本地版：需 Apple Silicon M4+ 32GB，当前不可用
- Windows/Linux：Beta，有小 bug
- **暂不安装，以后遇到类似 GUI 自动化再比较。**

## 关键指标

- OSWorld 基准第一 (58.2%)
- 4B 模型 80 tokens/s (M5 Pro)
- ClawHub 技能 MIT 开源
