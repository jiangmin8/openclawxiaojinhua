# 路由器巡检定时任务
# 每 60 分钟执行一次
# 请将以下内容添加到 crontab (crontab -e)
# */60 * * * * /home/lz/.openclaw/workspace/cron/router_inspe.sh >> /var/log/cron/router_inspe.log 2>&1