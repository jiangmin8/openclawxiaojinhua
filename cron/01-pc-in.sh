# PC 巡检定时任务
# 每 30 分钟执行一次
# 请将以下内容添加到 crontab (crontab -e)
# */30 * * * * /home/lz/.openclaw/workspace/cron/pc_inspe.sh >> /var/log/cron/pc_inspe.log 2>&1
